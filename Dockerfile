FROM ubuntu:22.04 AS build-env
RUN ln -sf /usr/share
RUN sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list
RUN apt update \
 && DEBIAN_FRONTEND=noninteractive apt build-dep -y vim \
 && apt install -y git curl
RUN curl -OL https://github.com/vim/vim/archive/refs/tags/v9.1.0741.tar.gz
RUN tar -zxvf v9.1.0741.tar.gz
RUN cd vim-9.1.0741/ \
 && ./configure \
 && make
RUN cd /tmp \
 && git clone https://github.com/kenconnor/dotfiles.git

FROM osrf/ros:humble-desktop
COPY --from=build-env /vim-9.1.0741 /root/vim-9.1.0741
RUN apt-get update && apt-get install -y \
    git \
    curl \
    clangd \
    libcanberra-dev \
    libgpm-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN cd /root/vim-9.1.0741 && make install
RUN curl -sL install-node.vercel.app/lts | bash -s -- -y
RUN mkdir /root/.cache
RUN cd $HOME && sh -c "$(curl -fsSL https://raw.githubusercontent.com/Shougo/dein-installer.vim/master/installer.sh)" --overwrite-config ./.cache/dein --use-vim-config
ADD https://api.github.com/repos/kenconnor/dotfiles/git/refs/heads/main version.json
COPY . /root/
