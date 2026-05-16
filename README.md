# Quick VPS Setup

## Requirements

### Update system

```bash
apt-get update -y && apt-get dist-upgrade -y
```

### Instal software

```bash
apt-get install -y nano curl ufw
```

## Setup SSH

### Generate pubkey on host

```bash
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub | wl-copy -n
```

### Configure server

```bash
bash <(curl -Ls https://raw.githubusercontent.com/yotlich/vps-starter/main/scripts/ssh-starter.sh)
```

> Save given credentials

## Setup UFW

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow $(grep Port /etc/ssh/sshd_config.d/hardened.conf | awk '{print $2}')/tcp
ufw enable
```

> Reconnect with saved credentials
