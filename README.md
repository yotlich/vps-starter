# Quick VPS Setup

## Requirements

Debian LTS

### Update system

```bash
apt-get update -y && apt-get dist-upgrade -y
```

### Instal software

```bash
apt-get install -y nano curl ufw
```

> Reboot VPS

## Setup SSH

### Generate pubkey on host

```bash
ssh-keygen -t ed25519
```

### Copy pubkey on host

```bash
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
ufw allow "$(sudo sshd -T | grep '^port' | awk '{print $2}')/tcp"
ufw enable

```

## Check rules

```bash
ufw status verbose
```

> Reconnect with saved credentials
