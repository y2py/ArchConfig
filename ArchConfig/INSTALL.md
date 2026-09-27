# استرجاع النظام من الباك أب

خطوات تثبيت النظام على جهاز جديد باستخدام هذا الباك أب.

## 1. تثبيت الأساسيات

```bash
# تحديث النظام
sudo pacman -Syu

# yay (AUR helper) - لو مش مثبت
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si

# Hyprland والأدوات الأساسية
sudo pacman -S hyprland hyprctl hypridle hyprlock
```

## 2. تثبيت caelestia shell

**مهم:** لا تسحب `caelestia` من هذا الباك أب — هو مستثنى عمدًا لأنه repo منفصل.
ثبّته من مصدره الأصلي:

```bash
yay -S caelestia-shell
```

أو حسب الطريقة الرسمية الحالية لمشروع caelestia (راجع توثيقهم لو الطريقة تغيرت).

## 3. سحب هذا الباك أب

```bash
cd ~
git clone https://github.com/y2py/arch-dotfiles.git config-backup
```

## 4. نسخ الإعدادات العادية

معظم الملفات هنا عادية وتُنسخ مباشرة لـ `~/.config`:

```bash
cp -r ~/config-backup/* ~/.config/
```

⚠️ راجع أولًا هل فيه ملفات موجودة أصلًا في `~/.config` عشان متكتبش فوقها بالغلط.

## 5. استرجاع hypr (symlink مهم!)

`hypr/` في هذا الباك أب هو مجرد إشارة (Git ما بيحفظش محتوى الـ symlinks).
المحتوى الحقيقي محفوظ في `_real-paths/caelestia-hypr/`. لازم تسترجعه يدويًا:

```bash
mkdir -p ~/.local/share/caelestia
cp -r ~/config-backup/_real-paths/caelestia-hypr ~/.local/share/caelestia/hypr

# احذف أي مجلد hypr فاضي اترفع بالغلط، واعمل اللينك الصحيح
rm -rf ~/.config/hypr
ln -s ~/.local/share/caelestia/hypr ~/.config/hypr
```

تأكد إن اللينك صح:
```bash
readlink -f ~/.config/hypr
# لازم يطلع: /home/aws/.local/share/caelestia/hypr
```

## 6. الأدوات المستخدمة في الـ scripts (dependencies)

الحزم دي بيعتمد عليها بعض السكربتات في `hypr/hyprland/` و`eww/scripts/`:

```
awk basename bash brightnessctl cat cp curl cut date echo eww
fastfetch git grep grim head hyprctl hypridle hyprland hyprlock jq
kitty loginctl ls mkdir mv nmcli nvim pamixer pidof playerctl
ranger rm sh sleep slurp socat stdbuf systemctl uptime wget wpctl xargs
```

تثبيت سريع للناقص:
```bash
sudo pacman -S --needed brightnessctl grim slurp jq kitty pamixer \
    playerctl ranger socat wget networkmanager pipewire-pulse
```

## 7. صلاحيات التنفيذ (executable)

بعد النسخ، تأكد إن السكربتات قابلة للتنفيذ (أحيانًا بتفقد الصلاحية عند النسخ):

```bash
find ~/.local/share/caelestia/hypr -name "*.sh" -exec chmod +x {} \;
find ~/.config/eww -name "*.sh" -exec chmod +x {} \;
```

## 8. الحزم/التطبيقات الثقيلة المستثناة من الباك أب

الإعدادات (config) بتاعت التطبيقات دي **مش** محفوظة في الباك أب لأنها كانت غالبًا كاش/بيانات مؤقتة أكتر من إعدادات حقيقية. ثبّت التطبيقات دي عاديًا وأعد ضبطها يدويًا لو محتاج:

- discord / discordcanary / vesktop / equibop / legcord
- البراوزرات: البريف، chromium، google-chrome، mozilla firefox
- VSCodium
- CurseForge
- Todoist
- obsidian
- LosslessCut

## 9. ما بعد التثبيت

```bash
# تفعيل fish shell كـ default (لو محتاج)
chsh -s /usr/bin/fish

# إعادة تشغيل caelestia shell
caelestia shell -k
caelestia shell -d
```

## ملاحظات إضافية

- `ranger/plugins/ranger_devicons` كان Git repo متضمّن، مستبعد من الباك أب. ثبّته يدويًا لو محتاجه:
  ```bash
  git clone <رابط ranger_devicons> ~/.config/ranger/plugins/ranger_devicons
  ```
- ملفات حساسة زي `gh/hosts.yml` و`kdeconnect/privateKey.pem` مستبعدة عمدًا من الباك أب لأسباب أمنية. لازم تعمل login/setup من جديد لـ:
  - `gh auth login` (GitHub CLI)
  - KDE Connect (سيربط نفسه بأجهزتك من جديد تلقائيًا عند أول استخدام)
- راجع `.gitignore` في جذر الريبو لمعرفة أي مجلدات تانية مستبعدة.
