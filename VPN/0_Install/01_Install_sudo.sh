#!/bin/bash
# Автоматическое обновление sudo до версии 1.9.17p2
# Дата: 26 июля 2025
# Автор: ChatGPT

set -e

VERSION="1.9.17p2"
SRC_URL="https://www.sudo.ws/dist/sudo-$VERSION.tar.gz"
SRC_DIR="/usr/src"
ARCHIVE="$SRC_DIR/sudo-$VERSION.tar.gz"

echo "🔍 Проверка текущей версии sudo..."
CURRENT=$(sudo --version | head -n1 | awk '{print $3}')
echo "Текущая версия: $CURRENT"

if [[ "$CURRENT" == "$VERSION" ]]; then
    echo "✅ У вас уже установлена версия sudo $VERSION"
    exit 0
fi

echo "📦 Обновляем пакеты и ставим зависимости..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential libpam0g-dev libssl-dev wget

echo "📥 Скачивание sudo $VERSION..."
cd $SRC_DIR
if [ -f "$ARCHIVE" ]; then
    echo "Файл уже скачан."
else
    sudo wget $SRC_URL
fi

echo "📦 Распаковка исходников..."
sudo tar -xvzf $ARCHIVE
cd "sudo-$VERSION"

echo "⚙️ Сборка и установка..."
./configure
make -j$(nproc)
sudo make install

echo "🧹 Очистка ненужных файлов..."
cd ..
sudo rm -rf "sudo-$VERSION"

echo "🔄 Перезагрузка системы рекомендуется!"
echo "Проверка версии:"
sudo --version | head -n1

echo "✅ Установка sudo $VERSION завершена успешно!"
