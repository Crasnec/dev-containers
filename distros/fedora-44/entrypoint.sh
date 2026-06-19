#!/usr/bin/env bash
set -euo pipefail

DEV_USER="${DEV_USER:-dev}"
DEV_HOME="${DEV_HOME:-/home/$DEV_USER}"

install -d -o "$DEV_USER" -g "$DEV_USER" -m 700 "$DEV_HOME/.ssh"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 700 "$DEV_HOME/.cache"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 700 "$DEV_HOME/.cache/pip"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 700 "$DEV_HOME/.cargo"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 755 /workspace

if [[ -S /var/run/docker.sock ]]; then
  sock_gid="$(stat -c '%g' /var/run/docker.sock)"
  if ! getent group "$sock_gid" >/dev/null; then
    groupadd --gid "$sock_gid" host-docker
  fi
  sock_group="$(getent group "$sock_gid" | cut -d: -f1)"
  usermod -aG "$sock_group" "$DEV_USER"
fi

ssh-keygen -A
chown -R "$DEV_USER:$DEV_USER" "$DEV_HOME/.cache" "$DEV_HOME/.cargo"
chmod 700 "$DEV_HOME/.ssh"
find "$DEV_HOME/.ssh" -maxdepth 1 -type f -name 'id_*' -exec chmod 600 {} \; 2>/dev/null || true
chmod 600 "$DEV_HOME/.ssh/authorized_keys" 2>/dev/null || true
chmod 644 "$DEV_HOME/.ssh/known_hosts" 2>/dev/null || true

if [[ -s /opt/dev-secrets/container-password ]]; then
  password="$(< /opt/dev-secrets/container-password)"
  printf '%s:%s\n' "$DEV_USER" "$password" | chpasswd
fi
