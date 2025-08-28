# Примеры конфигов Fail2Ban для защиты 3X-UI

## 1. Фильтр для 3X-UI (создать файл)

Например, если 3X-UI пишет логи в `/etc/x-ui/x-ui.log` или `/var/log/x-ui.log`, создайте фильтр:

`/etc/fail2ban/filter.d/3x-ui.conf`
```ini
[Definition]
failregex = ^.*Failed login attempt.*username.*from <HOST>.*
ignoreregex =
```
_Примечание: Подкорректируйте failregex под реальный формат логов вашей панели 3X-UI! Пример выше — шаблон._

## 2. Jail-конфиг для 3X-UI

`/etc/fail2ban/jail.local` (добавьте секцию):
```ini
[3x-ui]
enabled = true
filter = 3x-ui
action = nftables[name=3XUI, port=8443, protocol=tcp]
logpath = /etc/x-ui/x-ui.log
findtime = 600
maxretry = 3
bantime = 86400
backend = auto
```
_Замените logpath и port на актуальные для вашей установки._

## 3. Проверка и перезапуск

```bash
fail2ban-client reload
fail2ban-client status 3x-ui
```

---

**Если у 3X-UI другой лог или формат — покажите пример строки из лога, я помогу адаптировать failregex.**