# ⏱ Временные метки файлов в Linux: atime, mtime, ctime

[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey?style=flat-square&logo=linux)]()
[![Category](https://img.shields.io/badge/category-File%20Management-blue?style=flat-square)]()

Файлы в Linux имеют **три основные временные метки**:  

- **Access time (atime)** — время последнего доступа к файлу  
- **Modification time (mtime)** — время последнего изменения содержимого файла  
- **Change time (ctime)** — время изменения атрибутов файла (права, владелец, перемещение)  

> [!TIP]  
> Важно понимать, что **ctime ≠ создание файла**, а отражает изменение метаданных. В Linux нет стандартного поля "creation time" для большинства файловых систем (ext4 поддерживает `birth time` через `stat`).

---

## ⚡ 1. Просмотр временных меток файлов

### Используя `stat`
```bash
stat file.txt
````

Пример вывода:

```
  File: file.txt
  Size: 123          Blocks: 8          IO Block: 4096   regular file
Device: 802h/2050d   Inode: 123456      Links: 1
Access: 2025-10-02 10:30:15.123456789 +0300  # atime
Modify: 2025-10-01 14:12:00.000000000 +0300  # mtime
Change: 2025-10-01 14:15:30.000000000 +0300  # ctime
 Birth: 2020-01-01 12:00:00.000000000 +0300 # если поддерживается FS
```

> [!TIP]
> В старых файловых системах (ext3 и ниже) `Birth` может отсутствовать.

---

### Просмотр только определённой метки

```bash
stat -c %x file.txt  # Access time (atime)
stat -c %y file.txt  # Modification time (mtime)
stat -c %z file.txt  # Change time (ctime)
```

---

### Дополнительно: кто владелец файла

```bash
ls -l file.txt
```

Вывод:

```
-rw-r--r-- 1 user1 group1 123 Oct  2 10:30 file.txt
```

* `user1` — владелец файла
* `group1` — группа владельца
* Дата и время — mtime (последнее изменение содержимого)

Для подробной информации о правах:

```bash
getfacl file.txt
```

* Показывает все права доступа (Access Control Lists) и владельцев.

---

## 🛠 2. Изменение временных меток

### Изменить **время доступа (atime)**

```bash
touch -a -d "1988-02-15" file.txt
touch -a -d "1988-02-15 01:00" file.txt
touch -a -d "1988-02-15 01:00:17.547775198 +0300" file.txt
```

### Изменить **время модификации (mtime)**

```bash
touch -m -d "2020-01-20" file.txt
```

### Изменить одновременно **atime и mtime**

```bash
touch -t 202501021230.55 file.txt
# YYYYMMDDhhmm.ss
```

> [!IMPORTANT]
> **ctime нельзя изменить напрямую**. Оно обновляется автоматически при изменении прав, владельца или времени модификации.

---

### Изменение владельца и прав

```bash
sudo chown user2:group2 file.txt  # сменить владельца
chmod 644 file.txt                # изменить права
```

* Любое изменение владельца или прав обновляет **ctime**

---

## 🔍 3. Просмотр истории доступа и изменения файлов

### Использование `auditd`

* Для отслеживания, кто и когда открывал или изменял файл:

```bash
sudo auditctl -w /path/to/file.txt -p rwa -k file_watch
sudo ausearch -f /path/to/file.txt -k file_watch
```

* Параметры `-p`:

  * `r` — чтение (atime)
  * `w` — запись (mtime)
  * `x` — выполнение
  * `a` — атрибуты (ctime)

> [!TIP]
> `auditd` позволяет вести полноценный журнал изменений файлов и действий пользователей.

---

### Использование `inotify` (отслеживание в реальном времени)

```bash
inotifywait -m file.txt
```

* Выводит события: открытие, запись, изменение атрибутов, удаление

---

## 📄 4. Просмотр временных меток на всех файлах каталога

```bash
stat -c "%n %x %y %z" *.txt
```

* `%n` — имя файла
* `%x` — atime
* `%y` — mtime
* `%z` — ctime

---

## 💻 5. Временные метки и файловые системы

* ext4 — поддерживает atime, mtime, ctime и birth (creation time)
* ext3/ext2 — нет birth time
* XFS, Btrfs — поддерживают все временные метки, включая creation time

> [!TIP]
> В Linux `ctime` не означает «создано», оно отражает изменение **метаданных файла**.

---

## 🧩 6. Полезные команды в связке

| Задача                         | Команда                                |
| ------------------------------ | -------------------------------------- |
| Проверить временные метки      | `stat file.txt`                        |
| Изменить atime                 | `touch -a -d "2025-01-01" file.txt`    |
| Изменить mtime                 | `touch -m -d "2025-01-01" file.txt`    |
| Изменить владельца             | `chown user:group file.txt`            |
| Изменить права                 | `chmod 644 file.txt`                   |
| Отслеживать в реальном времени | `inotifywait -m file.txt`              |
| Логировать доступ/изменения    | `auditctl -w file.txt -p rwa -k watch` |

---

## 🔗 Полезные ссылки

* [man stat](https://linux.die.net/man/1/stat)
* [man touch](https://linux.die.net/man/1/touch)
* [man chown](https://linux.die.net/man/1/chown)
* [man chmod](https://linux.die.net/man/1/chmod)
* [inotifywait](https://linux.die.net/man/1/inotifywait)
* [auditctl](https://linux.die.net/man/8/auditctl)
