@echo off
rd staticfiles /q /s
python manage.py collectstatic