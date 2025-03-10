#!/usr/bin/env python3 
# -*- coding: utf-8 -*-

import os
import pwd
import grp

def get_permissions(file):
    try:
        if os.path.islink(file):
            # Пропуск символических ссылок
            return None, None, None
        stat_info = os.stat(file)
        user = pwd.getpwuid(stat_info.st_uid).pw_name
        group = grp.getgrgid(stat_info.st_gid).gr_name
        permissions = oct(stat_info.st_mode)[-3:]
        return user, group, permissions
    except FileNotFoundError:
        return None, None, None
    except OSError as e:
        # Логирование ошибок других типов
        return None, None, None

def generate_matrix(start_path):
    matrix = {}
    error_logs = "/home/error_logs_info_users"
    with open(error_logs, 'w') as error_log:
        for root, dirs, files in os.walk(start_path):
            for name in dirs + files:
                file_path = os.path.join(root, name)
                user, group, permissions = get_permissions(file_path)
                if user is not None and group is not None and permissions is not None:
                    matrix[file_path] = {'user': user, 'group': group, 'permissions': permissions}
                else:
                    # Логирование ошибок
                    error_log.write(f"Ошибка при обработке файла {file_path}\n")
    return matrix

start_path = '/'
matrix = generate_matrix(start_path)

# Вывод результатов в удобочитаемом формате и сохранение в файл
output_file = "/home/info_matrix"
with open(output_file, 'w') as f:
    for file_path, info in matrix.items():
        f.write(f"{file_path}: User={info['user']}, Group={info['group']}, Permissions={info['permissions']}\n")

print(f"Результаты записаны в файл {output_file}")
print("Ошибки записаны в файл /home/error_logs_info_users")
print("Некоторые файлы и ссылки в системе могут быть недоступны или уже удалены на момент выполнения скрипта. Например, файлы в каталоге /run и другие временные файлы могут исчезнуть или быть перемещены.")
