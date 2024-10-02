FROM ubuntu:latest AS build-env
RUN apt update \
 && apt install -y --no-install-recommends \
    curl \
    git \
    unzip \
    ca-certificates

# Download Clangd
RUN CLANGD_VERSION=$(curl -I https://github.com/clangd/clangd/releases/latest | grep -i location | awk -F '/' '{print $NF}' | tr -d '\r') \
 && curl -L -o clangd-linux-${CLANGD_VERSION}.zip https://github.com/clangd/clangd/releases/download/${CLANGD_VERSION}/clangd-linux-${CLANGD_VERSION}.zip \
 && mkdir -p /root/.config/coc/extensions/coc-clangd-data/install/${CLANGD_VERSION}/ \
 && unzip clangd-linux-${CLANGD_VERSION}.zip -d /root/.config/coc/extensions/coc-clangd-data/install/${CLANGD_VERSION}/

FROM ubuntu:latest
COPY --from=build-env /root/.config/coc/extensions/coc-clangd-data/install /root/.config/coc/extensions/coc-clangd-data/install
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    curl \
    ca-certificates \
    vim \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN curl -sL install-node.vercel.app/lts | bash -s -- -y
RUN mkdir -p ~/.cache/dein/repos/github.com/Shougo
RUN cd ~/.cache/dein/repos/github.com/Shougo \
 && git clone https://github.com/Shougo/dein.vim
COPY .vimrc /root/.vimrc
COPY .vim /root/.vim
RUN yes | vim +qall
RUN vim -c "CocInstall -sync coc-pyright" +qall
RUN vim -c "CocInstall -sync coc-clangd" +qall
