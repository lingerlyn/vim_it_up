#! /usr/bin/env/bash

# backup_configurations(){
#     if [ -f $HOME/.config/nvim/init.vim ]; then
#         echo "Pre-existing neovim configuration found"
#         cp $HOME/.config/nvim/init.vim $HOME/.config/nvim/init.vim.bak
#     else
#         echo "You are clear to go"
#     fi
# }

check_apt_packages(){
    requirements=(tmux python2.7 python-pip virtualenv python3-venv)
    sudo apt update
    for package in ${requirements[@]}; do
        dpkg -s "$package" >/dev/null 2>&1 && {
            echo "$package is installed."
        } || {
            sudo apt-get -y install $package
        }
    done
}

check_if_installed(){
    if ! [ -x "$(command -v cargo)" ]; then
      echo 'Error: Rust is not installed.' >&2
    else
        echo "You're good to go!"
    fi
}

make_virtual_envs(){
    if [ ! -f $HOME/.virtualenvs/neovim2/bin/activate ]; then 
        virtualenv $HOME/.virtualenvs/neovim2
        source $HOME/.virtualenvs/neovim2/bin/activate
        pip2 install -U pynvim
        deactivate 
    fi

    if [ ! -f $HOME/.virtualenvs/neovim3/bin/activate  ]; then 
        python3 -m venv $HOME/.virtualenvs/neovim3
        source $HOME/.virtualenvs/neovim3/bin/activate
        pip install -U pynvim
        deactivate
    fi
}

install_rg(){
    if ! [ -x "$(command -v cargo)" ]; then
      echo 'Error: Rust is not installed.' >&2
      curl https://sh.rustup.rs -sSf | sh
      source $HOME/.bash_profile
      source $HOME/.bashrc
    else
        echo "You're good to go!"
    fi
    cargo install ripgrep
    cargo install bat
    cargo install exa
}

install_tmux(){
    sudo apt install tmux
    curl -fLo ~/.tmux.conf \
    https://raw.githubusercontent.com/mjlbach/vim_it_up/master/.tmux.conf
}

install_neovim(){
    if [ "$(uname)" == "Darwin" ]
    then 
        brew install neovim
        echo "MacOS"
    elif [ "$(uname)" == "Linux" ]
    then
        curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage --create-dir -o $HOME/.neovim/nvim.appimage
        chmod u+x $HOME/.neovim/nvim.appimage
        echo "alias nvim=$HOME/.neovim/nvim.appimage" >> $HOME/.bashrc
        source $HOME/.bashrc
    else 
        echo "Get a better OS!"
    fi

    mkdir -p $HOME/.vim/{ swap backup undo }

    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    curl -fLo ~/.config/nvim/init.vim --create-dirs \
    https://raw.githubusercontent.com/mjlbach/vim_it_up/master/init.vim

    $HOME/.neovim/nvim.appimage +PlugInstall +qall 
}

uninstall_neovim(){
    if [ "$(uname)" == "Darwin" ]
    then 
        brew uninstall neovim
    elif [ "$(uname)" == "Linux" ]
    then
        rm -rf $HOME/.neovim/nvim.appimage
    else 
        echo "Get a better OS!"
    fi

    rm -rf $HOME/.local/share/nvim
}

check_apt_packages
make_virtual_envs
install_tmux
install_neovim

