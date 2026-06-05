#!/usr/bin/env bash
set -euo pipefail

mkdir -p /run/sshd /root/.ssh
chmod 700 /root/.ssh

if [[ -n "${SSH_AUTHORIZED_KEYS:-}" ]]; then
	printf '%s\n' "${SSH_AUTHORIZED_KEYS}" > /root/.ssh/authorized_keys
	chmod 600 /root/.ssh/authorized_keys
fi

if [[ -n "${SSH_ROOT_PASSWORD:-}" ]]; then
	echo "root:${SSH_ROOT_PASSWORD}" | chpasswd
fi

ssh-keygen -A >/dev/null
/usr/sbin/sshd

if [[ "$#" -gt 0 ]]; then
	exec "$@"
fi

if [[ -t 0 ]]; then
	exec fish
fi

exec sleep infinity
