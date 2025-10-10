# 🛡️ Настройка DNS-over-TLS на Ubuntu Server (AdGuard + Cloudflare + Google)

> \[!IMPORTANT]
> В данном примере настраиваем конфиг DNS на самом сервере DNS <br> 
> На котором у нас развёрнут AdGuard

Надёжная и безопасная конфигурация DNS через `systemd-resolved` с использованием **шифрованных DNS-запросов (DoT)** и отключением DHCP/Cloud-init вмешательства.

---

## 📑 Содержание

- [Описание](#описание)
- [1️⃣ Проверка текущего состояния](#проверка-текущего-состояния)
- [2️⃣ Настройка статического IP](#настройка-статического-ip)
- [3️⃣ Отключение Cloud-init вмешательства](#отключение-cloud-init-вмешательства)
- [4️⃣ Настройка systemd-resolved](#настройка-systemd-resolved)
- [5️⃣ Перезапуск и проверка DNS](#перезапуск-и-проверка-dns)
- [6️⃣ Проверка DNS-over-TLS](#проверка-dns-over-tls)
- [✅ Итоги](#итоги)

---

## 📘 Описание <a id="описание"></a>

Цель — создать надёжную, полностью **локально управляемую DNS-конфигурацию** без DHCP-переопределений.  
Сервер будет использовать:
- 🔹 **AdGuard DNS** как основные (через DoT)  
- 🔹 **Cloudflare и Google DNS** как резервные  
- 🔒 **DNSSEC** и **DNS-over-TLS** для безопасного разрешения имён  

---

## 1️⃣ Проверка текущего состояния <a id="проверка-текущего-состояния"></a>

Посмотрим интерфейсы и активные DNS:

```bash
ip -c -br a
ip route
resolvectl status
````

Пример вывода:

```
lo               UNKNOWN        127.0.0.1/8
eth0             UP             192.168.10.52/24
default via 192.168.10.1 dev eth0 proto dhcp src 192.168.10.52
DNS Servers: 1.1.1.1
Fallback DNS Servers: 8.8.8.8
```

---

## 2️⃣ Настройка статического IP <a id="настройка-статического-ip"></a>

Переходим в каталог с конфигами интерфейсов:

```bash
cd /etc/network/interfaces.d
```

Редактируем (или создаём) файл `eth0`:

```bash
nano /etc/network/interfaces.d/eth0
```

Пример конфигурации:

```ini
auto eth0
iface eth0 inet static
    address 192.168.10.52
    netmask 255.255.255.0
    gateway 192.168.10.1
```

---

## 3️⃣ Отключение Cloud-init вмешательства <a id="отключение-cloud-init-вмешательства"></a>

Cloud-init часто перезаписывает сетевые настройки. Чтобы этого избежать:

```bash
nano /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
```

Вставляем:

```yaml
network: {config: disabled}
```

Удаляем сетевые шаблоны Cloud-init:

```bash
rm -rf /etc/netplan
rm -rf /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
rm -rf /var/lib/cloud/sem/* /var/lib/cloud/instance /var/lib/cloud/instances/*
```

Перезапускаем службы:

```bash
systemctl restart cloud-init
systemctl restart networking
systemctl restart systemd-resolved
```

> Если появится ошибка при `networking.service`, можно просто перезагрузить сервер.

---

## 4️⃣ Настройка systemd-resolved <a id="настройка-systemd-resolved"></a>

Редактируем конфиг:

```bash
nano /etc/systemd/resolved.conf
```

> ⚠️ Не добавляйте в DNS собственный IP (во избежание зацикливания).

Полный пример:

```ini
[Resolve]
# Основные внешние DNS через DoT (AdGuard)
DNS=94.140.14.14#dns.adguard.com
DNS=94.140.15.15#dns.adguard.com

# Резервные (Cloudflare + Google DoT)
FallbackDNS=1.1.1.1#cloudflare-dns.com
FallbackDNS=8.8.8.8#dns.google

# Включить DNS over TLS
DNSOverTLS=yes

# DNSSEC при возможности
DNSSEC=allow-downgrade

# Разрешить кэш
Cache=yes

# Не использовать MulticastDNS/LLMNR
MulticastDNS=no
LLMNR=no
```

Сохраняем и применяем:

```bash
systemctl restart systemd-resolved
resolvectl flush-caches
```

---

## 5️⃣ Перезапуск и проверка DNS <a id="перезапуск-и-проверка-dns"></a>

Перезагружаем сервер:

```bash
reboot
```

После загрузки проверяем состояние:

```bash
resolvectl status
```

Пример результата:

```
Global
         DNS Servers: 94.140.14.14#dns.adguard.com 94.140.15.15#dns.adguard.com
Fallback DNS Servers: 1.1.1.1#cloudflare-dns.com 8.8.8.8#dns.google
DNSSEC=allow-downgrade/supported
DNSOverTLS=yes
```

---

## 6️⃣ Проверка DNS-over-TLS <a id="проверка-dns-over-tls"></a>

Проверим запрос:

```bash
resolvectl query google.com
```

Ожидаемый результат:

```
google.com: 142.250.74.238 -- link: eth0

-- Information acquired via protocol DNS in 1.2150s.
-- Data was acquired via local or encrypted transport: yes
```

Если в строке указано `encrypted transport: yes` —
🎉 значит **DNS-over-TLS работает корректно**!

---

## ✅ Итоги <a id="итоги"></a>

После выполнения всех шагов вы получили:

| Компонент  | Статус                                 |
| ---------- | -------------------------------------- |
| Cloud-init | 🚫 Отключён                            |
| DHCP       | 🚫 Не используется                     |
| Сеть       | ⚙️ Статическая                         |
| DNS        | 🔒 AdGuard + Cloudflare + Google (DoT) |
| DNSSEC     | ✅ Активен                              |
| Шифрование | ✅ DNS-over-TLS включен                 |

