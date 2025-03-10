import os
# Данный скрипт на питоне массово удалит ненужный фрагмент в названии из всех папок и файлов
# в данном примере это - [SW.BAND]

# Замени тут что требуется убрать в данном примере это - [SW.BAND] - (квадратные скобки тоже заменяем)
# Например у нас есть папка - [SW.BAND] Курсы линукс - а нам надо следать просто Курсы линукс 
# Либо другое повторяющееся имя у папок и файлов

# ЗАМЕНИ ТУТ - выдели всемте со скобками и нажми Ctrl+H - [SW.BAND]

# Укажите путь к корневой директории
root_dir = r"D:\Курсы"
# Больше ничего не редактируем только что заменить и директорию где заменять
# После замены просто запускаем скрипт питона 
def remove_prefix_in_directory(path):
    for dirpath, dirnames, filenames in os.walk(path, topdown=False):
        # Обрабатываем файлы
        for filename in filenames:
            if filename.startswith("[SW.BAND]"):
                old_file_path = os.path.join(dirpath, filename)
                new_file_name = filename.replace("[SW.BAND]", "", 1)
                new_file_path = os.path.join(dirpath, new_file_name)
                os.rename(old_file_path, new_file_path)
                print(f"Файл переименован: {old_file_path} -> {new_file_path}")
        
        # Обрабатываем папки
        for dirname in dirnames:
            if dirname.startswith("[SW.BAND]"):
                old_dir_path = os.path.join(dirpath, dirname)
                new_dir_name = dirname.replace("[SW.BAND]", "", 1)
                new_dir_path = os.path.join(dirpath, new_dir_name)
                os.rename(old_dir_path, new_dir_path)
                print(f"Папка переименована: {old_dir_path} -> {new_dir_path}")

# Запускаем функцию
remove_prefix_in_directory(root_dir)

# Теперь в VSCODE внизу во вкладке TERMINAL нажми стрелочку вверх и Enter
# Если ничего не появилось то напечатай .\rename.py

#Если в командной строке Windows то команду python3 и путь к данному скрипту
#Питон само собой должен быть установлен на ПК

#Проблема с длинными путями в Windows может возникать из-за ограничений файловой системы NTFS, которая по умолчанию поддерживает максимальную длину пути в 260 символов. 
#Однако есть несколько способов обойти это ограничение:

#1. Включение поддержки длинных путей в Windows
#Windows 10 (начиная с версии 1607) и Windows 11 поддерживают длинные пути, но эта функция отключена по умолчанию. Чтобы её включить:

#Откройте Редактор реестра (Win + R, введите regedit).
#Перейдите к ключу: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem
#Найдите параметр LongPathsEnabled:
#Если его нет, создайте новый параметр типа DWORD (32-бит).
#Установите значение 1 для включения поддержки длинных путей.
#Перезагрузите компьютер.
#После этого Windows сможет работать с путями длиной более 260 символов.

#Либо используем префикс \\?\
#В Python можно использовать префикс \\?\ перед путём, чтобы обойти ограничение на длину пути. 
#Этот префикс сообщает Windows, что путь является "длинным" и должен быть обработан без ограничений.
# Код с префиксом доступен тут - https://github.com/soulpastwk/share/blob/main/rename_new.py
