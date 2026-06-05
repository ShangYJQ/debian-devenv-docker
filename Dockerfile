FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

ARG NVIM_CONFIG_REPO="https://github.com/ShangYJQ/nvim.config.git"
ARG NVIM_VERSION="master"

SHELL ["/bin/bash", "-lc"]

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	git \
	build-essential \
	make \
	cmake \
	lld \
	ninja-build \
	gettext \
	pkg-config \
	unzip \
	tar \
	xz-utils \
	fish \
	ripgrep \
	fd-find \
	fzf \
	python3 \
	python3-pip \
	python3-venv \
	nodejs \
	npm \
	libtree-sitter-dev \
	clang \
	gdb \
	clangd \
	btop \
	fastfetch \
	clang-format \
	lldb \
	procps \
	less \
	man-db \
	manpages-dev \
	locales \
	zoxide \
	eza \
	sudo \
	&& rm -rf /var/lib/apt/lists/*

# Debian 里 fd 叫 fdfind，很多 nvim 配置默认找 fd
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

# 源码构建 Neovim
RUN git clone --depth 1 --branch "${NVIM_VERSION}" https://github.com/neovim/neovim.git /tmp/neovim && \
	cd /tmp/neovim && \
	make CMAKE_BUILD_TYPE=Release && \
	make install && \
	cd / && \
	rm -rf /tmp/neovim

# 安装 rustup + Rust nightly
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
	sh -s -- -y --default-toolchain nightly --profile default && \
	/root/.cargo/bin/rustup component add rust-src rustfmt clippy rust-analyzer

# clone nvim 配置
RUN mkdir -p /root/.config && git clone "${NVIM_CONFIG_REPO}" /root/.config/nvim;

RUN npm install -g tree-sitter-cli

# GCC 14 can OOM while compiling large generated tree-sitter parsers under Colima.
ENV CC=clang

# vim.pack 非交互安装插件
RUN nvim --headless \
	"+lua vim.pack.update(nil, { force = true })" \
	"+qa"

# clone fish 配置
COPY fish /root/.config/fish

WORKDIR /work

CMD ["fish"]
