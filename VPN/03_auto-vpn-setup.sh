```bash
#!/bin/bash

# Автоматизация установки OpenSSL, 3X-UI, Fail2Ban и базовой безопасности

set -e

echo "Обновление системы и установка базовых пакетов..."
apt update && apt upgrade -y
apt install -y nano mc htop lsof iperf3 curl dos2unix openssl systemd fail2ban nftables

echo "Скачивание и запуск скрипта установки 3X-UI..."
curl -fsSL -o ~/cert-vetal-gis.sh https://raw.githubusercontent.com/soulpastwk/share/main/VPN/cert-vetal-gis.sh
dos2unix ~/cert-vetal-gis.sh
chmod +x ~/cert-vetal-gis.sh
bash ~/cert-vetal-gis.sh

echo "Настройка SSH (перевод на нестандартный порт)..."
sed -i 's/^#Port 22/Port 60022/' /etc/ssh/sshd_config
systemctl restart ssh

echo "Настройка Fail2Ban для SSH..."
cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
filter = sshd
action = nftables[name=SSH, port=60022, protocol=tcp]
logpath = %(syslog_authpriv)s
findtime = 600
maxretry = 2
bantime = -1
backend = systemd
EOF

echo "Добавление фильтра и jail для 3X-UI..."
cat <<'EOF' > /etc/fail2ban/filter.d/3x-ui.conf
[Definition]
failregex = ^.*Failed login attempt.*username.*from <HOST>.*
ignoreregex =
EOF

cat <<EOF >> /etc/fail2ban/jail.local

[3x-ui]
enabled = true
filter = 3x-ui
action = nftables[name=3XUI, port=60000, protocol=tcp]
logpath = /etc/x-ui/x-ui.log
findtime = 600
maxretry = 3
bantime = 86400
backend = auto
EOF

systemctl enable fail2ban
systemctl restart fail2ban

echo "Настройка базового nftables..."
cat <<EOF > /etc/nftables.conf
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0;
        policy drop;

        iif lo accept
        ct state established,related accept

        tcp dport 60022 accept
        tcp dport 8443 accept

        icmp drop
    }
    chain forward {
        type filter hook forward priority 0;
        policy drop;
    }
    chain output {
        type filter hook output priority 0;
        policy accept;
    }
}
EOF

systemctl enable nftables
systemctl restart nftables

echo "Отключение IPv6..."
echo "GRUB_CMDLINE_LINUX=\"ipv6.disable=1\"" | tee -a /etc/default/grub
update-grub

echo "Защита ICMP..."
cat <<EOF >> /etc/sysctl.conf
net.ipv4.icmp_echo_ignore_all = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
EOF
sysctl -p

echo "Готово! Перезагрузите сервер для применения всех настроек."

```
