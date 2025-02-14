Вот дополнительный раздел для `README.md`, который вы можете добавить в ваш файл. Он включает все необходимые команды, объяснения и скриншоты:

---

# Дополнительная защита сервера

---

## Установка и настройка Fail2Ban

Fail2Ban — это инструмент для защиты сервера от брутфорс-атак путем блокировки IP-адресов, которые совершают подозрительные действия.

### Установка Fail2Ban
```bash
apt install fail2ban -y
```

Если у вас не установлен `nano`, установите его:
```bash
apt install nano -y
```

Создайте конфигурационный файл:
```bash
touch /etc/fail2ban/jail.local
nano /etc/fail2ban/jail.local
```

Вставьте следующий конфигурационный файл (без комментариев):
```ini
[sshd]
enabled = true
filter = sshd
action = iptables[name=SSH, port=ssh, protocol=tcp]
logpath = %(syslog_authpriv)s
findtime = 600
maxretry = 2
bantime = -1
backend = systemd
```

### Объяснение параметров
- **`[sshd]`**: Начало секции для настройки защиты SSH-сервера.
- **`enabled = true`**: Включение защиты для данного сервиса.
- **`filter = sshd`**: Используется стандартный фильтр для анализа логов SSH.
- **`action = iptables[name=SSH, port=ssh, protocol=tcp]`**: Блокировка IP через `iptables`.
- **`logpath = %(syslog_authpriv)s`**: Путь к файлу журнала, который анализируется.
- **`findtime = 600`**: Временной интервал (10 минут), в течение которого считаются неудачные попытки входа.
- **`maxretry = 2`**: Максимальное количество неудачных попыток входа до блокировки IP.
- **`bantime = -1`**: Время блокировки IP (`-1` означает постоянную блокировку).
- **`backend = systemd`**: Система мониторинга логов.

### Запуск и проверка статуса 
Добавьте Fail2Ban в автозагрузку, перезапустите и запустите службу:
```bash
systemctl enable fail2ban
systemctl restart fail2ban
systemctl start fail2ban
systemctl status fail2ban
```

Проверьте статус службы и клиента (может потребоваться подождать несколько секунд):
```bash
fail2ban-client status
```

---

### Просмотр правил и заблокированных IP
#### Просмотр всех правил `iptables`
```bash
sudo iptables -L -n --line-numbers
```

#### Просмотр заблокированных IP-адресов
```bash
sudo iptables -L f2b-SSH -n
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

## Ускорение работы сервера VPN

### Вариант 1: Ограничение логирования
Откройте файл для редактирования:
```bash
nano /etc/systemd/journald.conf
```

Замените содержимое файла на следующий конфигурационный файл:
```ini
[Journal]
Storage=volatile
SystemMaxUse=0
RuntimeMaxUse=10M
RuntimeMaxFileSize=5M
RuntimeMaxFiles=1
MaxRetentionSec=5m
MaxFileSec=5m
RateLimitIntervalSec=5s
RateLimitBurst=500
MaxLevelStore=emerg
MaxLevelSyslog=emerg
MaxLevelKMsg=emerg
MaxLevelConsole=emerg
ReadKMsg=no
Audit=no
```

Очистите логи и перезапустите службу:
```bash
rm -rf /var/log/journal/*
systemctl restart systemd-journald
reboot
```

Проверьте использование дискового пространства:
```bash
journalctl --disk-usage
```

Логи теперь будут находиться в `/run/log/journal/`.

---

### Вариант 2: Отключение записи в `/var/log/journal`
Удалите директорию и создайте immutable-файл:
```bash
rm -rf /var/log/journal
touch /var/log/journal
chattr +i /var/log/journal
```

Для снятия атрибута:
```bash
chattr -i /var/log/journal
```

---

## Смена стандартного порта SSH

Рекомендуется изменить стандартный порт SSH (22) на другой (например, из диапазона 60000-65000).

### Изменение порта
1. Откройте файл конфигурации SSH:
   ```bash
   nano /etc/ssh/sshd_config
   ```

2. Найдите строку:
   ```bash
   #Port 22
   ```

3. Раскомментируйте её и измените на новый порт:
   ```bash
   Port 60000
   ```

4. Сохраните файл и перезапустите службу SSH:
   ```bash
   systemctl restart sshd
   ```

---

Теперь ваш сервер защищен и оптимизирован! 

--- 
