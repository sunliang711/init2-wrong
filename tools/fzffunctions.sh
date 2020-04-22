if command -v fd >/dev/null 2>&1;then
    export FZF_DEFAULT_COMMAND='fd --type f --type d'
fi
export FZF_DEFAULT_OPTS='-m --height 70% --reverse --border'

fzff(){
    local dest=${1:-$HOME}
    if [ -d "$dest" ];then
        local wd=$(pwd)
        cd "$dest"
    else
        echo "No such directory: '$dest'"
        return 1
    fi

    fd --type f | fzf || { echo "canceld"; cd $wd; }
}

fzfd(){
    local dest=${1:-$HOME}
    if [ -d "$dest" ];then
        local wd=$(pwd)
        cd "$dest"
    else
        echo "No such directory: '$dest'"
        return 1
    fi

    fd --type d | fzf || { echo "canceld."; cd $wd; }
}

fp() {
    fzf --bind 'ctrl-f:preview-page-down' --bind 'ctrl-b:preview-page-up' --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || rougify {}  || highlight -O ansi -l {} || coderay {} || cat -n {}) 2> /dev/null | head -500'
}

fe(){
    local dest=${1:-$HOME}
    if [ -d "$dest" ];then
        local wd=$(pwd)
        cd "$dest"
    else
        echo "No such directory: '$dest'"
        return 1
    fi

    local editor=vi
    if command -v vim >/dev/null 2>&1;then
        editor=vim
    fi

    if command -v nvim >/dev/null 2>&1;then
        editor=nvim
    fi

    if command -v fd >/dev/null 2>&1;then
        file=$(fd --type f | fzf --border --height 60% --reverse -m --bind 'ctrl-f:preview-page-down' --bind 'ctrl-b:preview-page-up' --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || rougify {}  || highlight -O ansi -l {} || coderay {} || cat -n {}) 2> /dev/null | head -500')
    else
        file=$(find . -not -path '*/\.*' -type f | fzf --border --height 60% --reverse -m --bind 'ctrl-f:preview-page-down' --bind 'ctrl-b:preview-page-up' --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || rougify {}  || highlight -O ansi -l {} || coderay {} || cat -n {}) 2> /dev/null | head -500')
    fi
    if [ -n "$file" ];then
        # multi files
        echo "$file" | tr '\n' ' ' | xargs $editor
    fi
    cd "$wd"
}

fE(){
    local dest=${1:-$HOME}
    if [ -d "$dest" ];then
        local wd=$(pwd)
        cd "$dest"
    else
        echo "No such directory: '$dest'"
        return 1
    fi

    local editor=vi
    if command -v vim >/dev/null 2>&1;then
        editor=vim
    fi

    if command -v nvim >/dev/null 2>&1;then
        editor=nvim
    fi

    if command -v fd >/dev/null 2>&1;then
        file=$(fd -HI --type f | fzf --border --height 60% --reverse -m --bind 'ctrl-f:preview-page-down' --bind 'ctrl-b:preview-page-up' --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || rougify {}  || highlight -O ansi -l {} || coderay {} || cat -n {}) 2> /dev/null | head -500')
    else
        file=$(find . -type f | fzf --border --height 60% --reverse -m --bind 'ctrl-f:preview-page-down' --bind 'ctrl-b:preview-page-up' --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || rougify {}  || highlight -O ansi -l {} || coderay {} || cat -n {}) 2> /dev/null | head -500')
    fi
    if [ -n "$file" ];then
        # multi files
        echo "$file" | tr '\n' ' ' | xargs $editor
    fi
    cd "$wd"
}

fcd(){
    local dest=${1:-$HOME}
    if [ -d "$dest" ];then
        local wd=$(pwd)
        cd "$dest"
    else
        echo "No such directory: '$dest'"
        return 1
    fi

    local dir
    if command -v fd >/dev/null 2>&1;then
        dir=$(fd --type d | fzf --height 60% --border --reverse) && cd "$dir" || { echo "Canceled"; cd "$wd"; }
    else
        dir=$(find . -not -path '*/\.*' | fzf --height 60% --border --reverse) && cd "$dir" || { echo "Canceled"; cd "$wd"; }
    fi
}

fCD(){
    local dest=${1:-$HOME}
    if [ -d "$dest" ];then
        local wd=$(pwd)
        cd "$dest"
    else
        echo "No such directory: '$dest'"
        return 1
    fi

    local  dir
    if command -v fd >/dev/null 2>&1;then
        dir=$(fd -HI --type d | fzf --height 80% --border --reverse) && cd "$dir" || { echo "Canceled"; cd "$wd"; }
    else
        dir=$(find . -type d | fzf --height 80% --border --reverse) && cd "$dir" || { echo "Canceled"; cd "$wd"; }
    fi
}
