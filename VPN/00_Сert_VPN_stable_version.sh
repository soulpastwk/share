#!/bin/bash

set -e

# Проверка OpenSSL
if ! command -v openssl &> /dev/null; then
  sudo apt update && sudo apt install -y openssl
fi

# Установка/запуск 3X-UI
if ! command -v x-ui &> /dev/null; then
  bash <(curl -Ls https://raw.githubusercontent.com/MHSanaei/3x-ui/refs/tags/v2.6.0/install.sh)
else
  echo "3X-UI уже установлен."
fi

echo "┌───────────────────────────────────────────────────────────┐"
echo "│                                                           │"
echo "│   ██████    ██   ██████      GiS VPN Tools               │"
echo "│   ██        ██   ██                                       │"
echo "│   ██  ████  ██   ██████                                   │"
echo "│   ██    ██  ██       ██                                   │"
echo "│   ████████  ██   ██████                                   │"
echo "│                                                           │"
echo "│   Secure Connections & Certificate Generator              │"
echo "│                    Vitaliy Edition                        │"
echo "└───────────────────────────────────────────────────────────┘"

cat << "EOF"
=====================================================================
🛡️🌐👨‍💼🕵️‍♂️🖥️🔐🔥🚀🛰️📡🛠️ GiS Rulezzzzzzzz 🛠️📡🛰️🚀🔥🔐🖥️🕵️‍♂️👨‍💼🌐🛡️
=====================================================================

EOF

systemctl daemon-reload || true
if systemctl list-units --full -all | grep -Fq 'x-ui.service'; then
  systemctl enable x-ui || true
  systemctl restart x-ui || true
else
  x-ui || true
fi

# -------------------- Выбор сервиса --------------------
echo "Выберите сервис, под который будем маскировать сертификат:"
echo "1) Yandex"
echo "2) Google"
echo "3) Microsoft"
echo "4) Cloudflare"
echo "5) Telegram"
read -p "Введите цифру (1-5): " CHOICE

# Рандомное OU
OUs=("Tech" "IT" "Support" "DevOps" "Cloud" "Edge" "Security")
RAND_OU=${OUs[$RANDOM % ${#OUs[@]}]}

# Данные сервисов
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

# Выбор маскировки
case $CHOICE in
  1) C="RU"; ORG='Yandex LLC'
     ST=${YANDEX_ST[$RANDOM % ${#YANDEX_ST[@]}]}
     L=${YANDEX_L[$RANDOM % ${#YANDEX_L[@]}]}
     CN=${YANDEX_CN[$RANDOM % ${#YANDEX_CN[@]}]}
     ;;
  2) C="US"; ORG='Google LLC'
     ST=${GOOGLE_ST[$RANDOM % ${#GOOGLE_ST[@]}]}
     L=${GOOGLE_L[$RANDOM % ${#GOOGLE_L[@]}]}
     CN=${GOOGLE_CN[$RANDOM % ${#GOOGLE_CN[@]}]}
     ;;
  3) C="US"; ORG='Microsoft Corporation'
     ST=${MS_ST[$RANDOM % ${#MS_ST[@]}]}
     L=${MS_L[$RANDOM % ${#MS_L[@]}]}
     CN=${MS_CN[$RANDOM % ${#MS_CN[@]}]}
     ;;
  4) C="US"; ORG='Cloudflare, Inc.'
     ST=${CF_ST[$RANDOM % ${#CF_ST[@]}]}
     L=${CF_L[$RANDOM % ${#CF_L[@]}]}
     CN=${CF_CN[$RANDOM % ${#CF_CN[@]}]}
     ;;
  5) C="AE"; ORG='Telegram FZ-LLC'
     ST=${TG_ST[$RANDOM % ${#TG_ST[@]}]}
     L=${TG_L[$RANDOM % ${#TG_L[@]}]}
     CN=${TG_CN[$RANDOM % ${#TG_CN[@]}]}
     ;;
  *) echo "Неверный выбор, используем Google."
     C="US"; ORG='Google LLC'
     ST=${GOOGLE_ST[$RANDOM % ${#GOOGLE_ST[@]}]}
     L=${GOOGLE_L[$RANDOM % ${#GOOGLE_L[@]}]}
     CN=${GOOGLE_CN[$RANDOM % ${#GOOGLE_CN[@]}]}
     ;;
esac

# -------------------- Выбор типа ключа --------------------
echo "----------------------------------------------------------------------------------------------------------------"
echo "----------------------------------       Описание алгоритмов шифрования      -----------------------------------"
echo "----------------------------------------------------------------------------------------------------------------"
echo "✅ ECDSA P-256 prime256v1 / secp256r1 — стандартная и самая быстрая эллиптическая кривая, подходит почти везде."
echo "✅ ECDSA P-384 secp384r1 — более надёжная, но чуть медленнее."
echo "✅ ECDSA P-521 secp521r1 — ещё надёжнее, но самая «тяжёлая» по вычислениям, редко нужна."
echo "----------------------------------------------------------------------------------------------------------------"
echo "----------------------------------       Описание алгоритмов шифрования      -----------------------------------"
echo "----------------------------------------------------------------------------------------------------------------"
echo "🔥 максимум совместимости → RSA-2048"
echo "🚀 современно и быстро → ECDSA P-256"
echo "🛡️ повышенная стойкость → ECDSA P-384"
echo "----------------------------------------------------------------------------------------------------------------"
echo "----------------------------------        Советую 3 4 6 сами выбираем        -----------------------------------"
echo "----------------------------------------------------------------------------------------------------------------"
echo "1) RSA-2048"
echo "2) RSA-3072"
echo "3) RSA-4096"
echo "4) ECDSA P-256 (prime256v1)"
echo "5) ECDSA P-384 (secp384r1)"
echo "6) ECDSA P-521 (secp521r1)"
read -p "Введите цифру (1-6): " KEY_CHOICE

KEY_TYPE=""
case $KEY_CHOICE in
  1) KEY_TYPE="rsa:2048" ;;
  2) KEY_TYPE="rsa:3072" ;;
  3) KEY_TYPE="rsa:4096" ;;
  4) KEY_TYPE="prime256v1" ;;
  5) KEY_TYPE="secp384r1" ;;
  6) KEY_TYPE="secp521r1" ;;
  *) echo "Неверный выбор, используем RSA-2048."
     KEY_TYPE="rsa:2048" ;;
esac

# -------------------- Пути --------------------
CERT_DIR="/etc/ssl/self_signed_cert"
CERT_NAME="self_signed"
mkdir -p "$CERT_DIR"
KEY_PATH="$CERT_DIR/$CERT_NAME.key"
CSR_PATH="$CERT_DIR/$CERT_NAME.csr"
CERT_PATH="$CERT_DIR/$CERT_NAME.crt"
CONF_PATH="$CERT_DIR/$CERT_NAME.openssl.cnf"

# -------------------- Конфиг OpenSSL --------------------
cat > "$CONF_PATH" <<EOF
[ req ]
default_bits       = 2048
prompt             = no
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
C  = $C
ST = $ST
L  = $L
O  = $ORG
OU = $RAND_OU
CN = $CN

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $CN
EOF

# -------------------- Генерация ключа и CSR --------------------
if [[ "$KEY_TYPE" == rsa* ]]; then
  openssl req -new -nodes -newkey $KEY_TYPE \
    -keyout "$KEY_PATH" \
    -out "$CSR_PATH" \
    -config "$CONF_PATH"
else
  # ECDSA
  openssl ecparam -name $KEY_TYPE -genkey -noout -out "$KEY_PATH"
  openssl req -new -key "$KEY_PATH" -out "$CSR_PATH" -config "$CONF_PATH"
fi

# -------------------- Подпись сертификата --------------------
openssl x509 -req -in "$CSR_PATH" \
  -signkey "$KEY_PATH" \
  -out "$CERT_PATH" \
  -days 3650 \
  -extfile "$CONF_PATH" -extensions req_ext

# -------------------- Финал --------------------
echo "============================================================"
echo " Сертификат успешно создан!"
echo " Subject: C=$C, ST=$ST, L=$L, O=$ORG, OU=$RAND_OU, CN=$CN"
echo " KeyType: $KEY_TYPE"
echo " CERT:    $CERT_PATH"
echo " KEY:     $KEY_PATH"
echo "============================================================="
echo "  Пропиши эти пути в настройках 3x-ui и перезапусти панель.  "
echo "               Так же смени пароль от Web-ки                 "
echo "Ты великолепен!💡🌎 Массоны привествуют тебя в своих рядах 👨‍💼"
echo "============================================================="
