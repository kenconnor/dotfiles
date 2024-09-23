FROM ubuntu:latest
RUN apt-get update && apt-get install -y \
    vim-gtk3 \
    git \
    curl \
    clangd \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN curl -sL install-node.vercel.app/lts | bash -s -- -y
RUN mkdir /root/.cache
RUN cd $HOME && sh -c "$(curl -fsSL https://raw.githubusercontent.com/Shougo/dein-installer.vim/master/installer.sh)" --overwrite-config ./.cache/dein --use-vim-config
ADD https://api.github.com/repos/kenconnor/dotfiles/git/refs/heads/main version.json
RUN cd /tmp \
 && git clone https://github.com/kenconnor/dotfiles.git \
 && cp -r /tmp/dotfiles/. /root/
