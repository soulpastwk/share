import os

# данный скрипт удаляет часть названия папок и файла во всех вложенных в директорию файлах
# в данном примере это - [SW.BAND]

# Укажите путь к корневой директории
root_dir = r"E:\полный путь\можно русскими"

def remove_prefix_in_directory(path):
    for dirpath, dirnames, filenames in os.walk(path, topdown=False):
        # Обрабатываем файлы
        for filename in filenames:
            if filename.startswith("[SW.BAND]"):
                old_file_path = os.path.join(dirpath, filename)
                new_file_name = filename.replace("[SW.BAND] ", "", 1)
                new_file_path = os.path.join(dirpath, new_file_name)
                os.rename(old_file_path, new_file_path)
                print(f"Файл переименован: {old_file_path} -> {new_file_path}")
        
        # Обрабатываем папки
        for dirname in dirnames:
            if dirname.startswith("[SW.BAND]"):
                old_dir_path = os.path.join(dirpath, dirname)
                new_dir_name = dirname.replace("[SW.BAND] ", "", 1)
                new_dir_path = os.path.join(dirpath, new_dir_name)
                os.rename(old_dir_path, new_dir_path)
                print(f"Папка переименована: {old_dir_path} -> {new_dir_path}")

# Запускаем функцию
remove_prefix_in_directory(root_dir)
