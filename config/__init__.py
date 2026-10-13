"""Конфігурація проєкту Learnova.

PyMySQL використовується як драйвер БД (заміна ``mysqlclient``, не потребує
компіляції на Windows). ``install_as_MySQLdb()`` підставляє його під ім'я
``MySQLdb``, яке очікує ``django.db.backends.mysql`` — викликати треба до
завантаження налаштувань із базою даних.
"""
import pymysql

pymysql.install_as_MySQLdb()
