@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Проверка на запуск от имени администратора
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Этот скрипт требует прав администратора. Пожалуйста, запустите его от имени администратора.
    pause
    exit /b
)

:: Установка Chocolatey, если не установлен
where choco >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Устанавливаем Chocolatey...
    @powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
) ELSE (
    echo Chocolatey уже установлен.
)

:: Обновление Chocolatey
echo Обновляем Chocolatey...
choco upgrade chocolatey -y

:: Установка Git
echo Устанавливаем Git...
choco install git -y --params "/GitAndUnixToolsOnPath"

:: Установка Node.js LTS
echo Устанавливаем Node.js...
choco install nodejs-lts -y

:: Установка Python
echo Устанавливаем Python...
choco install python -y

:: Установка Docker Desktop
echo Устанавливаем Docker Desktop...
choco install docker-desktop -y

:: Опционально: Установка Visual Studio Code
set /p install_vscode=Хотите установить Visual Studio Code? (y/n):
if /I "%install_vscode%"=="Y" (
    echo Устанавливаем Visual Studio Code...
    choco install vscode -y
) else (
    echo Пропускаем установку Visual Studio Code.
)

:: Опционально: Установка Python-пакетов
set /p install_packages=Хотите установить Python-пакеты из requirements.txt? (y/n):
if /I "%install_packages%"=="Y" (
    if exist requirements.txt (
        echo Устанавливаем Python-пакеты...
        python -m pip install --upgrade pip
        python -m pip install -r requirements.txt
    ) else (
        echo Файл requirements.txt не найден в текущей директории.
    )
) else (
    echo Пропускаем установку Python-пакетов.
)

echo Настройка рабочего окружения завершена.
echo Если было предложено, перезагрузите компьютер для завершения установки.
pause
