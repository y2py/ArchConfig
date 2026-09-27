#!/bin/bash

update_vol() {
    local vol=$(pamixer --get-volume)
    local mute=$(pamixer --get-mute)
    
    if [ "$mute" = "true" ] || [ "$vol" -eq 0 ]; then
        /usr/bin/eww update volico="🔇"
        vol="0"
    else
        /usr/bin/eww update volico="🔊"
    fi
    /usr/bin/eww update get_vol="$vol"
}

# تشغيل الجلب لأول مرة عند إقلاع الشريط
update_vol

# الاستماع المستمر لتحديث الصوت فوراً عند الرفع أو الخفض
pactl subscribe 2>/dev/null | stdbuf -oL grep --line-buffered "sink" | while read -r _; do
    update_vol
done


