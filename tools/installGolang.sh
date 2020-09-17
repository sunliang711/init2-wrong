#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
thisDir="$(cd $(dirname $rpath) && pwd)"
cd "$thisDir"

user="${SUDO_USER:-$(whoami)}"
home="$(eval echo ~$user)"

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
cyan=$(tput setaf 5)
        bold=$(tput bold)
reset=$(tput sgr0)
function runAsRoot(){
    verbose=0
    while getopts ":v" opt;do
        case "$opt" in
            v)
                verbose=1
                ;;
            \?)
                echo "Unknown option: \"$OPTARG\""
                exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))
    cmd="$@"
    if [ -z "$cmd" ];then
        echo "${red}Need cmd${reset}"
        exit 1
    fi

    if [ "$verbose" -eq 1 ];then
        echo "run cmd:\"${red}$cmd${reset}\" as root."
    fi

    if (($EUID==0));then
        sh -c "$cmd"
    else
        if ! command -v sudo >/dev/null 2>&1;then
            echo "Need sudo cmd"
            exit 1
        fi
        sudo sh -c "$cmd"
    fi
}
###############################################################################
# write your code below (just define function[s])
# function with 'function' is hidden when run help, without 'function' is show
###############################################################################
function need(){
    if ! command -v $1 >/dev/null 2>&1;then
        echo "need $1"
        exit 1
    fi
}
usage(){
    cat<<EOF
    $(basename $0) install [version]
    $(basename $0) uninstall [version]
EOF
}

# TODO
defaultVersion=1.13.8
prefix=$HOME/.app/go

install(){
    need curl
    need tar
    version=${1:-$defaultVersion}
    dest=$HOME/.app/go/$version

    if [ ! -d $dest ];then
        mkdir -p $dest
    fi
    case $(uname) in
        Linux)
            goURL=https://dl.google.com/go/go${version}.linux-amd64.tar.gz
            ;;
        Darwin)
            goURL=https://dl.google.com/go/go${version}.darwin-amd64.pkg
            echo "Download golang to ~/Downlads from $goURL"
            cd $home/Downloads && curl -LO $goURL && echo "download go in ~/Downloads" && exit 0;
            ;;
    esac
    cd /tmp
    local name=go${version}.linux-amd64.tar.gz
    if [ ! -e $name ];then
        echo "Download $name to /tmp..."
        curl -LO $goURL || { echo "Download $name error"; exit 1; }
    fi

    cmd="tar -C $dest -xvf $name"
    echo "$cmd ..."
    bash -c "$cmd >/dev/null" && echo "Done" || { echo "Extract $name failed."; exit 1; }

    local localFile="${SHELLRC_ROOT}/shellrc.d/local"
    local binPath="${dest}/go/bin"
    if [ -e "${localFile}" ];then
        if ! grep -q "${binPath}" "${localFile}";then
            echo "append_path ${binPath}" >> "${localFile}"
        fi
    else
        echo "go$version has been installed to $dest, add ${binPath} to PATH manually"
    fi

    cd - >/dev/null

}

uninstall(){
    version=${1:-$defaultVersion}
    dest=$HOME/.app/go/$version

    if [ -d $dest ];then
        echo "remove $dest..."
        /bin/rm -rf $dest && echo "Done."
    fi
}



###############################################################################
# write your code above
###############################################################################
function help(){
    cat<<EOF2
Usage: $(basename $0) ${bold}CMD${reset}

${bold}CMD${reset}:
EOF2
    perl -lne 'print "\t$1" if /^\s*(\w+)\(\)\{$/' $(basename ${BASH_SOURCE}) | grep -v runAsRoot
}
function loadENV(){
    if [ -z "$INIT_HTTP_PROXY" ];then
        echo "INIT_HTTP_PROXY is empty"
        echo -n "Enter http proxy: (if you need) "
        read INIT_HTTP_PROXY
    fi
    if [ -n "$INIT_HTTP_PROXY" ];then
        echo "set http proxy to $INIT_HTTP_PROXY"
        export http_proxy=$INIT_HTTP_PROXY
        export https_proxy=$INIT_HTTP_PROXY
        export HTTP_PROXY=$INIT_HTTP_PROXY
        export HTTPS_PROXY=$INIT_HTTP_PROXY
        git config --global http.proxy $INIT_HTTP_PROXY
        git config --global https.proxy $INIT_HTTP_PROXY
    else
        echo "No use http proxy"
    fi
}

function unloadENV(){
    if [ -n "$https_proxy" ];then
        unset http_proxy
        unset https_proxy
        unset HTTP_PROXY
        unset HTTPS_PROXY
        git config --global --unset-all http.proxy
        git config --global --unset-all https.proxy
    fi
}


case "$1" in
     ""|-h|--help|help)
        help
        ;;
    *)
        "$@"
esac
