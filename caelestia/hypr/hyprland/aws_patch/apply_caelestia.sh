#!/bin/bash
LOCATION="/etc/xdg/quickshell"
OLD=caelestia_old
echo "CHECKING IF \"caelestia\" EXISTS"
if [ -d "$LOCATION/caelestia" ];then
    echo "\"caelestia\" EXISTS."
else
    echo "ERROR: \"caelestia\" DOES NOT EXIST!"
    exit 1
fi
echo "CHECKING IF \"caelestia_old\" FOLDER EXISTS"
if [ -d $OLD ];then
    echo "\"caelestia_old\" FOLDER EXISTS."
else
    echo "ERROR: \"caelestia_old\" FOLDER DOES NOT EXIST!"
    exit 1
fi

MAIN=$LOCATION/caelestia

counter=0

if sudo cp -r "$OLD/modules/lock" "$MAIN/modules/"; then
    echo "replaced $MAIN/modules/lock with $OLD/modules/lock"
    (( counter++ ))
else
    echo "REPLACE FAILS ON modules/lock"
fi

if sudo cp -r "$OLD/modules/osd" "$MAIN/modules/"; then
    echo "replaced $MAIN/modules/osd with $OLD/modules/osd"
    (( counter++ ))
else
    echo "REPLACE FAILS ON modules/osd"
fi

if sudo sed -i "s/Keep Awake/Caffaine/g" "$MAIN/modules/utilities/cards/IdleInhibit.qml"; then
    echo "REPLACED \"Keep Awake\" IN $MAIN/modules/utilities/cards/IdleInhibit.qml BY \"Caffaine\""
    (( counter++ ))
else
    echo "REPLACE FAILS ON $MAIN/modules/utilities/cards/IdleInhibit.qml"
fi


echo "Checking if \"WallpaperPauser.qml\" exists in $MAIN/services"
if [ -f "$MAIN/services/WallpaperPauser.qml" ]; then
    echo "\"WallpaperPauser.qml\" exists in \"$MAIN/services\""
else
    echo "\"WallpaperPauser.qml\" does not exist in \"$MAIN/services\" Please Patch Caelestia With \"Caelestia-aw\""
    exit 0
fi

echo "Checking if \"WallpaperPauser.qml\" exists in $OLD/services"
if [ -f "$OLD/services/WallpaperPauser.qml" ]; then
    echo "\"WallpaperPauser.qml\" exists in \"$OLD/services\""
else
    echo "\"WallpaperPauser.qml\" does not exist in \"$OLD/services\" Please Patch Caelestia With \"Caelestia-aw\" and make a new backup with it"
    exit 0
fi

if sudo cp -r "$OLD/services/WallpaperPauser.qml" "$MAIN/services/"; then
    echo "replaced $MAIN/services/WallpaperPauser.qml with $OLD/services/WallpaperPauser.qml"
    (( counter++ ))
else
    echo "REPLACE FAILS ON services/WallpaperPauser.qml"
fi

echo "Restarting Caelestia.."
caelestia shell -k && sleep 2 && caelestia shell -d && ~/.config/hypr/hyprland/idlescripts/restore-idle-state.sh && ~/.config/hypr/hyprland/force_dark_mode.sh
echo "Applied $counter effects!"
