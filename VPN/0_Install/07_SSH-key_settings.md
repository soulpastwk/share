# 🔑 Использование SSH-ключей вместо пароля

[![Linux](https://img.shields.io/badge/OS-Linux-blue?logo=linux\&logoColor=white)](https://www.linux.org/)
[![OpenSSH](https://img.shields.io/badge/OpenSSH-%E2%9C%94-green?logo=gnubash\&logoColor=white)](https://www.openssh.com/)
[![Security](https://img.shields.io/badge/Security-Keys-red?style=flat-square)](https://wiki.archlinux.org/title/SSH_keys)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Windows-lightgrey?style=flat-square\&logo=linux)
![Tested](https://img.shields.io/badge/tested%20on-Ubuntu%2024.04%20%7C%20Debian%2012-orange?style=flat-square)
[![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)

---

> \[!IMPORTANT]
> Использование SSH-ключей — это **обязательная практика безопасности**.
> ✅ Ключи надёжнее и удобнее паролей.
> 🚫 Никогда не передавайте приватный ключ третьим лицам.
> 🔒 Всегда храните копию приватного ключа в надёжном месте.

---

## 📂 Содержание

* 🛠 [Генерация ключей](#-генерация-ключей)
* 📥 [Загрузка открытого ключа на сервер](#-загрузка-открытого-ключа-на-сервер)
* ⚙️ [Настройка SSH-сервера](#️-настройка-ssh-сервера)
* 💻 [Подключение с клиента](#-подключение-с-клиента)
* 🌐 [Добавление ключа при заказе сервера](#-добавление-ключа-при-заказе-сервера)

---

## 🛠 Генерация ключей

Открываем **MobaXterm** → меню **Tools → MobaKeyGen**.

![Генерация SSH-ключа](https://github.com/soulpastwk/share/raw/main/media/vpn00/ssh-00.png)

Жмём **Generate** и двигаем мышкой в окне для генерации случайности:

![Процесс генерации](https://github.com/soulpastwk/share/raw/main/media/vpn00/ssh-01.png)

После генерации:

* вводим комментарий (например: `my-server-key`)
* задаём парольную фразу (рекомендуется)
* сохраняем **публичный ключ** (например `id_rsa.pub`)
* сохраняем **приватный ключ** (`id_rsa`)

> \[!TIP]
> Cоветую обзывать одинаково и публичному ключу можно добавить расширение .pub для удобства, у приватного расширение не меняем, а оставляем как есть

![Сохранение ключей](https://github.com/soulpastwk/share/raw/main/media/vpn00/ssh-02.png)

> \[!TIP]
> Рекомендую сразу скопировать весь открытый ключ в буфер обмена или блокнот.

---

## 📥 Загрузка открытого ключа на сервер

Подключаемся к серверу по паролю и создаём директорию если её нет `.ssh` (по умолчанию путь такой /root/.ssh)

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

В этой директории создаём (или редактируем) файл **authorized\_keys**:

```bash
nano ~/.ssh/authorized_keys
```

Вставляем туда **открытый ключ** (одной строкой!):

![authorized\_keys](https://github.com/soulpastwk/share/raw/main/media/vpn00/ssh-03.png)

**На скриншоте вывод команды cat сам перенёс на несколько строк, т.к. он не вмещается**

Далее:

```bash
chmod 600 ~/.ssh/authorized_keys
```

---

## ⚙️ Настройка SSH-сервера

Редактируем конфиг:

```bash
nano /etc/ssh/sshd_config
```

Поэтапно (в некоторых случаях необходимо перезагрузить сам сервер):

1. Разрешаем вход по ключам:

```ini
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

2. Проверяем, что вход по паролю включён (на случай ошибки):

```ini
PasswordAuthentication yes
```

3. Перезапускаем SSH:

```bash
systemctl restart ssh
```

4. Тестируем вход с ключом. Если всё работает — отключаем пароли:

```ini
PasswordAuthentication no
PermitRootLogin prohibit-password
```

5. Ещё раз перезапускаем SSH:

```bash
systemctl restart ssh
```

---

## 💻 Подключение с клиента

В свойствах сессии MobaXterm указываем путь к приватному ключу:

![Клиент: добавление ключа](https://github.com/soulpastwk/share/raw/main/media/vpn00/ssh-04.png)

При первом входе запросит **парольную фразу**, далее будет подключать автоматически.

---

## 🌐 Добавление ключа при заказе сервера

Многие провайдеры позволяют добавить ключ **сразу при создании сервера**.
Просто вставьте туда **открытый ключ** (`.pub`).

Примеры:

![Добавление ключа 1](https://github.com/soulpastwk/share/raw/main/media/vpn00/ssh-05.png)
![Добавление ключа 2](https://github.com/soulpastwk/share/raw/main/media/vpn00/ssh-06.png)
![Добавление ключа 3](https://github.com/soulpastwk/share/raw/main/media/vpn00/ssh-07.png)

---

## ✅ Итог

Теперь подключение по SSH к серверу выполняется **без пароля**, а только с использованием приватного ключа.
Это повышает безопасность и защищает сервер от атак перебором паролей.
