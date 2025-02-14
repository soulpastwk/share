# Замени тут что требуется убрать в данном примере это - [SW.BAND] - (квадратные скобки тоже заменяем)
# Например у нас есть папка - [SW.BAND] Курсы линукс - а нам надо следать просто Курсы линукс 
# Либо другое повторяющееся имя у папок и файлов

import os

# Укажите путь к корневой директории
root_dir = r"D:\Курсы"

def remove_prefix_in_directory(path):
    for dirpath, dirnames, filenames in os.walk(path, topdown=False):
        # Обрабатываем файлы
        for filename in filenames:
            if filename.startswith("[SW.BAND]"):
                old_file_path = os.path.join(dirpath, filename)
                new_file_name = filename.replace("[SW.BAND]", "", 1)
                new_file_path = os.path.join(dirpath, new_file_name)
                
                # Добавляем префикс \\?\ для длинных путей
                old_file_path = r"\\?\" + old_file_path
                new_file_path = r"\\?\" + new_file_path
                
                os.rename(old_file_path, new_file_path)
                print(f"Файл переименован: {old_file_path} -> {new_file_path}")
        
        # Обрабатываем папки
        for dirname in dirnames:
            if dirname.startswith("[SW.BAND]"):
                old_dir_path = os.path.join(dirpath, dirname)
                new_dir_name = dirname.replace("[SW.BAND]", "", 1)
                new_dir_path = os.path.join(dirpath, new_dir_name)
                
                # Добавляем префикс \\?\ для длинных путей
                old_dir_path = r"\\?\" + old_dir_path
                new_dir_path = r"\\?\" + new_dir_path
                
                os.rename(old_dir_path, new_dir_path)
                print(f"Папка переименована: {old_dir_path} -> {new_dir_path}")

# Запускаем функцию
remove_prefix_in_directory(root_dir)
