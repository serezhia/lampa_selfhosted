param (
    [string]$Domain = "l.serezhia.ru",
    [string]$Email = "",
    [string]$BotToken = "",
    [string]$BotName = "@my_lampa_bot",
    [string]$AdminPhones = ""
)

$ErrorActionPreference = "Stop"

Write-Host "Настройка Lampa Self-Hosted для Windows..." -ForegroundColor Cyan

# 1. Создание директорий
Write-Host "Создание директорий..."
$dirs = @(
    "data/certs/letsencrypt/live/$Domain",
    "data/certs/acme-challenge",
    "data/database",
    "data/transcoding",
    "data/library",
    "data/plugins",
    "data/nginx",
    "data/torrserver/config",
    "data/torrserver/cache",
    "data/jacred/config",
    "data/jacred/data"
)
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# 2. Генерация .env
Write-Host "Генерация .env..."
$jacredKey = -join ((33..126) | Get-Random -Count 32 | % {[char]$_})
$envContent = @"
DOMAIN=$Domain
BASE_URL=https://$Domain
TELEGRAM_BOT_TOKEN=$BotToken
TELEGRAM_BOT_NAME=$BotName
TELEGRAM_ADMIN_PHONES=$AdminPhones
JACRED_API_KEY=$jacredKey
LETSENCRYPT_EMAIL=$Email
USE_SSL=true
"@
Set-Content -Path ".env" -Value $envContent -Encoding UTF8

# 3. Настройка Nginx
Write-Host "Настройка Nginx..."
$nginxConf = Get-Content "source/nginx/nginx-ssl.example.conf" -Raw
$nginxConf = $nginxConf -replace "\{\{DOMAIN\}\}", $Domain
Set-Content -Path "data/nginx/lampa.conf" -Value $nginxConf -Encoding UTF8
 
# 4. Скачивание параметров TLS
Write-Host "Скачивание параметров TLS..."
if (-not (Test-Path "data/certs/letsencrypt/options-ssl-nginx.conf")) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf" -OutFile "data/certs/letsencrypt/options-ssl-nginx.conf"
}
if (-not (Test-Path "data/certs/letsencrypt/ssl-dhparams.pem")) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem" -OutFile "data/certs/letsencrypt/ssl-dhparams.pem"
}

# 5. Создание временного сертификата для запуска Nginx
Write-Host "Создание временного сертификата..."
if (-not (Test-Path "data/certs/letsencrypt/live/$Domain/fullchain.pem")) {
    docker compose run --rm --entrypoint openssl certbot req -x509 -nodes -newkey rsa:4096 -days 1 -keyout "/etc/letsencrypt/live/$Domain/privkey.pem" -out "/etc/letsencrypt/live/$Domain/fullchain.pem" -subj "/CN=localhost"
}

# 6. Запуск Nginx
Write-Host "Запуск Nginx..."
docker compose up -d nginx
Start-Sleep -Seconds 5

# 7. Получение реального сертификата Let's Encrypt
Write-Host "Получение сертификата Let's Encrypt..."
# Удаляем временные сертификаты
Remove-Item -Path "data/certs/letsencrypt/live/$Domain" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "data/certs/letsencrypt/archive/$Domain" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "data/certs/letsencrypt/renewal/$Domain.conf" -Force -ErrorAction SilentlyContinue

$emailArg = if ([string]::IsNullOrWhiteSpace($Email)) { "--register-unsafely-without-email" } else { "--email $Email" }

$cmd = "docker compose run --rm --entrypoint certbot certbot certonly --webroot -w /var/www/certbot $emailArg -d $Domain --rsa-key-size 4096 --agree-tos --force-renewal"
Invoke-Expression $cmd

# 8. Перезапуск и запуск всех контейнеров
Write-Host "Запуск всех сервисов..."
docker compose down
docker compose up -d --build

Write-Host "Готово! Lampa будет доступна по адресу https://$Domain" -ForegroundColor Green
Write-Host "Не забудьте пробросить порты 80 и 443 на роутере на IP вашей машины!" -ForegroundColor Yellow
