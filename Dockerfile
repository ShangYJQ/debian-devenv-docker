FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive
ENV CC=clang
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

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
	openssh-server \
	ripgrep \
	fd-find \
	fzf \
	python3 \
	python3-pip \
	python3-venv \
	nodejs \
	npm \
	golang-go \
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

RUN mkdir -p /run/sshd /root/.ssh /etc/ssh/sshd_config.d && \
	chmod 700 /root/.ssh && \
	printf "PermitRootLogin yes\nPasswordAuthentication yes\nPubkeyAuthentication yes\n" > /etc/ssh/sshd_config.d/debian-dev.conf

# 源码构建 Neovim
RUN git clone --depth 1 --branch "${NVIM_VERSION}" https://github.com/neovim/neovim.git /tmp/neovim && \
	cd /tmp/neovim && \
	make CMAKE_BUILD_TYPE=Release && \
	make install && \
	cd / && \
	rm -rf /tmp/neovim

# 源码构建 LuaLS
RUN git clone --depth 1 https://github.com/LuaLS/lua-language-server /opt/lua-language-server && \
	cd /opt/lua-language-server && \
	bash ./make.sh && \
	ln -sf /opt/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server && \
	find /opt/lua-language-server -name .git -exec rm -rf {} +

# 安装 rustup + Rust nightly
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
	sh -s -- -y --default-toolchain nightly --profile default && \
	/root/.cargo/bin/rustup component add rust-src rustfmt clippy rust-analyzer

RUN /root/.cargo/bin/cargo install neocmakelsp && \
	/root/.cargo/bin/cargo install stylua && \
	/root/.cargo/bin/cargo install --locked zellij && \
	/root/.cargo/bin/cargo install --force yazi-build && \
	rm -rf /root/.cargo/registry /root/.cargo/git

# clone nvim 配置
RUN mkdir -p /root/.config && git clone "${NVIM_CONFIG_REPO}" /root/.config/nvim;

RUN npm install -g tree-sitter-cli \
	dockerfile-language-server-nodejs \
	gh-actions-language-server \
	oxfmt && \
	npm cache clean --force

RUN GOBIN=/usr/local/bin go install github.com/owenrumney/make-ls/cmd/make-ls@latest && \
	rm -rf /root/go/pkg/mod /root/.cache/go-build

# vim.pack 非交互安装插件
RUN nvim --headless \
	"+lua vim.pack.update(nil, { force = true })" \
	"+qa"

# clone fish 配置
COPY fish /root/.config/fish
COPY clangd /root/.config/clangd
COPY zellij /root/.config/zellij
COPY entrypoint.sh /usr/local/bin/entrypoint

RUN chmod +x /usr/local/bin/entrypoint

EXPOSE 22

WORKDIR /work

ENTRYPOINT ["/usr/local/bin/entrypoint"]
