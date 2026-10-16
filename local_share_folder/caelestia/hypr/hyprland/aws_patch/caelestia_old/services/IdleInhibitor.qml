pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Singleton {
    id: root

    property alias enabled: props.enabled
    readonly property alias enabledSince: props.enabledSince

    onEnabledChanged: {
        if (enabled)
        props.enabledSince = new Date();

        idleSaveProcess.running=true
    }

    PersistentProperties {
        id: props

        property bool enabled
        property date enabledSince

        reloadableId: "idleInhibitor"
    }

    IdleInhibitor {
        enabled: props.enabled
        window: PanelWindow {
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"
            mask: Region {}
        }
      }

 Process {
    id: idleSaveProcess

    command: [
        "bash",
        "-c",
        "$HOME/.config/hypr/hyprland/idlescripts/save-idle-state.sh"
    ]
}

    IpcHandler {
        function isEnabled(): bool {
            return props.enabled;
        }

        function toggle(): void {
          props.enabled = !props.enabled;
          idleSaveProcess.running=true
        }

        function enable(): void {
          props.enabled = true;
          idleSaveProcess.running=true
        }

        function disable(): void {
            props.enabled = false;
            idleSaveProcess.running=true
          }

        target: "idleInhibitor"
    }
}

