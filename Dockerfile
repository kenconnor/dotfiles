FROM ubuntu:22.04 AS build-env
RUN apt update \
 && apt install -y --no-install-recommends \
    curl \
    git \
    unzip \
    ca-certificates

# Download Nvim
RUN NVIM_VERSION=$(curl -sI https://github.com/neovim/neovim/releases/latest | grep -i location | awk -F '/' '{print $NF}' | tr -d '\r' | sed 's/^v//') \
 && curl -OL https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim.appimage
RUN chmod u+x nvim.appimage && ./nvim.appimage  --appimage-extract

# Download Clangd
RUN CLANGD_VERSION=$(curl -I https://github.com/clangd/clangd/releases/latest | grep -i location | awk -F '/' '{print $NF}' | tr -d '\r') \
 && curl -L -o clangd-linux-${CLANGD_VERSION}.zip https://github.com/clangd/clangd/releases/download/${CLANGD_VERSION}/clangd-linux-${CLANGD_VERSION}.zip \
 && mkdir -p /root/.config/coc/extensions/coc-clangd-data/install/${CLANGD_VERSION}/ \
 && unzip clangd-linux-${CLANGD_VERSION}.zip -d /root/.config/coc/extensions/coc-clangd-data/install/${CLANGD_VERSION}/

FROM osrf/ros:humble-desktop
COPY .config /root/.config
COPY --from=build-env /squashfs-root /root/nvim
COPY --from=build-env /root/.config/coc/extensions/coc-clangd-data/install /root/.config/coc/extensions/coc-clangd-data/install
RUN ln -s /root/nvim/AppRun /usr/bin/nvim
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN curl -sL install-node.vercel.app/lts | bash -s -- -y
RUN mkdir -p /root/.local/share
RUN nvim +'CocInstall -sync coc-pyright' +qall
RUN nvim +'CocInstall -sync coc-clangd' +qall
RUN nvim +'CocCommand -sync clangd.install' +qall
