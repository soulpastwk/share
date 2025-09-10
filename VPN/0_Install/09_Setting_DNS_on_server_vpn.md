## 🖥 Настройка статического IP и DNS на сервере с Netplan 

> \[!IMPORTANT]
> ## ⚠️ ВНИМАНИЕ !!!
> ДАННЫЙ ПРИМЕР НАСТРОЙКИ ОСОБЕННО АКТУАЛЕН ДЛЯ ПРОВАЙДЕРА - hostkey.ru  
> И везде где сетью управляет **Netplan**.

> \[!TIP]
> Данные настройки выполняем на своём сервере VPN. <br>
> Если у вас каскадный VPN - то на обоих серверах. <br>
> Также не забываем прописывать DNS в веб-панелях **3X-UI**. <br>
> По веб-ке тут - https://github.com/soulpastwk/share/blob/main/VPN/0_Install/04_Setiings_DNS_web_3X-UI.md 
---

## 🔧 Настройка интерфейса на Ubuntu:

```bash
root@server-vpn-1:/etc/netplan# ls -lah
total 20K
drwxr-xr-x  2 root root 4.0K Sep 10 14:02 .
drwxr-xr-x 89 root root 4.0K Aug 29 12:41 ..
-rw-------  1 root root  360 Sep 10 13:58 01-netcfg.yaml
-rw-r--r--  1 root root  196 Sep 10 13:52 01-netcfg.yaml_backup
-rw-------  1 root root  389 Jun  6  2024 50-cloud-init.yaml.bak
````

В директории `/etc/netplan`.

---

## 💾 Коммитим и бэкапим

* Коммитим файл `50-cloud-init.yaml` путём переименовывания в `50-cloud-init.yaml.bak`
* Делаем бэкап `01-netcfg.yaml`
* Настраиваем `01-netcfg.yaml` на статику - ниже пример готового конфига <br>
  меняем только на ваш ip и личный dns прописываем

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens1:
      addresses:
        - 1.148.104.218/24 # ip вашего сервера
      routes:
        - to: default
          via: 1.148.104.1 
      nameservers:
        addresses:
          - 30.47.43.44     # Личный развёрнутый на VPS у провайдера DNS-сервер (AdGuard Home)
          - 94.140.14.14    # AdGuard DNS (резервный адрес официальный AdGuard)
```

---

## ⚠️ Возможные предупреждения

### Warning 1: Permissions

Если возникнут ошибки вида:

```
⚠️ Warning 1: Permissions for /etc/netplan/01-netcfg.yaml are too open
```

Это значит, что права доступа к файлу слишком "широкие".
Netplan требует, чтобы доступ был только у root.

👉 Исправляем:

```bash
sudo chmod 600 /etc/netplan/01-netcfg.yaml
```

### Warning 2: gateway4 deprecated

```
⚠️ Warning 2: gateway4 has been deprecated
```

В новых версиях netplan `gateway4` и `gateway6` заменили на `routes:`. <br>
Так что если у вас прописаны `gateway4` или `gateway6`, меняйте на `routes` как в примере конфига выше.

---

## ⚙️ Cloud-init

Сервера под управлением cloud-init (типично для VPS) генерируют свой сетевой конфиг (`50-cloud-init.yaml`). <br>
Даже если прописать ручной статический IP в `01-netcfg.yaml`, после ребута cloud-init может всё перезаписать.

Поэтому создаём:

```bash
sudo nano /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
```

С содержимым в одну строчку:

```yaml
network: {config: disabled}
```

Перезапуск интерфейса:

```bash
sudo ifdown --force ens1 && sudo ifup ens1
resolvectl status
```
---

## 🛠 Настройка systemd-resolved

Вставляем в `/etc/systemd/resolved.conf` следующий конфиг:

```ini
[Resolve]
# Основной DNS через DoT (ниже пишем и ваш айпишник и через знак # пишем доменное имя вашего ДНС - это синтаксис DoT)
DNS=30.47.43.44#vash-domen-dns.ru

# Резервный (Adguard DoT) (на случай отказа вашего сервера у провайдера)
FallbackDNS=94.140.14.14#dns.adguard.com
FallbackDNS=94.140.15.15#dns.adguard.com

# Включить DoT
DNSOverTLS=yes

# Использовать DNSSEC, если доступно
DNSSEC=allow-downgrade

# Кэширование
Cache=yes

# Отключаем лишние протоколы
MulticastDNS=no
LLMNR=no
```

---

## 🚀 Применяем конфиг

```bash
netplan generate
netplan apply
systemctl restart systemd-resolved
```

---

## ✅ Проверка работы DNS

Проверяем, что из резолверов пропали `1.1.1.1` и `8.8.8.8`, и остались только наши конфиги:

```bash
ip -c -br a
ip route
resolvectl status | grep 'DNS Servers' -A2
```

В выводе должны быть только ваши IP-адреса и ничего более.

#### 🛠 Установка пакетов для проверки работы DNS:

```bash
apt update
apt install dnsutils -y       # dig
apt install knot-dnsutils -y  # kdig ✅
```

#### Проверка резолвинга:

```bash
dig +short @94.140.14.14 google.com
kdig @94.140.14.14 google.com ✅
```

#### Проверка блокировки рекламы (AdGuard DNS):

```bash
dig +short @94.140.14.14 doubleclick.net
# NXDOMAIN -> реклама блокируется
или 0.0.0.0 -> реклама блокируется
```

