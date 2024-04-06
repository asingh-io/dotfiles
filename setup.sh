#!/bin/bash
set -e -x

DIR=${HOME}

get_dotfiles () {

    echo "(1/4): GETTING DOTFILES..."
    git clone https://github.com/asingh-io/dotfiles.git $DIR/dotfiles
}

setup_nvim () {

    echo "(2/4) SETTING UP NVIM..."
    sudo dnf install -y neovim python3-neovim
    # Install black for formatting
    sudo dnf install -y python3-pip
    python3 -m pip install black
    sudo dnf remove -y vim  

    mkdir -p ${DIR}/.config/nvim/autoload

    ln -s ${DIR}/dotfiles/.config/nvim/init.vim $DIR/.config/nvim/init.vim

    # Install vim plug for package management
    curl -fLo $DIR/.config/nvim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # Install packages
    nvim +PlugInstall +qall

}

setup_tmux () {

    echo "(3/4) SETTING UP TMUX..."
    # Install tmux dependencies
    sudo dnf -y install ncurses-devel
    sudo dnf -y install libevent-devel
    sudo dnf -y install htop


    ln -s $DIR/dotfiles/.tmux.conf $DIR/.tmux.conf
    ln -s $DIR/dotfiles/.lightline.tmux.conf $DIR/.lightline.tmux.conf
    sudo dnf install tmux

    # Get the latest version
    # git clone https://github.com/tmux/tmux.git
    # cd tmux
    # sh autogen.sh
    # ./configure && make install
    # cd ..
}

setup_zsh () {

    echo "(4/4) SETTING UP ZSH..."
     sudo dnf -y install zsh
    # Install oh-my-zsh
    wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O $DIR/install.sh
    chown -R $USER:$USER $DIR/install.sh
    cd $DIR
    echo pwd
    chmod +x ./install.sh
    ./install.sh

    # Setting zsh plugin 
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    
    # Change the default shell to zsh
    sudo dnf -y install util-linux-user
    
    rm -f $DIR/.zshrc $DIR/.bashrc_private
    ln -s $DIR/dotfiles/.zshrc $DIR/.zshrc
    ln -s $DIR/dotfiles/.bashrc_private $DIR/.bashrc_private
    sudo chsh -s /bin/zsh ${USER}

}

setup_powerline () {
    # set powerline10 K
    ZSH_THEME="powerlevel10k/powerlevel10k"
    echo "typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true" >> ~/.p10k.zsh
}

check_sudo() {
	if [ "$EUID" -ne 0 ]
	  then echo "Please run as root"
	  exit
	fi
}

get_dotfiles
setup_nvim
setup_tmux
setup_zsh
