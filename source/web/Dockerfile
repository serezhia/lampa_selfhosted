# Multi-stage build для Lampa Web с автоматическим клонированием из GitHub

# Stage 1: Build
FROM node:lts AS build

WORKDIR /app

# Клонируем оригинальный репозиторий lampa-source
ARG LAMPA_REPO=https://github.com/yumata/lampa-source.git
ARG LAMPA_BRANCH=main
ARG DOMAIN=example.com

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch ${LAMPA_BRANCH} ${LAMPA_REPO} .

# Копируем файлы патчей и build скрипт
COPY patches.json apply-modifications.js build.js site.webmanifest ./

# Устанавливаем зависимости
RUN npm install

# Заменяем placeholder на реальный домен
RUN sed -i "s/REPLACE_WITH_DOMAIN/${DOMAIN}/g" patches.json

# Применяем патчи к исходникам ПЕРЕД сборкой
RUN node apply-modifications.js

# Собираем проект (патчи уже применены к src файлам)
RUN node build.js

# Проверяем что сборка успешна
RUN if [ ! -d "build/github/lampa" ]; then \
    echo "❌ Build output not found!"; \
    ls -la build/ || true; \
    exit 1; \
    fi

# Проверяем что патчи применились

RUN echo "🔍 Checking if patches applied for domain: ${DOMAIN}" && \
    if grep -q "${DOMAIN}" build/github/lampa/app.min.js; then \
    echo "✅ Patches applied successfully!"; \
    grep -c "${DOMAIN}" build/github/lampa/app.min.js; \
    else \
    echo "❌ Patches NOT applied!"; \
    exit 1; \
    fi

# Создаем директорию для финальной сборки
RUN mkdir -p /build_output && \
    cp -r build/github/lampa/* /build_output/ && \
    mkdir -p /build_output/icons && \
    cp site.webmanifest /build_output/icons/

# Stage 2: Nginx
FROM nginx:alpine

# Удаляем дефолтные файлы nginx
RUN rm -rf /usr/share/nginx/html/*

# Копируем собранные файлы
WORKDIR /usr/share/nginx/html
COPY --from=build /build_output/ ./

# Создаем директории для плагинов (будут примонтированы через volume)
RUN mkdir -p /plugins/builtin /plugins/custom /usr/share/nginx/html/plugins

# Копируем entrypoint скрипт
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Добавляем скрипт для загрузки modification.js в index.html
# Вставляем тег <script> перед закрывающим </body>
RUN if [ -f index.html ]; then \
    sed -i 's|</body>|<script src="plugins/modification.js"></script>\n</body>|' index.html; \
    fi

EXPOSE 80

# Используем entrypoint для генерации манифеста плагинов
ENTRYPOINT ["/entrypoint.sh"]
