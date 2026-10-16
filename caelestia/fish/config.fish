if status is-interactive
    # Starship custom prompt
    starship init fish | source
    # Direnv + Zoxide
    command -v direnv &>/dev/null && direnv hook fish | source
    command -v zoxide &>/dev/null && zoxide init fish --cmd cd | source

    # Better ls
    alias ls='eza --icons --group-directories-first -1'

    # Abbrs
    abbr lg lazygit
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l ls
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    # Custom colours
    cat ~/.local/state/caelestia/sequences.txt 2>/dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end

    alias pomo='~/go/bin/pomo'
    alias rain='terminal-rain'
    alias cls='clear'
    alias python='/home/aws/venv/bin/python'

    function enable_3D
        hyprpm enable hypr3d
    end

    function update_icon
        sudo ~/.config/hypr/hyprland/update_icon.sh
    end

    function vencord-update
        vencordinstallercli -install -location /home/aws/.config/discord/app*
    end

    function convert_mp4
        bash /home/aws/.config/hypr/hyprland/mp4_fixer.sh $argv
    end

    # Custom fish config
    source ~/.config/caelestia/user-config.fish 2>/dev/null

end

# Created by `pipx` on 2026-07-29 00:16:53
set PATH $PATH /home/aws/.local/bin
