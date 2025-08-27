#!/bin/bash

# Устанавливаем 3x-ui панель для VLESS и самоподписанные сертификаты на 10 лет

# --- Проверка и установка зависимостей ---
if ! command -v openssl &> /dev/null; then
  sudo apt update && sudo apt install -y openssl
  [ $? -ne 0 ] && exit 1
fi

# Установка 3X-UI (если не установлен)
if ! command -v x-ui &> /dev/null; then
  bash <(curl -Ls https://raw.githubusercontent.com/MHSanaei/3x-ui/refs/tags/v2.6.0/install.sh)
  [ $? -ne 0 ] && exit 1
else
  echo "3X-UI уже установлен."
fi

# --- ASCII-арт ---
cat << "EOF"
=====================================================================
🛡️🌐👨‍💼🕵️‍♂️🖥️🔐🔥🚀🛰️📡🛠️ GIS RULEZzzzzzz 🛠️📡🛰️🚀🔥🔐🖥️🕵️‍♂️👨‍💼🌐🛡️
=====================================================================
EOF

# --- Запуск сервиса ---
systemctl daemon-reload
if systemctl list-units --full -all | grep -Fq 'x-ui.service'; then
  systemctl enable x-ui
  systemctl restart x-ui
else
  x-ui
fi

# --- Выбор маскировки ---
echo "Выберите сервис, под который будем маскировать сертификат:"
echo "Если VPN каскадный делаем, то тут внимательно очень !"
echo "1) Yandex"
echo "2) Google"
echo "3) Microsoft"
echo "4) Cloudflare"
echo "5) Telegram"
read -p "Введите цифру (1-5): " CHOICE

# Рандомный OU
OUs=("Tech" "IT" "Support" "DevOps" "Cloud" "Edge" "Security")
RAND_OU=${OUs[$RANDOM % ${#OUs[@]}]}

# Пулы данных
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

# --- Выбор параметров по сервису ---
case $CHOICE in
  1) RAND_ST=${YANDEX_ST[$RANDOM % ${#YANDEX_ST[@]}]}
     RAND_L=${YANDEX_L[$RANDOM % ${#YANDEX_L[@]}]}
     RAND_CN=${YANDEX_CN[$RANDOM % ${#YANDEX_CN[@]}]}
     CERT_SUBJ="/C=RU/ST=$RAND_ST/L=$RAND_L/O=Yandex LLC/OU=$RAND_OU/CN=$RAND_CN"
     ;;
  2) RAND_ST=${GOOGLE_ST[$RANDOM % ${#GOOGLE_ST[@]}]}
     RAND_L=${GOOGLE_L[$RANDOM % ${#GOOGLE_L[@]}]}
     RAND_CN=${GOOGLE_CN[$RANDOM % ${#GOOGLE_CN[@]}]}
     CERT_SUBJ="/C=US/ST=$RAND_ST/L=$RAND_L/O=Google LLC/OU=$RAND_OU/CN=$RAND_CN"
     ;;
  3) RAND_ST=${MS_ST[$RANDOM % ${#MS_ST[@]}]}
     RAND_L=${MS_L[$RANDOM % ${#MS_L[@]}]}
     RAND_CN=${MS_CN[$RANDOM % ${#MS_CN[@]}]}
     CERT_SUBJ="/C=US/ST=$RAND_ST/L=$RAND_L/O=Microsoft Corporation/OU=$RAND_OU/CN=$RAND_CN"
     ;;
  4) RAND_ST=${CF_ST[$RANDOM % ${#CF_ST[@]}]}
     RAND_L=${CF_L[$RANDOM % ${#CF_L[@]}]}
     RAND_CN=${CF_CN[$RANDOM % ${#CF_CN[@]}]}
     CERT_SUBJ="/C=US/ST=$RAND_ST/L=$RAND_L/O=Cloudflare, Inc./OU=$RAND_OU/CN=$RAND_CN"
     ;;
  5) RAND_ST=${TG_ST[$RANDOM % ${#TG_ST[@]}]}
     RAND_L=${TG_L[$RANDOM % ${#TG_L[@]}]}
     RAND_CN=${TG_CN[$RANDOM % ${#TG_CN[@]}]}
     CERT_SUBJ="/C=AE/ST=$RAND_ST/L=$RAND_L/O=Telegram FZ-LLC/OU=$RAND_OU/CN=$RAND_CN"
     ;;
  *) echo "Неверный выбор, используем Google."
     RAND_ST=${GOOGLE_ST[$RANDOM % ${#GOOGLE_ST[@]}]}
     RAND_L=${GOOGLE_L[$RANDOM % ${#GOOGLE_L[@]}]}
     RAND_CN=${GOOGLE_CN[$RANDOM % ${#GOOGLE_CN[@]}]}
     CERT_SUBJ="/C=US/ST=$RAND_ST/L=$RAND_L/O=Google LLC/OU=$RAND_OU/CN=$RAND_CN"
     ;;
esac

# --- Генерация сертификата ---
CERT_DIR="/etc/ssl/self_signed_cert"
CERT_NAME="self_signed"
mkdir -p "$CERT_DIR"
CERT_PATH="$CERT_DIR/$CERT_NAME.crt"
KEY_PATH="$CERT_DIR/$CERT_NAME.key"
CSR_PATH="$CERT_DIR/$CERT_NAME.csr"

# Даты + серийник
DAYS_VALID=3650
START_DATE=$(date -u +"%Y%m%d%H%M%SZ")
END_DATE=$(date -u -d "+${DAYS_VALID} days" +"%Y%m%d%H%M%SZ")
SERIAL=$(openssl rand -hex 16)

# Шаг 1. Генерация ключа и CSR
openssl req -new -newkey rsa:2048 -nodes \
  -keyout "$KEY_PATH" \
  -out "$CSR_PATH" \
  -subj "$CERT_SUBJ"

# Шаг 2. Подпись сертификата
openssl x509 -req -in "$CSR_PATH" \
  -signkey "$KEY_PATH" \
  -out "$CERT_PATH" \
  -days $DAYS_VALID \
  -set_serial 0x$SERIAL \
  -startdate "$START_DATE" \
  -enddate "$END_DATE"

if [ $? -eq 0 ]; then
  echo "============================================================"
  echo " Сертификат успешно создан!"
  echo " Subject: $CERT_SUBJ"
  echo " SSL CERTIFICATE PATH: $CERT_PATH"
  echo " SSL KEY PATH: $KEY_PATH"
else
  echo "Ошибка генерации сертификата!"
  exit 1
fi

# --- Финальное сообщение ---
echo "============================================================"
echo "   Установка завершена, ключи сгенерированы!"
echo "   Осталось только прописать пути в панели управления 3x-ui:"
echo "   → Публичный сертификат: $CERT_PATH"
echo "   → Приватный ключ:       $KEY_PATH"
echo "============================================================"
