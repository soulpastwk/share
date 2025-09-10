# Настройка DNS с фильтрацией рекламы и трекеров на сервере VPN 🌐

Инструкция для быстрого развертывания безопасного DNS с поддержкой **DoT (DNS-over-TLS)** и фильтрацией рекламы через **AdGuard**, **Quad9** или собственный сервер.  

---

## Что мы тут реализуем - покажем наглядно

```text
                       ┌─────────────────────────────┐
                       │        Клиент VPN           │
                       │   (смартфон / ПК)           │
                       │                             │
                       │  Основной трафик:           │
                       │  instagram.com  ✅         │
                       │  Фоновые сервисы:           │
                       │  mail.ru, yandex.ru ❌     │
                       └─────────────┬──────────────┘
                                     │
                                     │ 🔒 VPN-туннель
                                     ▼
                       ┌─────────────────────────────┐
                       │        VPN сервер           │
                       │  Маршрутизация доменов:     │
                       │  - .ru, .рф, .su → ❌       │
                       │  - остальные → ✅ direct    │
                       │  DNS: 38.41.145.108         │
                       └───────┬─────────────┬───────┘
                               │             │
                               │             │
           Основной запрос: instagram.com  Фоновые запросы: mail.ru, yandex.ru
                               │             │
                               ▼             ▼
                         ✅ Пропущено      ❌ Заблокировано
                          (direct)         (blackhole)
                               │
                               ▼
                       ┌─────────────────────────────┐
                       │         DNS сервер          │
                       │   (AdGuard / Pi-hole)       │
                       │ - Фильтрация рекламы        │
                       │ - Безопасный резолвинг      │
                       │ - Разрешает только ✅      │
                       └─────────────────────────────┘

````
### Как это работает на практике:

1. **Instagram.com**

   * Не попадает под правило блокировки `.ru`.
   * VPN сервер пропускает запрос через `direct`.
   * DNS сервер резолвит имя и возвращает IP клиенту.

2. **Mail.ru и другие `.ru` сервисы**

   * Попадают под правило блокировки доменов `.ru`.
   * VPN сервер не пускает запрос дальше, отсылает на `blackhole`.
   * Клиент не получает IP и соединение не устанавливается.

3. **Фоновые сервисы на клиенте**

   * Любые попытки обращения к `.ru` доменам будут блокироваться автоматически через VPN сервер.
   * Весь остальной трафик (например, Instagram.com, Google.com) работает как обычно через VPN.
> [!IMPORTANT]
> ⚠️ Если у вас есть собственный DNS (AdGuard, Pi-hole), замените IP на ваш сервер.

---
📝 Шаг 1: Настройка systemd-resolved

Файл конфигурации: `/etc/systemd/resolved.conf`

### Пример с публичными DNS:

```ini
[Resolve]
# Основной DNS через AdGuard
DNS=94.140.14.14#dns.adguard.com
DNS=94.140.15.15#dns.adguard.com

# Резервный DNS (Quad9)
FallbackDNS=9.9.9.9#dns.quad9.net

# Настройки безопасности и кэширования
DNSOverTLS=yes
DNSSEC=allow-downgrade
Cache=yes
MulticastDNS=no
LLMNR=no
````

## 🚀 Шаг 2: Применение новых настроек

```bash
sudo systemctl restart systemd-resolved
sudo resolvectl flush-caches
resolvectl status
```

Пример вывода:

```
Global
   Protocols: -LLMNR -mDNS +DNSOverTLS DNSSEC=allow-downgrade
   DNS Servers: 94.140.14.14#dns.adguard.com
   Fallback DNS Servers: 9.9.9.9#dns.quad9.net
```

✅ **Global DNS Servers** — основной DNS 

✅ **Fallback DNS Servers** — резервные 

✅ **Link X (eth0)** — DNS для конкретного интерфейса 

---

## 🔍 Шаг 3: Проверка работы DNS

### 3.1 Через `resolvectl`

```bash
resolvectl query example.com
```

### 3.2 Через `dig` / `kdig`

#### Установка пакетов:

```bash
sudo apt update
sudo apt install dnsutils -y       # dig
sudo apt install knot-dnsutils -y  # kdig ✅
```

#### Проверка резолвинга:

```bash
dig +short @94.140.14.14 example.com
kdig @94.140.14.14 example.com ✅
```

#### Проверка блокировки рекламы (AdGuard DNS):

```bash
dig +short @94.140.14.14 doubleclick.net
# NXDOMAIN -> реклама блокируется
```

---

## 🌐 Шаг 4: Настройка сетевого интерфейса с несколькими DNS

Файл: `/etc/network/interfaces.d/eth0`

```ini
auto eth0
iface eth0 inet static
    address 91.153.107.13
    netmask 255.255.255.0
    gateway 91.153.107.1
    dns-nameservers 38.41.145.108 9.9.9.9 94.140.14.14
```

Перезапуск интерфейса:

```bash
sudo ifdown --force eth0 && sudo ifup eth0
resolvectl status
```

> Пояснение:
>
> * Первый DNS — основной
> * Остальные — резервные
> * Порядок важен

---

## 🔧 Шаг 5: Работа с `ifdown` и `ifup`

* `ifdown` — отключает интерфейс
* `ifup` — включает интерфейс с новыми настройками

Если команды отсутствуют:

```bash
sudo apt update
sudo apt install ifupdown -y
```

---

## ⚡ Шаг 6: Альтернатива через systemd

Для систем с `systemd-networkd`:

```bash
sudo systemctl restart systemd-networkd
```

Эквивалент `ifdown/ifup` для современных систем.

---

## ✅ Шаг 7: Настройка в Web-панели 3X-UI

📸 📸 Включаем как на скриншотах ниже:

![sc-06](https://github.com/soulpastwk/share/blob/main/media/vpn00/scr-03.png)

![sc-06](https://github.com/soulpastwk/share/blob/main/media/vpn00/scr-04.png)

И прописываем либо свой DNS / либо общие самого AdGuard и так же добавляем остальные резервные IP

`94.140.14.14`
`94.140.15.15`
`9.9.9.9`

## ✅ Шаг 8: Дополнительно полезные команды

* Проверка IP адресов: `ip -c -br a`
* Проверка маршрутизации: `ping 8.8.8.8`
* Установка net-tools для старых команд (`ifconfig`, `route`):

```bash
sudo apt install net-tools -y
```

* `resolvectl` и `systemd-resolved` — управление DNS
* `dig` / `kdig` — тестирование резолвинга

---

## 📌 Итог

Теперь сервер:

* Использует безопасный DNS через **DoT**
* Поддерживает **DNSSEC**
* Блокирует рекламу и трекеры через AdGuard/Quad9
* Работает с несколькими DNS (основной + резервные)
* Подходит для VPN и серверов с публичным доступом

---

💡 Рекомендация: для фильтрации рекламы используйте AdGuard DNS первым, резервные Quad9 и/или AdGuard вторым.
💡 А для максимальной фильтрации и управлением - свой DNS сервер (разворачивается на отдельном сервере от VPN).
