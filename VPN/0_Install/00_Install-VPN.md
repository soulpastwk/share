# 🛡️ Свой VPN-сервер ( Ubuntu 24 + 3X-UI )

[![OS Linux](https://img.shields.io/badge/OS-Linux-blue?logo=linux&logoColor=white)](https://www.linux.org/)
[![OpenSSL](https://img.shields.io/badge/OpenSSL-%E2%9C%94-green?logo=openssl&logoColor=white)](https://www.openssl.org/)
[![Xray](https://img.shields.io/badge/Xray-Ready-orange?logo=github)](https://github.com/XTLS/Xray-core)
[![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)

====== ↑ ↑ ↑ Кликабельные штуки ↑ ↑ ↑ ======
> [!IMPORTANT]
> Этот проект предназначен только для **личного использования**.  
> ⚠️ **Дисклеймер** ⚠️  
> Данный материал создан *исключительно в образовательных целях*.  
> Автор не несёт ответственности за возможные последствия использования.  
> Применяйте только в рамках законного тестирования и легальных задач.
>
> ---
>
> ## 📜 ДИСКЛЕЙМЕР / ПРАВОВОЕ ПРЕДУПРЕЖДЕНИЕ
>
> Все материалы, представленные в данном репозитории и сопровождающих инструкциях, предназначены **исключительно в образовательных целях** и раскрывают техническую сторону развертывания частного (белого) VPN-сервера.  
> Информация предназначена исключительно для законного применения, включая:
>
> - 🔑 безопасный удалённый доступ к собственным ресурсам (например, файлы, NAS, серверы);  
> - ⚡ ускорение соединения с легальными зарубежными сайтами и сервисами (например, облачные хранилища, рабочие CRM-системы);  
> - 📥 обновление программного обеспечения для оборудования и устройств, поставляемых из-за рубежа;  
> - 🛡️ обеспечение конфиденциальности и цифровой гигиены при подключении через общедоступные сети;  
> - 🎓 доступ к корпоративным и учебным ресурсам, не подпадающим под блокировки.  
>
> ### ⚖️ Законность и ответственность
> - Использование VPN-технологий в РФ **не запрещено**, однако доступ к ресурсам, заблокированным по решению Роскомнадзора (в том числе признанным экстремистскими), может рассматриваться как нарушение законодательства.  
> - Сам факт установки и использования VPN не является правонарушением, но использование в противоправных целях (например, для распространения запрещённого контента, экстремизма, клеветы, дискредитации и т.д.) может повлечь административную или уголовную ответственность.  
> - Автор **не распространяет информацию о способах обхода блокировок**, не призывает к нарушению закона и не рекламирует VPN-сервисы.  
> - Ответственность за соблюдение законодательства страны, в которой используется информация из инструкции, целиком и полностью ложится на пользователя.  
> - Если вы **не согласны с этими условиями**, либо намерены использовать материалы в целях, противоречащих законодательству РФ, — немедленно покиньте страницу и прекратите использование инструкции.  
>
> ### 🚫 Категорически запрещено использовать материалы:
> - для обхода блокировок доступа к экстремистским и иным запрещённым ресурсам;  
> - для анонимного доступа к деструктивному, пиратскому, фейковому или вредоносному контенту;  
> - для призывов к незаконной деятельности, митингам, киберпреступлениям и прочим противоправным действиям;  
> - для распространения инструкций или ссылок, подпадающих под действующее законодательство РФ о противодействии экстремизму и дезинформации.  
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

| Провайдер | Характеристики | Трафик | Цена |
|-----------|----------------|--------|:----:|
| [hshp.host](https://hshp.host/) | 1 CPU / 2 ГБ RAM / 30 ГБ NVMe / 500 Мбит канал | 🟩 **Безлимит** | **300 ₽** |
| [hostkey.ru](https://hostkey.ru/) | VPS / 1 vCPU / 1 ГБ RAM / 15 ГБ SSD / 500 Мбит канал | 🟨 **3 ТБ/мес** | **255 ₽** |
|           | VPS / 2 vCPU / 2 ГБ RAM / 30 ГБ SSD / 500 Мбит канал | 🟨 **3 ТБ/мес** | **350 ₽** |
| [cloudzy.com](https://cloudzy.com/) | VPS Европа (Мощности ниже, но хватает) | 🟧 **1 ТБ/мес** | ~**7,5 💲** <br>(+1 💲 комиссия при оплате криптой) |
| [cloudzy.com](https://cloudzy.com/) | VPS Америка (Мощности ниже, но хватает) | 🟧 **1 ТБ/мес** | ~**5,5 💲** <br>(+1 💲 комиссия при оплате криптой) |
| [hostvds.com](https://hostvds.com/) | 1 CPU / 2 GB RAM / 20 GB NVMe / 1 Gbit/s | 🟧 **1 ТБ/мес** | **1.99 💲** <br>(можно платить СБП) |
| [hostvds.com](https://hostvds.com/) | 2 CPU / 4 GB RAM / 40 GB NVMe / 10 Gbit/s | 🟨 **2 ТБ/мес** | **3.99 💲** <br>(можно платить СБП) |

Буду признателен если зарегистрируетесь по моей ссылке 
https://hostvds.com/?affiliate_uuid=92b0d8b4-f87f-4753-bb6a-c17f915c40da 

---

### 🔌 Тарифные планы сети только для hostvds.com (опция безлимита) + к стоимости сервера

| План | Трафик | Пропускная способность | Цена за доп. 1 TB | Цена за месяц |
|------|--------|------------------------|------------------|---------------|
| **Limited 10 Gbps** | 2 TB | 10 Gbit/s | **1 💲** | **FREE** |
| **Unlimited Shared 100 Mbps** | ∞ | 100 Mbit/s | FREE | **0.49 💲** / мес|
| **Unlimited Shared 1 Gbps** | ∞ | 1 Gbit/s | FREE | **0.99 💲** / мес|
| **Unlimited Shared 10 Gbps** | ∞ | 10 Gbit/s | FREE | **1.99 💲** / мес|


---
# 🛡 Инструкция по установке и защите VPN-сервера
---

## 🔄 1. Обновление системы и установка базовых пакетов

```bash
apt update && apt upgrade -y && apt dist-upgrade -y
apt install -y nano mc htop lsof iperf3 curl dos2unix openssl systemd fail2ban nftables
```
  
⚠️ nftables - ставим только, если выбрали провайдера hostvds.com - у них по умолчанию нет этой службы

⚠️ iperf3 - можно не ставить, если не планируете создавать каскадный VPN из двух серверов

**Для чего нужны пакеты:**

* **nano/mc** – удобные редактор и файловый менеджер.
* **htop/lsof** – мониторинг процессов и сетевых соединений.
* **iperf3** – проверка скорости соединения.
* **curl** – скачивание установочных скриптов.
* **dos2unix** – исправление формата строк в скриптах.
* **openssl** – генерация сертификатов.
* **systemd** – управление сервисами.
* **fail2ban** - защита сервера от перебора паролей.
* **nftables** - управление фаерволом, сетевыми правилами

<p align="center"><strong>============================================================================== </strong></p>
<p align="center"><strong>📸 По итогу должно получиться что-то такое - результат первого блока команд: </strong></p>
<p align="center"><strong>============================================================================== </strong></p>

![sc-01](https://github.com/soulpastwk/share/blob/main/media/vpn00/sc-00-01.png)

<p align="center"><strong>============================================================================== </strong></p>
<p align="center"><strong>📸 И не пугаемся карасного текста при установке пакета fial2ban </strong></p>
<p align="center"><strong>============================================================================== </strong></p>

![sc-01-02](https://github.com/soulpastwk/share/blob/main/media/vpn00/sc-00-02.png)

Это не ошибка, а **предупреждения** (`SyntaxWarning`) от Python.

Они связаны с тем, что в тестовых файлах `fail2ban` (папка `/usr/lib/python3/dist-packages/fail2ban/tests/...`) используются строковые литералы с "неправильными" escape-последовательностями, например `"\s"` или `"\d"`.

В современном Python это надо писать либо как `r"\s"` (raw-строка), либо `\\s`. Но эти файлы относятся к **unit-тестам**, которые в продакшене никак не задействуются.

## 🚀 2. Установка и настройка 3X-UI

Устанавливаем 3X-UI с панелью и самоподписанными сертификатами на 10 лет:

```bash
curl -fsSL -o ~/00_Сert_VPN_stable_version.sh https://raw.githubusercontent.com/soulpastwk/share/main/VPN/0_Install/00_Сert_VPN_stable_version.sh \
&& dos2unix ~/00_Сert_VPN_stable_version.sh 2>/dev/null || true \
&& chmod +x ~/00_Сert_VPN_stable_version.sh \
&& bash ~/00_Сert_VPN_stable_version.sh
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
Запомните/запишите их — они нужны для настройки фаервола в будущем.

<p align="center"><strong>============================================================================== </strong></p>
<p align="center"><strong>📸 По итогу должно получиться что-то такое - результат второго блока команд: </strong></p>
<p align="center"><strong>============================================================================== </strong></p>

При установке появится вопрос:

> **Would you like to customize the Panel Port settings? (If not, a random port will be applied) [y/n]**

- Если нажать **`n`** → порт будет выбран автоматически (рекомендуется).  
- Если нажать **`y`** → можно задать свой порт, но его всегда можно изменить позже в панели управления.

<p align="center"><strong>============================================================================== </strong></p>

![sc-02](https://github.com/soulpastwk/share/blob/main/media/vpn00/sc-02.png)
<p align="center"><strong>============================================================================== </strong></p>

Скрипт продолжит работу где у нас спросят под что мы будем маскироваться выбираем: 

- Только Google - для обычного VPN .  
- Yandex - для каскадного VPN.

Так же спросит каким методом будем шифровать...

<p align="center"><strong>============================================================================== </strong></p>

![sc-03](https://github.com/soulpastwk/share/blob/main/media/vpn00/sc-03.png)
<p align="center"><strong>============================================================================== </strong></p>

## 🔑 Авторизация в панели

1. Переходим в браузере по ссылке, указанной в терминале (**лучше в режиме инкогнито**).  
2. Вводим логин/пароль (из терминала).  
3. Указываем пути сертификатов, которые выводились в терминале.
<p align="center"><strong>============================================================================== </strong></p>   
<p align="center"><strong>📸 Скриншот: </strong></p>
<p align="center"><strong>============================================================================== </strong></p>

![sc-04-1](https://github.com/soulpastwk/share/blob/main/media/vpn00/sc-04-01.png)

4. Не забываем СОХРАНИТЬ и "Перезапустить панель"
5. Делаем данные манипуляции при любом изменении !

## 🔒 Установка сертификатов

После установки сертификатов:  
- Перезагрузите страницу или заново откройте браузер.  
- Адрес изменится с `http://` на `https://`.  
- Браузер может предупредить, что сертификат недействителен — **это нормально** ✅  

## 🔐 Настройка безопасности

После установки сертификатов:  
- можно изменить **логин/пароль панели**,  
- а также путь и порт доступа.  

![sc-04-2](https://github.com/soulpastwk/share/blob/main/media/vpn00/sc-04-02.png)

## ⚡ Создание VLESS соединения

Для подключения с разных устройств создаём **VLESS соединение**.

### 🔑 Важные параметры:
- **Порт IP:** `443`  
- **Dest:** `google.com:443`  
- **SNI:** `google.com,www.google.com` *(можно оставить yahoo.com)*  
- **Sniffing:** включен ✅  

<p align="center"><strong>============================================================================== </strong></p>   
<p align="center"><strong>📸 Скриншоты настроенного подключения: </strong></p>
<p align="center"><strong>============================================================================== </strong></p>

![sc-05](https://github.com/soulpastwk/share/blob/main/media/vpn00/sc-05.png)


### ⚠️ Обратите внимание
У клиента возможность выбрать из списка тип поодключения - Flow - как на скриншоте ниже, появится только после того, как вы в создании подключения нажмёте на переключатель **Reality** 
Потом возвращаемся выше на Клиента - разворачиваем его, задаём имя и выбираем из списка - как на скриншоте ниже: 

![sc-06](https://github.com/soulpastwk/share/blob/main/media/vpn00/sc-06.png)

## 📱 Подключение устройств

После создания соединения:  
- Скачайте приложение для своей ОС.  
- Импортируйте конфигурацию через **QR-код** или **буфер обмена**.  

📸 Пример конфигурации: 
 
![sc-06](https://github.com/soulpastwk/share/blob/main/media/vpn00/sc-07.png)

## 📥 Клиенты для разных ОС

| <div align="center"><img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/android/android-original.svg" width="48"/><br>**Android**</div> | <div align="center"><img src="https://github.com/soulpastwk/share/blob/main/media/vpn00/icons8-ос-mac-100.png?raw=true" width="48"/><br>**iOS**</div> | <div align="center"><img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/windows8/windows8-original.svg" width="48"/><br>**Windows**</div> | <div align="center"><img src="https://github.com/soulpastwk/share/blob/main/media/vpn00/icons8-ос-mac-100.png?raw=true" width="48"/><br>**macOS**</div> | <div align="center"><img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/linux/linux-original.svg" width="48"/><br>**Linux**</div> |
|-------------|---------|-------------|-----------|-----------|
| [v2rayNG](https://github.com/2dust/v2rayNG) | Streisand | [Furious](https://github.com/LorenEteval/Furious) | V2Box | [Nekoray](https://github.com/MatsuriDayo/nekoray/) |
| [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid) | FoXray | [InvisibleMan-XRayClient](https://github.com/InvisibleManVPN/InvisibleMan-XRayClient) | FoXray | *(отдельная инструкция позже)* |
| [v2RayTun](https://play.google.com/store/apps/details?id=com.v2raytun.android&hl=ru) | Shadowrocket | [Nekoray](https://github.com/MatsuriDayo/nekoray/) | Streisand | Работает **50/50** |
| - | V2Box - V2Ray Client | - | V2RayXS | - |
| - | v2RayTun | - | [NekoRay/NekoBox for macOS](https://github.com/abbasnaqdi/nekoray-macos) | - |
| - | - | - | Furious | - |


## 🔗 Прямые ссылки на загрузку

- **Android:**  
  - [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases)  
  - [V2RayNG](https://play.google.com/store/apps/details?id=com.v2ray.ang)  

- **Windows / Linux:**  
  - [Nekoray](https://github.com/Matsuridayo/nekoray/releases)  

- **iOS (App Store):**  
  - [V2Box - V2ray Client](https://apps.apple.com/ru/app/v2box-v2ray-client/id6446814690)  

- **Android TV / Google TV:**  
  - [v2rayNG (релиз)](https://github.com/2dust/v2rayNG/releases/tag/1.8.38)  

---

✅ Теперь панель установлена, сертификаты подключены, а **VLESS-соединение готово к использованию**!

# Перед дальнейшими действиями ПРОВЕРЬТЕ, что подключение работает на ПК/Телефоне/Ноутбуке 
## ⚠️ Не забывайте делать бэкап файла, который изменяете. ⚠️

# Рекомендую настроить безопасность ОС

## 🔒 3. Настройка SSH

Изменяем конфигурацию:

```bash
nano /etc/ssh/sshd_config
```

Пример:

```ini
Port 60022        # выбираем нестандартный порт (60000–65000)
Banner none
PrintMotd no
DebianBanner no
PasswordAuthentication no    # Этот параметр включаем ТОЛЬКО если у вас настроены ssh КЛЮЧИ

```

Перезапуск:

```bash
systemctl restart ssh
```

*Зачем:* уменьшает вероятность атак на SSH. (Иногда нужен reboot сервера)

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

### 📖 Расшифровка параметров

* **enabled = true** — включает защиту для этого сервиса.
* **filter = sshd** — указывает, какой фильтр (шаблон поиска в логах) использовать.
* **action = nftables\[name=SSH, port=ssh, protocol=tcp]** — при срабатывании бана добавляется правило в `nftables`, закрывающее доступ к порту SSH.
* **logpath = %(syslog\_authpriv)s** — путь до логов (в Ubuntu 24.04 через systemd-journald маппится автоматически).
* **findtime = 600** — за какой период (в секундах, здесь 10 минут) учитываются попытки входа.
* **maxretry = 2** — сколько ошибок допускается прежде чем IP будет забанен.
* **bantime = -1** — время бана: `-1` значит **пожизненно** (IP останется в бане, пока админ вручную не снимет).
* **backend = systemd** — Fail2Ban получает логи напрямую через systemd-journald (правильно для Ubuntu 24).

---

⚠️ **Важно:** в самих конфиг-файлах (`jail.local`) комментарии внутри секции **писать нельзя** — Fail2Ban не примет такой файл и сервис не запустится.
Если нужны пояснения — лучше оставлять их в отдельной документации или в начале файла **перед секциями**.

Запуск:

```bash
systemctl enable fail2ban
systemctl restart fail2ban
```
#### Просмотр статуса Fail2Ban
Общий статус:
```bash
sudo fail2ban-client status
```

Статус конкретного jail (например, `sshd`):
```bash
sudo fail2ban-client status sshd
```

#### Разблокировка IP-адреса
Чтобы разблокировать определенный IP-адрес:
```bash
sudo fail2ban-client set sshd unbanip 192.168.1.100
```
---

## 🔥 5. Настройка фаервола (nftables)

⚠️ Перед настройкой обязательно проверьте **порт SSH** и **порты, которые использует 3X-UI** для Веб-ки и 443 (или 8433 если каскадный VPN)

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

## ⚡ 6. Оптимизация логов (безопаснее в оперативке)

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

Открыть конфиг на редактирование:

   ```bash
   sudo nano /etc/systemd/journald.conf
   ```

Сохранить и перезапустить службу:

   ```bash
   sudo systemctl restart systemd-journald
   ```
---

⚡ Проверить, где сейчас хранятся логи:

```bash
journalctl --disk-usage
```

👉 Если `Storage=volatile` — логи будут в `/run/log/journal/` (RAM).
👉 Если `Storage=persistent` — в `/var/log/journal/`.

---

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
---

## 🔒 Дополнительная защита ICMP

Чтобы усложнить сетевые сканирования и защитить сервер:

```bash
# Добавляем параметры в /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf

# Применяем изменения
sysctl -p
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

## ⚠️ ТАК ЖЕ ВАЖНО: обновление пакета `sudo`

Рекомендуется обновить пакет **sudo** до последней версии.

Инструкция доступна так же в моём репозитории по ссылке: 
## 👉 [Обновление sudo](https://github.com/soulpastwk/share/blob/main/VPN/0_Install/01_Update_Sudo.md)

### ❗ Причина

В версиях **sudo до 1.9.17p2** обнаружена критическая уязвимость (**CVE-2025-32463**):

* Любой непривилегированный пользователь может выполнить код с правами **root**,
* Даже если пользователь **не упомянут в sudoers**.

Обновление обязательно для безопасной работы сервера перед дальнейшей настройкой.

---

✅ Теперь сервер:

* Обновлён и защищён,
* Работает с **3X-UI панелью и сертификатами**,
* С надёжным **фаерволом (nftables)**,
* С оптимизированными логами,
* С отключённым IPv6 (чтобы избежать утечек).

---

