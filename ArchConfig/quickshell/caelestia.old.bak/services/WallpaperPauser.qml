pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Io

import qs.services

Singleton {
    id: root

    property bool pauseOnBattery: false
    property bool pauseOnWindowOverlap: true
    property string hwDecoder: "none"

    Settings {
        id: pauserSettings
        category: "WallpaperPauser"
        property alias pauseOnBattery: root.pauseOnBattery
        property alias pauseOnWindowOverlap: root.pauseOnWindowOverlap
        property alias hwDecoder: root.hwDecoder
    }
    property bool paused: false
    property bool _loaded: false
    property string pauseReason: "None"

    Process {
        id: saveHwDecoderProcess
    }

  function recalculate() {
    let newPaused = false;
    let reason = "None";

    // Rule #1 — Battery
    if (pauseOnBattery && UPower.onBattery) {
        newPaused = true;
        reason = "Battery";
    } else if (pauseOnWindowOverlap) {
        const monitor = Hyprland.focusedMonitor;
        const ws = monitor && monitor.activeWorkspace ? monitor.activeWorkspace : Hyprland.focusedWorkspace;

        if (ws) {
            const toplevels = ws.toplevels.values;

            // Rule #2 — Actual fullscreen only
            for (const t of toplevels) {
                const fs = t.lastIpcObject?.fullscreen;
                // Hyprland reports fullscreen as 0 (none), 1 (maximized/fullscreen), 2 (fullscreen fullscreen)
                // depending on version some send booleans, so we check both
                if (fs === true || fs === 1 || fs === 2) {
                    newPaused = true;
                    reason = "Fullscreen: " + (t.lastIpcObject?.title ?? "Unknown");
                    break;
                }
            }
        }
    }

    paused = newPaused;
    root.pauseReason = reason;
} 
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            root.recalculate();
        }
        function onFocusedMonitorChanged() {
            root.recalculate();
        }
        function onRawEvent(event) {
            const n = event.name;
            if (n.startsWith("workspace") || n.startsWith("activewindow") || n.startsWith("createworkspace") || n.startsWith("destroyworkspace") || ["fullscreen", "changefloatingmode", "minimize", "movewindow", "openwindow", "closewindow", "moveworkspace", "focusedmon"].includes(n)) {
                recalcTimer.restart();
            }
        }
    }

    Connections {
        target: UPower
        function onOnBatteryChanged() {
            recalcTimer.restart();
        }
    }

    Timer {
        id: recalcTimer
        interval: 50
        onTriggered: root.recalculate()
    }

    // Startup timer to ensure we catch the asynchronously loaded Hyprland and Quickshell state
    Timer {
        id: startupTimer
        interval: 1000
        repeat: true
        running: true
        property int attempts: 0
        onTriggered: {
            root.recalculate();
            attempts++;
            if (attempts >= 5) {
                running = false;
            }
        }
    }

    onPauseOnBatteryChanged: {
        recalculate();
    }

    onPauseOnWindowOverlapChanged: {
        recalculate();
    }

    onHwDecoderChanged: {
        // We still need to sync this to a text file because the python CLI needs to read it
        // BEFORE the Qt application starts in order to inject the environment variables.
        if (root._loaded) {
            saveHwDecoderProcess.command = ["sh", "-c", "echo '" + root.hwDecoder + "' > ~/.cache/caelestia/hwDecoder.txt && nohup sh -c 'sleep 0.5 && caelestia shell -d' >/dev/null 2>&1 & caelestia shell -k"];
            saveHwDecoderProcess.running = true;
        }
    }

    Component.onCompleted: {
        root._loaded = true;
        recalculate();
    }
}
