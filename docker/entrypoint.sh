#!/bin/bash
set -e

# Cria o .env a partir do .env.example se não existir
if [ ! -f /var/www/html/.env ]; then
    cp /var/www/html/.env.example /var/www/html/.env
fi

# Garante que os diretórios do framework existam
mkdir -p /var/www/html/storage/framework/views
mkdir -p /var/www/html/storage/framework/cache/data
mkdir -p /var/www/html/storage/framework/sessions
mkdir -p /var/www/html/storage/framework/testing
mkdir -p /var/www/html/bootstrap/cache
mkdir -p /var/log/supervisor

# Garante que as permissões estão corretas nos volumes montados
chown -R www-data:www-data /var/www/html/storage
chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache

# Gera a chave da aplicação se não existir
if [ -z "$APP_KEY" ]; then
    php artisan key:generate --force
fi

# Cria o link simbólico do storage
php artisan storage:link --force 2>/dev/null || true

# Aguarda o banco de dados ficar disponível
if [ "$DB_CONNECTION" = "mysql" ] || [ "$DB_CONNECTION" = "mariadb" ]; then
    echo "Aguardando banco de dados..."
    until php artisan db:monitor --max=1 2>/dev/null; do
        sleep 2
    done
fi

# Executa as migrations
php artisan migrate --force

# Limpa e otimiza os caches
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Iniciando servidores..."
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
