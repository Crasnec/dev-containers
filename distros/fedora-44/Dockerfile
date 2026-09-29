ARG TUNNEL_CLIENT_VERSION=v0.0.9--context-conduit-topaz

FROM golang:1.26.2 AS tunnel-client-builder
ARG TUNNEL_CLIENT_VERSION
RUN git clone --depth 1 --branch "$TUNNEL_CLIENT_VERSION" https://github.com/openai/tunnel-client.git /src/tunnel-client && \
    cd /src/tunnel-client && \
    CGO_ENABLED=0 go build -trimpath -o /out/tunnel-client ./cmd/client && \
    /out/tunnel-client --version

FROM fedora:44

ARG DEV_USER=dev
ARG DEV_UID=1000
ARG DEV_GID=1000
ARG CODEX_NPM_VERSION
ARG TUNNEL_CLIENT_VERSION

RUN dnf -y update && \
    dnf -y install \
      bash \
      sudo \
      git \
      curl \
      wget \
      ca-certificates \
      openssh-server \
      openssh-clients \
      vim-enhanced \
      neovim \
      less \
      tmux \
      htop \
      procps-ng \
      findutils \
      which \
      file \
      tar \
      unzip \
      zip \
      gzip \
      xz \
      jq \
      ripgrep \
      fd-find \
      gcc \
      gcc-c++ \
      make \
      cmake \
      ninja-build \
      pkgconf-pkg-config \
      openssl-devel \
      zlib-devel \
      bzip2-devel \
      xz-devel \
      sqlite-devel \
      readline-devel \
      libffi-devel \
      python3 \
      python3-pip \
      python3-virtualenv \
      nodejs \
      npm \
      rust \
      cargo \
      docker-cli \
      docker-compose \
      gh \
      opam \
      m4 \
      bubblewrap \
      patch \
      rsync \
      diffutils \
      gmp-devel \
      nspr \
      nss \
      at-spi2-atk \
      libXcomposite \
      libXdamage \
      libXrandr \
      mesa-libgbm \
      alsa-lib \
      pango \
      cups-libs \
      libXfixes \
      webkit2gtk4.1-devel \
      libappindicator-gtk3-devel \
      librsvg2-devel \
      libxdo-devel \
      llvm \
      lld \
      clang \
      libreoffice-impress \
      libreoffice-calc \
      poppler-utils \
      tesseract \
      tesseract-langpack-eng \
      tesseract-langpack-kor \
      systemd \
      systemd-udev && \
    dnf clean all

COPY --from=tunnel-client-builder /out/tunnel-client /usr/local/bin/tunnel-client
RUN tunnel-client --version

RUN groupadd --gid "$DEV_GID" "$DEV_USER" && \
    useradd --uid "$DEV_UID" --gid "$DEV_GID" --create-home --shell /bin/bash "$DEV_USER" && \
    printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$DEV_USER" >/etc/sudoers.d/90-dev-user && \
    chmod 0440 /etc/sudoers.d/90-dev-user && \
    mkdir -p \
      "/home/$DEV_USER/.ssh" \
      "/home/$DEV_USER/.cache/pip" \
      "/home/$DEV_USER/.cargo" \
      "/home/$DEV_USER/.npm" \
      "/home/$DEV_USER/.local/bin" \
      "/home/$DEV_USER/.local/lib/node_modules" && \
    printf 'prefix=%s\n' "/home/$DEV_USER/.local" > "/home/$DEV_USER/.npmrc" && \
    chown -R "$DEV_UID:$DEV_GID" "/home/$DEV_USER" && \
    chmod 700 "/home/$DEV_USER/.ssh"

# Keep the image-provided Codex and all later self-updates in one user-owned location.
RUN test -n "$CODEX_NPM_VERSION" && \
    sudo -u "$DEV_USER" env \
      HOME="/home/$DEV_USER" \
      NPM_CONFIG_PREFIX="/home/$DEV_USER/.local" \
      PATH="/home/$DEV_USER/.local/bin:$PATH" \
      npm install -g "@openai/codex@$CODEX_NPM_VERSION" && \
    "/home/$DEV_USER/.local/bin/codex" --version

COPY distros/fedora-44/sshd_config /etc/ssh/sshd_config
COPY distros/fedora-44/entrypoint.sh /usr/local/sbin/dev-container-entrypoint
COPY distros/fedora-44/dev-container-entrypoint.service /etc/systemd/system/dev-container-entrypoint.service

RUN chmod 0755 /usr/local/sbin/dev-container-entrypoint && \
    systemctl enable sshd.service dev-container-entrypoint.service && \
    systemctl mask getty@tty1.service docker.service docker.socket

ENV PATH="/home/${DEV_USER}/.local/bin:/opt/dev-bin:/home/${DEV_USER}/.cache/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV DEV_USER="${DEV_USER}"
ENV DEV_HOME="/home/${DEV_USER}"
ENV GOPATH="/home/${DEV_USER}/.cache/go"
ENV NPM_CONFIG_PREFIX="/home/${DEV_USER}/.local"
ENV TUNNEL_CLIENT_VERSION="${TUNNEL_CLIENT_VERSION}"

STOPSIGNAL SIGRTMIN+3
