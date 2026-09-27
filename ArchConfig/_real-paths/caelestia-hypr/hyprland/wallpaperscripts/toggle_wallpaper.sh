
#!/bin/bash
run_wallpaper="$HOME/.config/hypr/hyprland/wallpaperscripts/run_wallpaper.sh"
stop_wallpaper="$HOME/.config/hypr/hyprland/wallpaperscripts/stop_wallpaper.sh"
function checkRunning(){
    pgrep "mpvpaper" > /dev/null
}



function toggle(){
    if checkRunning; then
        bash $stop_wallpaper
    else
        bash $run_wallpaper
    fi

}

toggle
