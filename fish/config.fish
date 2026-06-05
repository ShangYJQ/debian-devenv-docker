if status is-interactive
    # 基础环境变量
    set -gx EDITOR nvim

    set -gx FZF_DEFAULT_COMMAND 'fd --type f'
    fish_add_path $HOME/.cargo/bin
    fish_add_path $HOME/.local/bin

    # eza 替代 ls
    if type -q eza
        alias l='command eza --icons -l --group-directories-first'
        alias ls='command eza --icons --group-directories-first'
        alias ll='command eza --icons -l --git --header --total-size --time-style=long-iso'
        alias la='command eza --icons -l -a --git --header --total-size --time-style=long-iso'
    end

    function lt
        set level 3

        if test (count $argv) -gt 0
            set level $argv[1]
        end

        eza --icons --tree --level=$level
    end

    alias c='clear'

    # git abbr
    abbr -a qkgit 'git add .; and aicommits -y; and git push'
    abbr -a gpl 'git pull'
    abbr -a gph 'git push'
    abbr -a g2p 'git pull; and git push'
    abbr -a ga 'git add .'
    abbr -a gr 'git restore .'
    abbr -a gs 'git status --short'

    if type -q zoxide
        zoxide init fish | source
    end

    if type -q fzf
        fzf --fish | source
    end

    # yazi: 退出后 cd 到 yazi 当前目录
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        command yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

end
