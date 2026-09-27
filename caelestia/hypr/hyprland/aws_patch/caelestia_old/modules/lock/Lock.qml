pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components.misc

Scope {
    property alias lock: lock

    WlSessionLock {
        id: lock

        signal unlock

        LockSurface {
            lock: lock
            pam: pam
        }
    }

    Pam {
        id: pam
        lock: lock
    }

    Connections {
        target: pam

        function onAuthenticationSucceeded(): void {
            onUnlockProcess.running = true
            lock.unlock()
        }
    }

    Loader {
        asynchronous: true
        active: true
        onLoaded: active = false

        // Preload ScreencopyView to work around async backend loading during lock
        sourceComponent: ScreencopyView {
            captureSource: Quickshell.screens[0]
        }
    }

    Process {
        id: onLockProcess

        command: [
            "bash",
            Quickshell.env("HOME") +
            "/.config/hypr/hyprland/lockscripts/onLock.sh"
        ]
    }

Process {
    id: onUnlockProcess

    command: [
        "bash",
        Quickshell.env("HOME") +
        "/.config/hypr/hyprland/lockscripts/onUnlock.sh"
    ]
}

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "lock"
        description: "Lock the current session"

        onPressed: {
            onLockProcess.running = true
            lock.locked = true
        }
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "unlock"
        description: "Unlock the current session"

        onPressed: {
            onUnlockProcess.running = true
            lock.unlock()
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            onLockProcess.running = true
            lock.locked = true
        }

        function unlock(): void {
            onUnlockProcess.running = true
            lock.unlock()
        }

        function isLocked(): bool {
            return lock.locked
        }
    }
}
