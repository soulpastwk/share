# 🛡️ Свой VPN-сервер ( Ubuntu 24 + 3X-UI )

[![OS Linux](https://img.shields.io/badge/OS-Linux-blue?logo=linux&logoColor=white)](https://www.linux.org/)
[![OpenSSL](https://img.shields.io/badge/OpenSSL-%E2%9C%94-green?logo=openssl&logoColor=white)](https://www.openssl.org/)
[![Xray](https://img.shields.io/badge/Xray-Ready-orange?logo=github)](https://github.com/XTLS/Xray-core)
[![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)

## 🔑 Рекомендуемая логика настройки

1. Обновляем систему и ставим базовые утилиты.
2. Устанавливаем **3X-UI + сертификаты** (получаем веб-порт панели и порты сервисов).
3. Настраиваем **SSH** (смена порта, отключение лишнего).
4. Настраиваем **Fail2Ban** (с учётом уже известных портов).
5. Настраиваем фаервол (**nftables**) под эти порты.
6. Оптимизируем логи (**systemd-journal**, Fail2Ban) и параметры **ICMP/sysctl**.
7. Чистим систему: убираем старые ядра и при необходимости отключаем **IPv6**.

---

## 🌍 Рекомендованные провайдеры VPS

* [hshp.host](https://hshp.host/) — отличная цена за ресурсы сервера (**Рекомендуется**).
* [hostkey.ru](https://hostkey.ru/) — немного дороже и ресурсов меньше, чем у предыдущего провайдера.
* [cloudzy.com](https://cloudzy.com/) — возможность платить криптой, но цена выше (\~7,5 \💲). Чисто зарубежный сервис.
* Европа — (~7,5 💲) — Америка (~5,5 💲) — это у [cloudzy.com](https://cloudzy.com/)

---

---
# 🛡 Инструкция по установке и защите VPN-сервера
---

## 🔄 1. Обновление системы и установка базовых пакетов

```bash
apt update && apt upgrade -y && apt dist-upgrade -y
apt install -y nano mc htop lsof iperf3 curl dos2unix openssl systemd
```

**Для чего нужны пакеты:**

* **nano/mc** – удобные редактор и файловый менеджер,
* **htop/lsof** – мониторинг процессов и сетевых соединений,
* **iperf3** – проверка скорости соединения,
* **curl** – скачивание установочных скриптов,
* **dos2unix** – исправление формата строк в скриптах,
* **openssl** – генерация сертификатов,
* **systemd** – управление сервисами.

⚠️ iperf3 - можно не ставить, если не планируете создавать каскадный VPN из двух серверов

---

## 🚀 2. Установка и настройка 3X-UI

Устанавливаем 3X-UI с панелью и самоподписанными сертификатами на 10 лет:

```bash
rm -f ~/cert-vetal-gis.sh \
&& curl -fsSL -o ~/cert-vetal-gis.sh https://raw.githubusercontent.com/soulpastwk/share/main/VPN/cert-vetal-gis.sh \
&& dos2unix ~/cert-vetal-gis.sh 2>/dev/null || true \
&& chmod +x ~/cert-vetal-gis.sh \
&& bash ~/cert-vetal-gis.sh
```

### Что делает скрипт:

1. Проверяет наличие `openssl` и `x-ui`.
2. Устанавливает **3X-UI**.
3. Создаёт самоподписанный сертификат с маскировкой под выбранный сервис (Google, Yandex, и др.).
  * (Yandex - для серверов в России / Google - для всех остальных)
  * Сервер в России понадобится нам только для каскадного VPN, который описан отдельно будет.
5. Включает автозапуск панели.
6. Показывает **логин, пароль и порт панели (случайный)**.

⚠️ **Важно:** порты веб-панели и сервисов становятся известны только после установки.
Запомните их — они нужны для настройки фаервола.

---

## 🔒 3. Настройка SSH

Изменяем конфигурацию:

```bash
nano /etc/ssh/sshd_config
```

Пример:

```ini
Port 60022        # выбираем нестандартный порт (60000–65000)
PermitRootLogin no
PasswordAuthentication no   # при использовании ключей
Banner none
PrintMotd no
DebianBanner no
```

Перезапуск:

```bash
systemctl restart ssh
```

*Зачем:* уменьшает вероятность атак на SSH.

---

## 🛡 4. Настройка Fail2Ban

Создаём конфиг:

```bash
nano /etc/fail2ban/jail.local
```

Пример для SSH:

```ini
[sshd]
enabled = true
filter = sshd
action = nftables[name=SSH, port=ssh, protocol=tcp]
logpath = %(syslog_authpriv)s
findtime = 600
maxretry = 2
bantime = -1
backend = systemd
```

Запуск:

```bash
systemctl enable fail2ban
systemctl restart fail2ban
```

---

## 🔥 5. Настройка фаервола (nftables)

⚠️ Перед настройкой обязательно узнайте **порт SSH** и **порты, которые использует 3X-UI** (из шага 2).

Файл `/etc/nftables.conf`:

```nft
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0;
        policy drop;

        # Loopback
        iif lo accept

        # Уже установленные соединения
        ct state established,related accept

        # SSH (укажите свой порт)
        tcp dport 60022 accept

        # Порты панели 3X-UI (замените на реальные)
        tcp dport 8443 accept
        tcp dport 60555 accept

        # Пример: iperf3 только с определенного IP
        ip saddr 192.168.1.1 tcp dport 5201 accept

        # ICMP блокируем
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
```

Применяем:

```bash
systemctl enable nftables
systemctl restart nftables
nft list ruleset
```

---

## ⚡ 6. Оптимизация логов

### 📌 Вариант 1: хранение в RAM

```ini
[Journal]
Storage=volatile
RuntimeMaxUse=50M
SystemMaxUse=0
```

* Логи очищаются при перезагрузке.
* Fail2Ban: при перезагрузке «история» атак обнуляется. Это не критично для большинства случаев, т.к. после старта новые атаки снова будут блокироваться.
* Логи будут храниться только в /run/log/journal/ (в оперативной памяти).
* После перезагрузки все записи очищаются.

---

### 📌 Вариант 2: хранение на диске

```ini
[Journal]
Storage=persistent
SystemMaxUse=500M
RuntimeMaxUse=50M
```

* Логи будут храниться в привычном месте /var/log/journal/ и сохраняться после перезагрузки.
* Fail2Ban: сможет анализировать длительную историю атак, а не только с момента старта системы.
* Минус: больше нагрузки на диск (особенно SSD/VPS с ограниченным ресурсом), но не критично.

---

## 🌐 7. Отключение IPv6 и защита от ICMP

### Почему отключаем IPv6?

* Многие VPN используют только IPv4.
* Если IPv6 оставить включённым, возможны **утечки реального IP через DNS или прямые соединения**, что может «выдать» вас.

Отключение:

```bash
echo "GRUB_CMDLINE_LINUX=\"ipv6.disable=1\"" | tee -a /etc/default/grub
update-grub
reboot
```

### Доп. защита ICMP

В `/etc/sysctl.conf` добавляем три строки:

```conf
net.ipv4.icmp_echo_ignore_all = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
```

## 📊 Объяснение параметров

```
ICMP пакеты
├── Echo Request (ping)
│   └─ net.ipv4.icmp_echo_ignore_all = 1  ✅ игнорируются все ping-запросы
├── Broadcast Echo Request (ping на широковещательный адрес)
│   └─ net.ipv4.icmp_echo_ignore_broadcasts = 1  ✅ защита от Smurf-атак
└── Подозрительные ICMP ошибки (bogus/error)
    └─ net.ipv4.icmp_ignore_bogus_error_responses = 1  ✅ игнор некорректных или потенциально опасных ICMP-пакетов
```

### 🔹 Пояснения

* `icmp_echo_ignore_all` → закрывает только обычные ping-запросы.
* `icmp_echo_ignore_broadcasts` → отдельно защищает от широковещательных ping (Smurf).
* `icmp_ignore_bogus_error_responses` → блокирует нестандартные/подозрительные ICMP сообщения.

⚠️ **Вывод:** для полной защиты сервера от ICMP-сканирования и атак нужно использовать **все три параметра вместе**.

---

### 1️⃣ `net.ipv4.icmp_echo_ignore_all = 1`

* Полностью **игнорирует все ICMP echo-запросы** (`ping`).
* Сервер **не отвечает на `ping`** ни от кого.
* **Влияет только на ICMP типа Echo Request**.

---

### 2️⃣ `net.ipv4.icmp_echo_ignore_broadcasts = 1`

* Игнорирует **ping на broadcast-адреса** (например, 192.168.1.255).
* Защищает от **Smurf-атак** (когда злоумышленник шлёт ping на широковещательный адрес, чтобы нагрузить сеть).
* **Не дублирует `icmp_echo_ignore_all`**, т.к. broadcast может обрабатываться отдельно, особенно если `icmp_echo_ignore_all` отключен (`0`).

---

### 3️⃣ `net.ipv4.icmp_ignore_bogus_error_responses = 1`

* Игнорирует **подозрительные ICMP ошибки**, которые могут использоваться для атак или сканирования.
* Примеры: ICMP Destination Unreachable с некорректным содержимым, ICMP Redirect, ICMP Parameter Problem.
* **Не относится к Echo Request**, поэтому не дублирует первое правило.

---

## 🗑 8. Очистка старых ядер

```bash
apt purge $(dpkg --list | grep linux-image | awk '{print $2}' | grep -v $(uname -r))
apt autoremove --purge -y
```
* **Удаляем старые ядра
---

✅ Теперь сервер:

* Обновлён и защищён,
* Работает с **3X-UI панелью и сертификатами**,
* С надёжным **фаерволом (nftables)**,
* С оптимизированными логами,
* С отключённым IPv6 (чтобы избежать утечек).

---

