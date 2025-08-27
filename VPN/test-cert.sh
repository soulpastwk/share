#!/bin/bash

# Устанавливаем 3x-ui панель для VLESS и сертификаты на 10 лет

# Установка OpenSSL
if ! command -v openssl &> /dev/null; then
  sudo apt update && sudo apt install -y openssl
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# Установка 3X-UI
if ! command -v x-ui &> /dev/null; then
  bash <(curl -Ls https://raw.githubusercontent.com/MHSanaei/3x-ui/refs/tags/v2.6.0/install.sh)
  if [ $? -ne 0 ]; then
    exit 1
  fi
else
  echo "3X-UI уже установлен."
fi

# ASCII-арт
cat << "EOF"
=====================================================================
🛡️🌐👨‍💼🕵️‍♂️🖥️🔐🔥🚀🛰️📡🛠️ GIS RULEZzzzzzz 🛠️📡🛰️🚀🔥🔐🖥️🕵️‍♂️👨‍💼🌐🛡️
=====================================================================
EOF

# Запуск 3X-UI
systemctl daemon-reload
if systemctl list-units --full -all | grep -Fq 'x-ui.service'; then
  systemctl enable x-ui
  systemctl start x-ui
else
  x-ui
fi

# --- Блок выбора маскировки сертификата ---
echo "Выберите сервис, под который будем маскировать сертификат:"
echo "Если VPN каскадный делаем, то тут внимательно очень !"
echo "1) Yandex"
echo "2) Google"
echo "3) Microsoft"
echo "4) Cloudflare"
echo "5) Telegram"
read -p "Введите цифру (1-5): " CHOICE

# Рандомное OU
OUs=("Tech" "IT" "Support" "DevOps" "Cloud" "Edge" "Security")
RAND_OU=${OUs[$RANDOM % ${#OUs[@]}]}

# Пулы регионов/городов и CN для каждого сервиса
YANDEX_ST=("Moscow" "Saint-Petersburg" "Novosibirsk")
YANDEX_L=("Moscow" "Saint-Petersburg" "Novosibirsk")
YANDEX_CN=("mail.yandex.com" "disk.yandex.ru" "yandex.ru" "passport.yandex.ru")

GOOGLE_ST=("California" "Texas" "New York")
GOOGLE_L=("Mountain View" "Dallas" "New York")
GOOGLE_CN=("google.com" "mail.google.com" "accounts.google.com" "drive.google.com")

MS_ST=("Washington" "Texas" "California")
MS_L=("Redmond" "Austin" "Los Angeles")
MS_CN=("update.microsoft.com" "login.microsoftonline.com" "outlook.office.com" "onedrive.live.com")

CF_ST=("California" "Illinois" "New York")
CF_L=("San Francisco" "Chicago" "New York")
CF_CN=("cdn.cloudflare.net" "workers.dev" "cloudflare.com" "pages.dev")

TG_ST=("Dubai" "Sharjah")
TG_L=("Dubai" "Sharjah")
TG_CN=("web.telegram.org" "core.telegram.org" "api.telegram.org" "t.me")

# Выбор параметров по сервису
case $CHOICE in
  1) # Yandex
    RAND_ST=${YANDEX_ST[$RANDOM % ${#YANDEX_ST[@]}]}
    RAND_L=${YANDEX_L[$RANDOM % ${#YANDEX_L[@]}]}
    RAND_CN=${YANDEX_CN[$RANDOM % ${#YANDEX_CN[@]}]}
    CERT_SUBJ="/C=RU/ST=$RAND_ST/L=$RAND_L/O=Yandex LLC/OU=$RAND_OU/CN=$RAND_CN"
    ;;
  2) # Google
    RAND_ST=${GOOGLE_ST[$RANDOM % ${#GOOGLE_ST[@]}]}
    RAND_L=${GOOGLE_L[$RANDOM % ${#GOOGLE_L[@]}]}
    RAND_CN=${GOOGLE_CN[$RANDOM % ${#GOOGLE_CN[@]}]}
    CERT_SUBJ="/C=US/ST=$RAND_ST/L=$RAND_L/O=Google LLC/OU=$RAND_OU/CN=$RAND_CN"
    ;;
  3) # Microsoft
    RAND_ST=${MS_ST[$RANDOM % ${#MS_ST[@]}]}
    RAND_L=${MS_L[$RANDOM % ${#MS_L[@]}]}
    RAND_CN=${MS_CN[$RANDOM % ${#MS_CN[@]}]}
    CERT_SUBJ="/C=US/ST=$RAND_ST/L=$RAND_L/O=Microsoft Corporation/OU=$RAND_OU/CN=$RAND_CN"
    ;;
  4) # Cloudflare
    RAND_ST=${CF_ST[$RANDOM % ${#CF_ST[@]}]}
    RAND_L=${CF_L[$RANDOM % ${#CF_L[@]}]}
    RAND_CN=${CF_CN[$RANDOM % ${#CF_CN[@]}]}
    CERT_SUBJ="/C=US/ST=$RAND_ST/L=$RAND_L/O=Cloudflare, Inc./OU=$RAND_OU/CN=$RAND_CN"
    ;;
  5) # Telegram
    RAND_ST=${TG_ST[$RANDOM % ${#TG_ST[@]}]}
    RAND_L=${TG_L[$RANDOM % ${#TG_L[@]}]}
    RAND_CN=${TG_CN[$RANDOM % ${#TG_CN[@]}]}
    CERT_SUBJ="/C=AE/ST=$RAND_ST/L=$RAND_L/O=Telegram FZ-LLC/OU=$RAND_OU/CN=$RAND_CN"
    ;;
  *)
    echo "Неверный выбор, по умолчанию используем Google."
    RAND_ST=${GOOGLE_ST[$RANDOM % ${#GOOGLE_ST[@]}]}
    RAND_L=${GOOGLE_L[$RANDOM % ${#GOOGLE_L[@]}]}
    RAND_CN=${GOOGLE_CN[$RANDOM % ${#GOOGLE_CN[@]}]}
    CERT_SUBJ="/C=US/ST=$RAND_ST/L=$RAND_L/O=Google LLC/OU=$RAND_OU/CN=$RAND_CN"
    ;;
esac

# Генерация сертификата
CERT_DIR="/etc/ssl/self_signed_cert"
CERT_NAME="self_signed"
DAYS_VALID=3650
mkdir -p "$CERT_DIR"
CERT_PATH="$CERT_DIR/$CERT_NAME.crt"
KEY_PATH="$CERT_DIR/$CERT_NAME.key"

# Генерим рандомный серийник (16 байт -> hex)
SERIAL=$(openssl rand -hex 16)

# Дата начала действия (от -30 до 0 дней назад)
DAYS_SHIFT=$((RANDOM % 30))
START_DATE=$(date -u -d "-$DAYS_SHIFT days" +"%Y%m%d%H%M%SZ")
END_DATE=$(date -u -d "+$((DAYS_VALID - DAYS_SHIFT)) days" +"%Y%m%d%H%M%SZ")

# Генерация сертификата с кастомным серийником и датами
openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout "$KEY_PATH" \
  -out "$CERT_PATH" \
  -subj "$CERT_SUBJ" \
  -set_serial 0x$SERIAL \
  -days $DAYS_VALID \
  -startdate "$START_DATE" \
  -enddate "$END_DATE"

if [ $? -eq 0 ]; then
  echo "============================================================"
  echo " Сертификат успешно создан!"
  echo " Subject: $CERT_SUBJ"
  echo " Serial: $SERIAL"
  echo " Start: $START_DATE"
  echo " End:   $END_DATE"
  echo " SSL CERTIFICATE PATH: $CERT_PATH"
  echo " SSL KEY PATH: $KEY_PATH"
else
  exit 1
fi

# Финальное сообщение
echo "============================================================"
echo "   Установка завершена, ключи сгенерированы!"
echo "   Осталось только пути ключей прописать в панели управления 3x-ui"
echo "1) Зайди по ссылке сверху (покрути вверх в терминале), введи логин и пароль, который сгенерировал скрипт"
echo "2) После успешной авторизации перейти в Настройки панели, смени пароли, само собой и порты панели и её имя"
echo "3) Путь к файлу ПУБЛИЧНОГО ключа сертификата - сюда вставить путь $CERT_PATH"
echo "4) Путь к файлу ПРИВАТНОГО ключа сертификата - сюда вставить путь $KEY_PATH"
echo "5) Сохраняем и перегружаем панель"

echo "Ты великолепен!💡🌎 Массоны приветствуют тебя в своих рядах 👨‍💼"
echo "==========================+++=================================="
