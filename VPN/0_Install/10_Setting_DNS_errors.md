# ⚡ Возможна ошибка `ifdown: unknown interface ens1` и правильная работа с Netplan

> \[!IMPORTANT]
> Данная ошибка возникает, когда вы пытаетесь перезапустить сетевой интерфейс через `ifup/ifdown`,
> но интерфейс не прописан в конфигурационных файлах **/etc/network/interfaces** или **/etc/network/interfaces.d/**.
> Утилиты `ifup` и `ifdown` работают только с интерфейсами, описанными в этих конфиг-файлах.
>
> ⚠️ Если вы используете **Netplan**, как основной механизм управления сетью, лучше использовать только `netplan generate` и `netplan apply`.

---

## 🔍 Симптомы

```bash
sudo ifdown --force ens1 && sudo ifup ens1
ifdown: unknown interface ens1
```

При этом интерфейс виден в системе:

```bash
ip -c -br a
lo               UNKNOWN        127.0.0.1/8
ens1             UP             45.211.246.16/24
```

---

## 🔧 Решение

### 1. Проверка конфигов ifupdown (временный костыль)

```bash
grep -R ens1 /etc/network/interfaces*
```

Если вывода нет — интерфейс не прописан. Можно добавить временно:

```bash
nano /etc/network/interfaces
```

```ini
auto ens1
iface ens1 inet static
    address 45.211.246.16
    netmask 255.255.255.0
    gateway 45.211.246.1
    dns-nameservers 94.140.14.14 94.140.15.15
```

> \[!TIP]
> Только если нужно временно поднять интерфейс. В дальнейшем основной механизм — Netplan.

---

### 2. Поднятие интерфейса через Netplan (рекомендуется)

```bash
sudo netplan generate
sudo netplan apply
```

Проверяем:

```bash
ip -c -br a show ens1
ip route
resolvectl status | grep 'DNS Servers' -A2
ping -c 4 8.8.8.8
```

> \[!TIP]
> После `netplan apply` IP, маршруты и DNS будут корректно применены согласно конфигу `/etc/netplan/*.yaml`.

---

### 3. Временное ручное поднятие интерфейса без ifupdown

Если нужно поднять интерфейс «на лету», можно сделать так:

```bash
sudo ip link set ens1 up
sudo ip addr flush dev ens1
sudo ip addr add 45.211.246.16/24 dev ens1
sudo ip route add default via 45.211.246.1
```

> ⚠️ Эти изменения **не сохраняются после перезагрузки**. Для постоянной конфигурации используйте Netplan.

---

## ⚠️ Возможные предупреждения

### Warning: LLMNR

При запуске может появляться:

```
Setting LLMNR support level "yes" for "2", but the global support level is "no".
```

* Это не ошибка.
* Лишнее предупреждение systemd-resolved о том, что глобально отключён протокол **LLMNR** (локальный мультикаст резолв имён).
* На работу сети и VPN не влияет.

---

## ✅ Итог

* `ifup/ifdown` → временный костыль, только для проверки или ручного поднятия интерфейса.
* Постоянное управление сетью — через **Netplan** (`netplan generate/apply`).
* Ручные изменения через `ip addr/route` — безопасная альтернатива, если не трогать конфиг Netplan.


# 📌 Как убрать лишний DNS (например, `1.1.1.1`) в Ubuntu/Debian с Netplan + systemd-resolved

При настройке сетей через **Netplan + systemd-resolved** может внезапно появляться лишний DNS (например, `1.1.1.1`), даже если он не указан ни в `/etc/netplan/*.yaml`, ни в `/etc/systemd/resolved.conf`.

Это происходит из-за:

* 🗂️ старых **DHCP lease**, сохранённых systemd-networkd/NetworkManager;
* 🌀 конфигов cloud-init или `*.network` файлов systemd, где подхватывается DNS.

---

## 🔍 Шаг 1. Проверить текущие DNS

```bash
resolvectl status | grep 'DNS Servers' -A2
```

Если видите что-то вроде:

```
DNS Servers: 30.50.90.50
Fallback DNS Servers: 94.140.14.14 94.140.15.15

Link 2 (eth0)
       DNS Servers: 1.1.1.1   👈 Лишний
```

— значит, проблема именно в lease или в `.network`-файлах.

---

## 🗑️ Шаг 2. Удалить старые DHCP lease

```bash
rm -f /var/lib/systemd/network/*.lease
rm -f /var/lib/NetworkManager/*lease
```

---

## 🔄 Шаг 3. Перезапустить сетевые сервисы

```bash
systemctl restart systemd-networkd
systemctl restart systemd-resolved
```

---

## 📝 Шаг 4. Проверить результат

```bash
resolvectl status | grep 'DNS Servers' -A2
```

Теперь должен остаться только ваш DNS (например, `94.140.15.15` и `94.140.14.14`).

---

## 🛡️ Шаг 5. Если `1.1.1.1` всё ещё появляется

Создаём drop-in для systemd-networkd:

```bash
nano /etc/systemd/network/10-eth0.network
```

Прописываем строго свои DNS:

```ini
[Match]
Name=eth0

[Network]
DNS=94.140.15.15
DNS=94.140.14.14
Domains=~.
```

Применяем изменения:

```bash
systemctl restart systemd-networkd systemd-resolved
```

---

## ✅ Итог

После этих шагов `resolvectl status` будет показывать только те DNS, что вы задали вручную. Никакого Cloudflare `1.1.1.1` ✨

---


