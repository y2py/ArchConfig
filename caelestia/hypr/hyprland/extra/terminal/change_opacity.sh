#!/bin/bash


path=~/.config/kitty/kitty.conf
lua_path=~/.config/hypr/hyprland/rules.lua
current=~/.config/hypr/hyprland/extra/terminal/current
toSet=0.78
iValue=0.05
dValue=0.05

if [[ -n $1 ]];then
    toSet=$(cat $current)
    if [ "$1" == "increase" ]; then
        toSet=$(echo "$toSet + $iValue" | bc -l)

    elif [ "$1" == "decrease" ]; then
        toSet=$(echo "$toSet - $dValue" | bc -l) 

    elif [ "$1" == "default" ]; then
        toSet=0.78
    else
        toSet="$1"
    fi
    if (( $(echo "$toSet > 1.0" | bc -l) )); then
        toSet=1
    elif (( $(echo "$toSet < 0.0" | bc -l) )); then
        toSet=0
    fi
    
 fi

value=$(grep -r "background_opacity" $path)
newValue="background_opacity $toSet"

sed -i "s/$value/$newValue/g" $path

if [[ -f $lua_path ]]; then
    sed -i -E "s/(class = \"codium\" \}, opacity = \")[0-9.]+( override\")/\1$toSet\2/g" $lua_path
    sed -i -E "s/(class = \"VSCodium\" \}, opacity = \")[0-9.]+( override\")/\1$toSet\2/g" $lua_path
fi

echo $toSet>$current

        
sleep 0.3
for tty in /dev/pts/[0-9]*; do
    cat ~/.local/state/caelestia/sequences.txt > "$tty" 2>/dev/null
done
