ARG FEDORA_VERSION=44
ARG DEV_USER=dev

FROM local/dev-fedora:${FEDORA_VERSION}

ARG DEV_USER=dev

RUN dnf -y install \
      Thunar \
      adwaita-icon-theme \
      dbus-x11 \
      dejavu-sans-fonts \
      mesa-dri-drivers \
      mesa-libEGL \
      mesa-libGL \
      tigervnc-server \
      novnc \
      websockify \
      xterm \
      xfce4-panel \
      xfce4-session \
      xfce4-settings \
      xfconf \
      xfdesktop \
      xfwm4 \
      xorg-x11-server-Xvfb && \
    dnf clean all

RUN mkdir -p "/home/${DEV_USER}/.vnc" && \
    chown -R "${DEV_USER}:${DEV_USER}" "/home/${DEV_USER}/.vnc"
