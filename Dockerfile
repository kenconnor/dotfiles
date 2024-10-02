FROM ubuntu:22.04 AS build-env
RUN ln -sf /usr/share
RUN sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list
RUN apt update \
 && DEBIAN_FRONTEND=noninteractive apt build-dep -y vim \
 && apt install -y --no-install-recommends \
    curl \
    git \
    unzip \
    ca-certificates

# Download & Make vim
RUN curl -OL https://github.com/vim/vim/archive/refs/tags/v9.1.0741.tar.gz
RUN tar -zxvf v9.1.0741.tar.gz
RUN cd vim-9.1.0741/ \
 && ./configure \
 && make

# Download Clangd
RUN CLANGD_VERSION=$(curl -I https://github.com/clangd/clangd/releases/latest | grep -i location | awk -F '/' '{print $NF}' | tr -d '\r') \
 && curl -L -o clangd-linux-${CLANGD_VERSION}.zip https://github.com/clangd/clangd/releases/download/${CLANGD_VERSION}/clangd-linux-${CLANGD_VERSION}.zip \
 && mkdir -p /root/.config/coc/extensions/coc-clangd-data/install/${CLANGD_VERSION}/ \
 && unzip clangd-linux-${CLANGD_VERSION}.zip -d /root/.config/coc/extensions/coc-clangd-data/install/${CLANGD_VERSION}/

FROM osrf/ros:humble-desktop
COPY --from=build-env /vim-9.1.0741 /root/vim-9.1.0741
COPY --from=build-env /root/.config/coc/extensions/coc-clangd-data/install /root/.config/coc/extensions/coc-clangd-data/install
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    curl \
    ca-certificates \
    libcanberra-dev \
    libgpm-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN cd /root/vim-9.1.0741 && make install
RUN curl -sL install-node.vercel.app/lts | bash -s -- -y
RUN mkdir /root/.cache
RUN cd $HOME && sh -c "$(curl -fsSL https://raw.githubusercontent.com/Shougo/dein-installer.vim/master/installer.sh)" --overwrite-config ./.cache/dein --use-vim-config
#RUN mkdir -p ~/.cache/dein/repos/github.com/Shougo
#RUN cd ~/.cache/dein/repos/github.com/Shougo \
# && git clone https://github.com/Shougo/dein.vim
COPY .vimrc /root/.vimrc
COPY .vim /root/.vim
RUN yes | vim +qall
RUN vim -c "CocInstall -sync coc-pyright" +qall
RUN vim -c "CocInstall -sync coc-clangd" +qall
