#!/bin/bash
# Todo; Rewrite to /bin/sh so it will run on *BSD?
set -e

ROOT_DIR=~/offsec
USE_ZYPPER=1
USE_PIP2=1
USE_PIP3=1
USE_GIT=1
SKIP_CHECK=0
SKIP_LIST=()
GIT_CLONE="git clone --depth=1"
PIP2="pip2 install --upgrade --user"
PIP3="pip3 install --upgrade --user"
CORE_PATTERN="core-%p.dmp"

function install_git
{
    NAME=$1
    REPO=$2
    INSTALL_PATH=$3
    POST_COMMAND=$4
    if [ $USE_GIT -eq 1 ]; then
        echo -e "\e[32m\e[1m--] Installing $NAME\e[0m"
        $GIT_CLONE $REPO $ROOT_DIR/$INSTALL_PATH || (pushd $ROOT_DIR/$INSTALL_PATH && git pull && popd)
        pushd $ROOT_DIR/$INSTALL_PATH && $POST_COMMAND && popd
    fi
}

function install_zypper
{
    NAME=$1
    PKG_NAME=$2
    POST_COMMAND=$3
    if [ $USE_ZYPPER -eq 1 ]; then
        echo -e "\e[32m\e[1m--] Installing $NAME\e[0m"
        sudo zypper -n in $PKG_NAME
        $POST_COMMAND
    fi
}

function install_pip2
{
    NAME=$1
    PKG_NAME=$2
    POST_COMMAND=$3
    if [ $USE_PIP2 -eq 1 ]; then
        echo -e "\e[32m\e[1m--] Installing $NAME\e[0m"
        $PIP2 $PKG_NAME
        $POST_COMMAND
    fi
}

function install_pip3
{
    NAME=$1
    PKG_NAME=$2
    POST_COMMAND=$3
    if [ $USE_PIP3 -eq 1 ]; then
        echo -e "\e[32m\e[1m--] Installing $NAME\e[0m"
        $PIP3 $PKG_NAME
        $POST_COMMAND
    fi
}



function load_config
{
    CONFIG_FILE=~/.lifprc
    if [[ ! -e $CONFIG_FILE ]]; then
        touch $CONFIG_FILE
        # Todo; Create example config
        chmod 600 $CONFIG_FILE
    fi
    source $CONFIG_FILE
}

function run_lifp
{
    echo "  _.,  Lazy Installer    ,._"
    echo "~(._\"@   For Pentesters @\"_.)~"
    echo "  \" \"      -- Stolas     \" \""

    echo -e "\e[32m\e[1m--] Current Configuration\e[0m"
    echo -e "\e[32m\e[1m--] Current Configuration\e[0m"
    load_config
    echo -n " :: root directory      " ; echo "$ROOT_DIR"
    echo -n " :: user                " ; echo "$USER"
    echo -n " :: core_pattern        " ; echo "$CORE_PATTERN"
    echo -n " :: use zypper          " ; echo "$USE_ZYPPER"
    echo -n " :: use pip2            " ; echo "$USE_PIP2"
    echo -n " :: use pip3            " ; echo "$USE_PIP3"
    echo -n " :: use git             " ; echo "$USE_GIT"
    echo -n " :: pip2 command        " ; echo "$PIP2"
    echo -n " :: pip3 command        " ; echo "$PIP3"
    echo -n " :: git clone command   " ; echo "$GIT_CLONE"

    if [ $SKIP_CHECK -eq 0 ]; then
        while true; do
            echo "Change settings in $CONFIG_FILE"
            read -p "Is this ok?" yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi

    mkdir -p $ROOT_DIR/{Fuzzing,Exploitation,Cracking,Enumeration,SecLists,Reversing}

    # Todo; Remove most of the zypper's
    # Todo; Gef, GoBuster, Aircrack, SecLists, enum4linux, hashcat, hydra, ncrack, afl, z3, triton, EyeWitness, Impacket, Metasploit, umap, aircrack, hashcat, hydra, ncrack, binja, ripr, diphora, SecLists

    # Todo; Make configurable to ignore certain files w/o having to edit this.
    install_zypper "DevTools" "cmake gcc"
    install_zypper "Python2 DevChain" "python python-pip python-devel"
    install_zypper "Python3 DevChain" "python3 python3-pip python3-devel"
    install_zypper "OpenSSL Headers" libopenssl-devel
    install_zypper "Python Curses" python-curses
    install_pip2   "PwnTools" pwntools
    install_zypper "Nmap Scanner" nmap
    install_zypper "Ncat" ncat
    install_pip3   "MitM HTTP(S) Proxy" mitmproxy
    install_pip2   "Scapy Library Py2" scapy
    install_pip3   "Scapy Library Py3" scapy-python3
    install_zypper "ini_config LibraryaHeaders 64bit" libini_config-devel
    install_zypper "ini_config LibraryaHeaders 32bit" libini_config-devel-32bit
    install_git    "Preeny Preload libs" https://github.com/zardus/preeny.git Exploitation/preeny "make -s -j4"
    install_pip2   "Ropper" ropper
    install_pip2   "Keystone Engine" keystone-engine
    install_pip2   "Unicorn Engine" unicorn
    install_pip2   "Capstone Engine" capstone
    install_zypper "John the Ripper" john
    install_git    "Sqlmap" https://github.com/sqlmapproject/sqlmap.git Exploitation/sqlmap
    install_zypper "Wireshark" wireshark-ui-qt

    # Todo; Fix
    echo -e "\e[32m\e[1m--] Setting CorePattern\e[0m"
    sudo sysctl -w kernel_core_pattern=$CORE_PATTERN

    # Todo; Find a cleaner solution
    echo -e "\e[32m\e[1m--] Installing GDB Enhanced Features (GEF) \e[0m"
    wget -q -O- https://github.com/hugsy/gef/raw/master/gef.sh | sh
}

# Recommended to source the file, so the install_git command is available =)
run_lifp
