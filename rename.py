import os
# данный скрипт удаляет часть названия папок и файла во всех вложенных в директорию файлах
# в данном примере это - [BOOMINFO.RU]

# ЗАМЕНИ ТУТ - выдели всемте со скобками и нажми Ctrl+H - [BOOMINFO.RU]

# Укажите путь к корневой директории
root_dir = r"D:\Курсы Милла"

def remove_prefix_in_directory(path):
    for dirpath, dirnames, filenames in os.walk(path, topdown=False):
        # Обрабатываем файлы
        for filename in filenames:
            if filename.startswith("[BOOMINFO.RU]"):
                old_file_path = os.path.join(dirpath, filename)
                new_file_name = filename.replace("[BOOMINFO.RU]", "", 1)
                new_file_path = os.path.join(dirpath, new_file_name)
                os.rename(old_file_path, new_file_path)
                print(f"Файл переименован: {old_file_path} -> {new_file_path}")
        
        # Обрабатываем папки
        for dirname in dirnames:
            if dirname.startswith("[BOOMINFO.RU]"):
                old_dir_path = os.path.join(dirpath, dirname)
                new_dir_name = dirname.replace("[BOOMINFO.RU]", "", 1)
                new_dir_path = os.path.join(dirpath, new_dir_name)
                os.rename(old_dir_path, new_dir_path)
                print(f"Папка переименована: {old_dir_path} -> {new_dir_path}")

# Запускаем функцию
remove_prefix_in_directory(root_dir)
# Теперь внизу во вкладке TERMINAL нажми стрелочку вверх и Enter
# Если ничего не появилось то напечатай .\rename.py