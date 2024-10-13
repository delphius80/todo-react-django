# Многоступенчатая сборка

# Этап 1: Сборка React-приложения
FROM node:18-alpine AS frontend-build

# Установка рабочей директории
WORKDIR /app/frontend

# Копирование package.json и package-lock.json (если есть)
COPY frontend/package*.json ./

# Установка зависимостей
RUN npm install --production

# Копирование исходного кода
COPY frontend/ ./

# Сборка React-приложения
RUN npm run build

# Этап 2: Сборка Django-приложения
FROM python:3.11-slim AS backend-build

# Установка зависимостей системы
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Установка pip и обновление
RUN pip install --upgrade pip

# Установка зависимостей Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Создание рабочей директории
WORKDIR /app/backend

# Копирование Django-приложения
COPY backend/ ./

# Копирование собранного React-приложения из предыдущего этапа
COPY --from=frontend-build /app/frontend/build/ /app/backend/frontend/build/

# Сборка статических файлов
RUN python manage.py collectstatic --noinput

# Этап 3: Финальный образ
FROM python:3.11-slim

# Установка зависимостей системы
RUN apt-get update && apt-get install -y \
    libpq5 \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Установка зависимостей Python из backend-build
COPY --from=backend-build /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Копирование исполняемых файлов (например, gunicorn)
COPY --from=backend-build /usr/local/bin/gunicorn /usr/local/bin/gunicorn

# Копирование Django-приложения
COPY --from=backend-build /app/backend /app/backend

# Установка переменных окружения
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Установка рабочей директории
WORKDIR /app/backend

# Команда для запуска приложения
CMD ["gunicorn", "todoproject.wsgi:application", "--bind", "0.0.0.0:8000"]
