#!/bin/bash
set -euo pipefail

gen_username() {
	# shellcheck disable=SC2018
	tr -dc 'a-z' </dev/urandom | head -c 8
}

gen_password() {
	tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32
}

prp_pass() {
	echo -e "$1\n$1"
}

srq1_password=$(gen_password)
srq2_username=$(gen_username)
srq2_password=$(gen_password)
srq2_ssh_pubkey="${1:?Usage: $0 <public_key>}"

prp_pass "$srq1_password" | passwd

useradd -m -G sudo -s /bin/bash "$srq2_username"
prp_pass "$srq2_password" | passwd "$srq2_username"

srq2_homedir=$(eval echo "~$srq2_username")
srq2_ssh_conf="$srq2_homedir/.ssh"
srq2_ssh_keys="$srq2_ssh_conf/authorized_keys"

install -d -m 700 -o "$srq2_username" -g "$srq2_username" "$srq2_ssh_conf"
touch "$srq2_ssh_keys"
chown "$srq2_username:$srq2_username" "$srq2_ssh_keys"
chmod 600 "$srq2_ssh_keys"

if ! grep -qxF "$srq2_ssh_pubkey" "$srq2_ssh_keys"; then
	printf "%s\n" "$srq2_ssh_pubkey" >>"$srq2_ssh_keys"
fi

sshd_config="/etc/ssh/sshd_config.d/hardened.conf"
sshd_port=$((((RANDOM << 15) | RANDOM) % 63001 + 2000))

cat <<EOF >"$sshd_config"
Port $sshd_port

AllowUsers $srq2_username
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
PubkeyAuthentication yes

X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2

LogLevel VERBOSE
EOF
sshd -t && systemctl restart ssh

public_ip=$(curl -s 'https://checkip.amazonaws.com')

echo "Credentials:"
echo "root $srq1_password"
echo "$srq2_username $srq2_password"
echo "Connection:"
echo "ssh $srq2_username@$public_ip -p $sshd_port"
