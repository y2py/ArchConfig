local vars = require("variables")
local fn   = require("utils.functions")

hl.on("hyprland.start", function()
    -- Keyring and auth
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Auto delete trash 30 days old
    hl.exec_cmd("trash-empty 30")

    -- Cursors
    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    -- Location provider and night light
    hl.exec_cmd("/usr/lib/geoclue-2.0/demos/agent")
    hl.exec_cmd("sleep 1 && gammastep")

    -- Forward bluetooth media commands to MPRIS
    hl.exec_cmd("mpris-proxy")

    -- Start shell
    hl.exec_cmd("caelestia shell -d")


    -- aws

    hl.exec_cmd("kdeconnectd")
    --hl.exec_cmd("sudo isw -b on")
    hl.exec_cmd("vencord-update")
    hl.exec_cmd("gloriousctl --set-effect single --set-colors FF0000 --set-brightness 4")
    hl.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1")
    hl.exec_cmd("discover-overlay")
    hl.exec_cmd("systemctl --user enable opentabletdriver.service --now")
    hl.exec_cmd("/home/aws/.config/AwsScripts/disks/mount-usb.sh")
    hl.exec_cmd("/home/aws/.config/hypr/hyprland/idlescripts/restore-idle-state.sh")
    hl.exec_cmd("/home/aws/.config/hypr/hyprland/force_dark_mode.sh")
end)

-- Resizer listeners
local function apply_resizer_rules(win)
    local float_center = {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.center({ window = win }),
    }
    local pip_actions = fn.move_actions(win) or {}

    -- Bitwarden
    fn.resizer(win, "Bitwarden", 20, 54, float_center, true, "class")                                       -- Native app
    fn.resizer(win, "^Extension: %(Bitwarden Password Manager%) %- Bitwarden", 20, 54, float_center, false) -- Firefox
    fn.resizer(win, "nngceckbapebfimnlniiiahkandclblb", 20, 54, float_center, true, "class")                -- Chromium

    -- Picture in picture
    fn.resizer(win, "Picture[- ]in[- ][Pp]icture", 0, 0, pip_actions, false)
end




hl.on("window.title", apply_resizer_rules)
hl.on("window.open", apply_resizer_rules)







