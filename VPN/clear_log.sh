#!/bin/bash

# Определяем директорию логов
LOG_DIR="/var/log"
JOURNAL_DIR="$LOG_DIR/journal"
FAIL2BAN_LOG="$LOG_DIR/fail2ban.log"
REPORT_LOG="$LOG_DIR/clear_logs_report.log" # Файл отчетов

# Функция для перезаписи файла случайными данными
overwrite_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo "Перезапись файла: $file"
        local filesize=$(stat --format="%s" "$file") # Размер файла в байтах
        if [[ "$filesize" -eq 0 ]]; then
            echo "  Файл пустой, пропускаем перезапись."
        else
            for i in {1..6}; do
                echo "  Проход $i из 6..."
                dd if=/dev/urandom of="$file" bs="$filesize" count=1 conv=notrunc status=none
            done
        fi
        echo "Удаление файла: $file"
        rm -f "$file" # Удаляем файл после перезаписи
    fi
}

# Выводим заголовок
echo "=== Начало очистки логов ==="
echo ""

# Сохраняем размеры логов до очистки
declare -A before_sizes
for file in $(find "$LOG_DIR" -type f \
  ! -path "$JOURNAL_DIR/*" \
  ! -name "$(basename "$FAIL2BAN_LOG")" \
  ! -name "$(basename "$FAIL2BAN_LOG").1" \
  ! -name "$(basename "$REPORT_LOG")"); do
    before_sizes["$file"]=$(du -h --apparent-size "$file" | cut -f1)
done

# Выводим размеры логов до очистки
echo "Размеры логов до очистки:"
for file in "${!before_sizes[@]}"; do
    echo "  $file: ${before_sizes[$file]}"
done
echo ""

# Очищаем логи
echo "Очистка логов..."
for file in $(find "$LOG_DIR" -type f \
  ! -path "$JOURNAL_DIR/*" \
  ! -name "$(basename "$FAIL2BAN_LOG")" \
  ! -name "$(basename "$FAIL2BAN_LOG").1" \
  ! -name "$(basename "$REPORT_LOG")"); do
    overwrite_file "$file"
done

# Удаляем старые архивные логи (например, *.gz или *.1), исключая fail2ban
find "$LOG_DIR" -type f \( -name "*.gz" -o -name "*.1" \) \
  ! -name "$(basename "$FAIL2BAN_LOG").1" \
  -exec rm -f {} \;

# Создаём новые пустые файлы на месте удалённых
echo "Создание новых пустых файлов..."
for file in "${!before_sizes[@]}"; do
    touch "$file"
    chmod 640 "$file" # Устанавливаем права доступа
    chown root:adm "$file" # Устанавливаем владельца и группу
done

# Выводим результаты
echo ""
echo "=== Очистка завершена ==="
