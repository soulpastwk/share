# Инструкция по обновлению Sudo до версии 1.9.17p2 (последняя стабильная) 🛠️

## 📌 Актуальная информация
Согласно [официальному сайту](https://www.sudo.ws/):
- **Стабильная версия:** 1.9.17p2 (26 июля 2025)
- **Legacy-версия:** 1.8.32 (9 февраля 2021)
- **Релиз-кандидат:** 1.9.17rc1 (9 июня 2025)


---

## ⚠️ Важно!!!
Перед обновлением:
1. Проверьте актуальную версию на [официальном сайте](https://www.sudo.ws/)
2. Создайте резервную копию критических данных
3. Убедитесь, что система обновлена: 
```bash
sudo apt update && sudo apt upgrade -y
```

---

## 📥 1. Установка зависимостей
```bash
sudo apt install build-essential libpam0g-dev libssl-dev -y
```

---

## 📲 2. Скачивание исходников
```bash
cd /usr/src
sudo wget https://www.sudo.ws/dist/sudo-1.9.17p2.tar.gz
```

---

## 📦 3. Распаковка и компиляция
```bash
sudo tar -xvzf sudo-1.9.17p2.tar.gz
cd sudo-1.9.17p2
```

---

## 🔧 4. Настройка и сборка
```bash
./configure
make
sudo make install
```

---

## 🔄 5. Перезагрузка и проверка
```bash
sudo reboot
```

После перезагрузки:
```bash
sudo --version    # Должна отображаться версия 1.9.17p2
which sudo        # Проверка пути к бинарнику
```

---

## 📦 Альтернативный способ (через пакетный менеджер)
```bash
sudo apt update
sudo apt install sudo -y
```

---

📌 **Примечания:**
- Для отката изменений:
```bash
sudo apt install --reinstall sudo
```
- Рекомендуется проверить целостность системы:
```bash
sudo apt --fix-broken install
```
```
