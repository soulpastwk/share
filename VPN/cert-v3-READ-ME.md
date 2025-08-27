
# 🛡️ 3X-UI Auto Installer + Self-Signed SSL Generator

[![OS Linux](https://img.shields.io/badge/OS-Linux-blue?logo=linux&logoColor=white)](https://www.linux.org/)
[![OpenSSL](https://img.shields.io/badge/OpenSSL-%E2%9C%94-green?logo=openssl&logoColor=white)](https://www.openssl.org/)
[![Xray](https://img.shields.io/badge/Xray-Ready-orange?logo=github)](https://github.com/XTLS/Xray-core)
[![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)

Скрипт автоматизирует установку [**3X-UI панели**](https://github.com/MHSanaei/3x-ui) и генерацию самоподписанных SSL-сертификатов на **10 лет**, с возможностью маскировки под популярные сервисы (Google, Yandex, Microsoft, Cloudflare, Telegram).

---

## ⚡ Возможности
- 🔄 Автоматическая установка и запуск **3X-UI** (или перезапуск, если уже установлен).  
- 🔑 Генерация **SSL-сертификата** с кастомизацией:
  - Маскировка под сервис (**Google / Yandex / Microsoft / Cloudflare / Telegram**).  
  - Рандомизация полей сертификата (OU, город, штат, CN).  
  - Выбор алгоритма ключа:
    - **RSA**: 2048 / 3072 / 4096 бит  
    - **ECDSA**: prime256v1 / secp384r1 / secp521r1  
    - **EdDSA**: Ed25519 / Ed448  
- 📅 Срок действия сертификата: **10 лет (3650 дней)**.  
- 📂 Автоматическое сохранение файлов в `/etc/ssl/self_signed_cert/`.  

---

## 📂 Пути по умолчанию
- 🔑 Приватный ключ: `/etc/ssl/self_signed_cert/self_signed.key`  
- 📜 Сертификат: `/etc/ssl/self_signed_cert/self_signed.crt`  

---

## 🚀 Установка и запуск
```bash
wget -O install.sh https://raw.githubusercontent.com/username/repo/main/install.sh
chmod +x install.sh
./install.sh
````

---

## 🖼️ Пример работы

При запуске скрипт задаст вопросы:

1. Под какой сервис маскировать сертификат (Google, Yandex, и т.д.).
2. Какой алгоритм ключа использовать (RSA, ECC, EdDSA).

Пример вывода:

```
============================================================
 Сертификат успешно создан!
 Subject: C=US, ST=California, L=Mountain View, O=Google LLC, OU=IT, CN=google.com
 Алгоритм ключа: RSA-4096
 CERT:    /etc/ssl/self_signed_cert/self_signed.crt
 KEY:     /etc/ssl/self_signed_cert/self_signed.key
============================================================
```

---

## ⚠️ Примечание

* Самоподписанные сертификаты подходят для тестирования, VPN и прокси, но браузеры будут ругаться.
* Для боевых проектов лучше использовать [Let's Encrypt](https://letsencrypt.org/).
* Поддержка **ChaCha20-Poly1305** зависит от версии OpenSSL и клиента — если алгоритм есть, TLS выберет его автоматически.

---

## 🧑‍💻 WK-13

👨‍💼 Сделано с ❤️ и 🔐

