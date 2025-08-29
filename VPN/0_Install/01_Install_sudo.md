[![sudo version](https://img.shields.io/badge/sudo-1.9.17p2-brightgreen?style=flat-square)](https://www.sudo.ws/)
[![CVE Fixed](https://img.shields.io/badge/CVE--2025--32463-fixed-blue?style=flat-square)](https://nvd.nist.gov/vuln/detail/CVE-2025-32463)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey?style=flat-square&logo=linux)
![Tested on](https://img.shields.io/badge/tested%20on-Ubuntu%2024.04%20%7C%20Debian%2012-orange?style=flat-square)

# 🚀 Автоматическая установка и обновление `sudo` до версии 1.9.17p2

Скрипт позволяет **в один клик обновить sudo** до последней стабильной версии **1.9.17p2** (26 июля 2025), устраняя критическую уязвимость (CVE-2025-32463).

---

## 🔧 Быстрая установка (1 команда)

Просто выполните в терминале:

```bash
curl -sL https://raw.githubusercontent.com/soulpastwk/share/main/VPN/0_Install/01_Install_sudo.sh | bash
````

---

## 📥 Альтернативный способ (скачивание и запуск вручную)

### 1. Скачайте скрипт

```bash
wget https://raw.githubusercontent.com/soulpastwk/share/main/VPN/0_Install/01_Install_sudo.sh
```

### 2. Дайте права на выполнение

```bash
chmod +x 01_Install_sudo.sh
```

### 3. Запустите установку

```bash
./01_Install_sudo.sh
```

---

## 📌 Проверка

После установки проверьте версию:

```bash
sudo --version
```

Ожидаемый результат:

```
Sudo version 1.9.17p2
```

---

## 🔄 Откат

При необходимости можно вернуть пакетную версию:

```bash
sudo apt install --reinstall sudo
```

---

## ⚠️ Примечания

* Перед запуском убедитесь, что система обновлена:

  ```bash
  sudo apt update && sudo apt upgrade -y
  ```
* Скрипт протестирован на **Debian/Ubuntu-based** системах.
  Для RHEL/Fedora/SUSE используйте зависимости `gcc make pam-devel openssl-devel`.
* После обновления рекомендуется **перезагрузить систему**:

  ```bash
  sudo reboot
  ```

---

✅ Теперь обновление `sudo` до актуальной версии занимает всего **одну команду**!
