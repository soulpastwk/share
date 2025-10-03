# 👤 Управление пользователями и группами в Linux

[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey?style=flat-square&logo=linux)]()
[![Category](https://img.shields.io/badge/category-User%20Management-blue?style=flat-square)]()
[![Tested on](https://img.shields.io/badge/tested%20on-Astra%20SE%201.7.5%20|%20Astra%20SE%201.8%20|%20RED%20OS%207.3-orange?style=flat-square)]()

> [!TIP]  
> Эти команды универсальны для большинства дистрибутивов Linux. Различия могут быть только в путях конфигурационных файлов или менеджерах пакетов (Astra Linux / РЕД ОС).

---

## ⚡ 1. Основная информация о пользователях и группах

### Список пользователей
```bash
cat /etc/passwd
````

* Каждый пользователь описан строкой:

```
user:x:UID:GID:comment:home:shell
```

* `UID 0` — root
* `UID 1000+` — обычные пользователи

### Список групп

```bash
cat /etc/group
```

* Формат:

```
group_name:x:GID:user1,user2
```

### Проверить текущего пользователя

```bash
whoami
id
```

* `whoami` — имя пользователя
* `id` — UID, GID и группы пользователя

---

## 🛠 2. Создание пользователей

### Простое создание пользователя

```bash
sudo adduser user1
```

* Создает домашнюю директорию `/home/user1`
* Настраивает пароль, шелл, базовые группы

### Создание пользователя без домашнего каталога

```bash
sudo adduser --no-create-home user2
```

### Создание пользователя с конкретным UID и GID

```bash
sudo adduser --uid 1500 --gid 1001 user3
```

### Добавление комментариев

```bash
sudo adduser --comment "Developer" devuser
```

---

## 🔑 3. Установка и изменение пароля

```bash
sudo passwd user1         # установить пароль
sudo passwd -l user1      # заблокировать учетную запись
sudo passwd -u user1      # разблокировать
```

> [!IMPORTANT]
> Пароль root лучше оставить заблокированным для SSH-доступа и использовать sudo у обычных пользователей.

---

## 👑 4. Предоставление прав root через sudo

### Добавление пользователя в группу `sudo` или `wheel`

```bash
sudo usermod -aG sudo user1    # Debian / Astra
sudo usermod -aG wheel user1   # RHEL / RED OS
```

### Проверка прав sudo

```bash
sudo -l -U user1
```

> [!TIP]
> Группа `sudo` или `wheel` управляет доступом через `/etc/sudoers`. Для редактирования:

```bash
sudo visudo
```

---

## 🔐 5. Отключение встроенного root

```bash
sudo passwd -l root       # блокировка пароля root
sudo usermod -L root      # альтернативная блокировка
```

* root всё ещё существует, но нельзя войти напрямую через пароль.
* Используем `sudo` у обычных пользователей для административных задач.

---

## 🧩 6. Создание групп и управление доступом

### Создание группы

```bash
sudo groupadd sshusers
sudo groupadd developers
```

### Добавление пользователя в группу

```bash
sudo usermod -aG sshusers user1
sudo usermod -aG developers devuser
```

### Проверка группы пользователя

```bash
groups user1
id user1
```

---

## 🖥 7. Ограничение SSH-доступа

### Разрешить вход только определённым пользователям/группам

1. Открыть конфигурацию SSH:

```bash
sudo nano /etc/ssh/sshd_config
```

2. Добавить:

```
AllowGroups sshusers
AllowUsers devuser user1
```

3. Перезапустить SSH:

```bash
sudo systemctl restart ssh
```

> [!IMPORTANT]
> Если указать `AllowGroups` или `AllowUsers`, убедитесь, что хотя бы один администратор имеет доступ, иначе вы заблокируете SSH.

---

## ⚙️ 8. Удаление пользователей и групп

### Удаление пользователя, оставив домашний каталог

```bash
sudo deluser user1
```

### Удаление пользователя с домашним каталогом

```bash
sudo deluser --remove-home user1
```

### Удаление группы

```bash
sudo groupdel sshusers
```

---

## 🔍 9. Просмотр сессий и активности пользователей

### Список текущих пользователей

```bash
who
w
```

### История входов

```bash
last
lastlog
```

### Проверка процессов пользователя

```bash
ps -u user1
```

---

## 🧾 10. Практические рекомендации

> [!TIP]
>
> * Используйте группы для управления доступом к ресурсам.
> * Не предоставляйте root-доступ напрямую через SSH.
> * Логи входа и sudo находятся в `/var/log/auth.log` (Debian/Astra) или `/var/log/secure` (RED OS).

> [!IMPORTANT]
> Перед массовым удалением пользователей или групп проверяйте активные процессы и домашние директории.

---

## 🔗 Полезные ссылки

* [man adduser](https://linux.die.net/man/8/adduser)
* [man usermod](https://linux.die.net/man/8/usermod)
* [man passwd](https://linux.die.net/man/1/passwd)
* [man deluser](https://linux.die.net/man/8/deluser)
* [man groupadd](https://linux.die.net/man/8/groupadd)
* [man visudo](https://linux.die.net/man/8/visudo)
* [man sshd_config](https://man.openbsd.org/sshd_config)
