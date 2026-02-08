#!/bin/bash
set -e

# =========================================================================
# Lampa Self-Hosted — Unified Installer
# =========================================================================
# Usage:
#   Install:      curl -fsSL https://raw.githubusercontent.com/serezhia/lampa_selfhosted/main/install.sh | bash
#   Install (branch): curl ... | bash -s -- --branch dev
#   Update:       ./install.sh --update
#   Update (branch): ./install.sh --update --branch dev
#   Uninstall:    ./install.sh --uninstall
#   Verbose:      ./install.sh --verbose
# =========================================================================

VERSION="1.0.0"

# If running from pipe, download to temp file and re-execute
if [ ! -t 0 ] && [ -z "$LAMPA_INSTALLER_REEXEC" ]; then
    TEMP_SCRIPT=$(mktemp /tmp/lampa-install.XXXXXX.sh)
    curl -fsSL https://raw.githubusercontent.com/serezhia/lampa_selfhosted/main/install.sh > "$TEMP_SCRIPT"
    chmod +x "$TEMP_SCRIPT"
    export LAMPA_INSTALLER_REEXEC=1
    export LAMPA_TEMP_SCRIPT="$TEMP_SCRIPT"
    exec bash "$TEMP_SCRIPT" "$@" </dev/tty
fi

# Cleanup temp file on exit if we were re-executed
if [ -n "$LAMPA_TEMP_SCRIPT" ] && [ -f "$LAMPA_TEMP_SCRIPT" ]; then
    trap 'rm -f "$LAMPA_TEMP_SCRIPT"' EXIT
fi

REPO_URL="https://github.com/serezhia/lampa_selfhosted.git"
INSTALL_DIR="/opt/lampa"
BRANCH="main"
VERBOSE=false
MODE="install"  # install, update, uninstall
AUTO_UPDATE_ENABLED=false
CRONTAB_AVAILABLE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
debug() { $VERBOSE && echo -e "${CYAN}[DEBUG]${NC} $*" || true; }

# =========================================================================
# Check prerequisites
# =========================================================================
check_prerequisites() {
    info "Checking prerequisites..."

    debug "Checking git..."
    if ! command -v git &>/dev/null; then
        err "git is not installed. Install it first: apt install git"
        exit 1
    fi
    debug "git: $(git --version)"

    debug "Checking docker..."
    if ! command -v docker &>/dev/null; then
        err "Docker is not installed."
        echo ""
        echo "Install Docker:"
        echo "  curl -fsSL https://get.docker.com | sh"
        echo "  sudo usermod -aG docker \$USER"
        exit 1
    fi
    debug "docker: $(docker --version)"

    debug "Checking docker compose..."
    if ! docker compose version &>/dev/null; then
        err "Docker Compose V2 is not available."
        echo "Upgrade Docker or install docker-compose-plugin."
        exit 1
    fi
    debug "docker compose: $(docker compose version)"

    # Check for crontab availability
    debug "Checking crontab..."
    if command -v crontab &>/dev/null; then
        # Also check if we can actually use it
        if crontab -l &>/dev/null || [ $? -eq 1 ]; then
            # Exit code 1 means "no crontab for user" which is fine
            CRONTAB_AVAILABLE=true
            debug "crontab: available"
        else
            CRONTAB_AVAILABLE=false
            debug "crontab: command exists but not accessible"
        fi
    else
        CRONTAB_AVAILABLE=false
        debug "crontab: not installed"
    fi

    ok "All prerequisites met"
}

# =========================================================================
# Check crontab and offer alternatives
# =========================================================================
check_autoupdate_support() {
    if [ "$CRONTAB_AVAILABLE" = "true" ]; then
        return 0
    fi
    
    warn "Crontab is not available on this system"
    echo ""
    echo "Auto-update alternatives:"
    echo "  1. Install cron: apt install cron (Debian/Ubuntu)"
    echo "  2. Use systemd timer (see docs)"
    echo "  3. Run './install.sh --update' manually"
    echo ""
    return 1
}

# =========================================================================
# Check for existing configuration
# =========================================================================
load_existing_config() {
    if [ -f "$INSTALL_DIR/.env" ]; then
        info "Found existing configuration in $INSTALL_DIR/.env"
        source "$INSTALL_DIR/.env"
        
        # Map to INPUT_* variables
        INPUT_DOMAIN="$DOMAIN"
        INPUT_EMAIL="$LETSENCRYPT_EMAIL"
        INPUT_TG_TOKEN="$TELEGRAM_BOT_TOKEN"
        INPUT_TG_BOT_NAME="$TELEGRAM_BOT_NAME"
        INPUT_ADMIN_PHONES="$TELEGRAM_ADMIN_PHONES"
        
        if [ "$USE_SSL" = "true" ]; then
            PROTOCOL="https"
        else
            PROTOCOL="http"
        fi
        
        echo ""
        info "Existing configuration:"
        echo "  Domain:     ${DOMAIN:-<not set>}"
        echo "  URL:        $PROTOCOL://$DOMAIN"
        echo "  HTTPS:      ${USE_SSL:-false}"
        echo "  Jackett:    ${JACKETT_API_KEY:+<configured>}${JACKETT_API_KEY:-<not set>}"
        echo ""
        
        read -rp "$(echo -e "${YELLOW}Use existing configuration?${NC} (Y/n): ")" USE_EXISTING < /dev/tty
        USE_EXISTING="${USE_EXISTING,,}"
        
        if [ "$USE_EXISTING" != "n" ] && [ "$USE_EXISTING" != "no" ]; then
            ok "Using existing configuration"
            return 0  # Use existing
        fi
    fi
    return 1  # Need new config
}

# =========================================================================
# Interactive setup — ask user for config values
# =========================================================================
ask_config() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Lampa Self-Hosted — Configuration${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""

    # Domain
    read -rp "$(echo -e "${YELLOW}Domain${NC} (e.g. lampa.example.com): ")" INPUT_DOMAIN < /dev/tty
    if [ -z "$INPUT_DOMAIN" ]; then
        err "Domain is required"
        exit 1
    fi

    # Email for Let's Encrypt
    read -rp "$(echo -e "${YELLOW}Email for Let's Encrypt${NC} (optional, press Enter to skip): ")" INPUT_EMAIL < /dev/tty

    # Telegram bot token
    read -rp "$(echo -e "${YELLOW}Telegram Bot Token${NC} (from @BotFather, press Enter to skip): ")" INPUT_TG_TOKEN < /dev/tty

    # Telegram bot name (for display in auth screen)
    if [ -n "$INPUT_TG_TOKEN" ]; then
        read -rp "$(echo -e "${YELLOW}Telegram Bot Name${NC} (e.g. @mybot, press Enter to skip): ")" INPUT_TG_BOT_NAME < /dev/tty
        # Add @ prefix if missing
        if [ -n "$INPUT_TG_BOT_NAME" ] && [[ "$INPUT_TG_BOT_NAME" != @* ]]; then
            INPUT_TG_BOT_NAME="@$INPUT_TG_BOT_NAME"
        fi

        # Admin phone numbers
        echo ""
        echo -e "${CYAN}Admin users (optional):${NC}"
        echo "  Enter phone numbers of admin users (comma-separated)."
        echo "  Admins can manage notices and see all users."
        echo "  Format: +79001234567,+79007654321"
        read -rp "$(echo -e "${YELLOW}Admin phones${NC} (press Enter to skip): ")" INPUT_ADMIN_PHONES < /dev/tty
    fi

    # Use HTTPS?
    echo ""
    read -rp "$(echo -e "${YELLOW}Enable HTTPS with Let's Encrypt?${NC} (y/N): ")" INPUT_HTTPS < /dev/tty
    INPUT_HTTPS="${INPUT_HTTPS,,}" # lowercase

    # Protocol
    if [ "$INPUT_HTTPS" = "y" ] || [ "$INPUT_HTTPS" = "yes" ]; then
        PROTOCOL="https"
        USE_SSL="true"
    else
        PROTOCOL="http"
        USE_SSL="false"
    fi

    echo ""
    info "Configuration summary:"
    echo "  Domain:     $INPUT_DOMAIN"
    echo "  URL:        $PROTOCOL://$INPUT_DOMAIN"
    echo "  Email:      ${INPUT_EMAIL:-<not set>}"
    echo "  Telegram:   ${INPUT_TG_TOKEN:+<set>}${INPUT_TG_TOKEN:-<not set>}"
    echo "  Bot name:   ${INPUT_TG_BOT_NAME:-<not set>}"
    echo "  Admins:     ${INPUT_ADMIN_PHONES:-<not set>}"
    echo "  HTTPS:      $USE_SSL"
    echo ""
    read -rp "Continue? (Y/n): " CONFIRM < /dev/tty
    CONFIRM="${CONFIRM,,}"
    if [ "$CONFIRM" = "n" ] || [ "$CONFIRM" = "no" ]; then
        echo "Aborted."
        exit 0
    fi
    
    # Mark that we need to write new .env
    WRITE_NEW_ENV=true
}

# =========================================================================
# Clone or update repository
# =========================================================================
setup_repo() {
    if [ -d "$INSTALL_DIR/.git" ]; then
        # Already a git repo - just update
        info "Updating repository..."
        cd "$INSTALL_DIR"
        debug "Running: git fetch origin"
        git fetch origin
        debug "Running: git reset --hard origin/$BRANCH"
        git reset --hard "origin/$BRANCH"
        ok "Repository updated"
    elif [ -d "$INSTALL_DIR" ]; then
        # Directory exists but not a git repo
        # Preserve user data and initialize git
        info "Directory exists, preserving data and initializing git..."
        
        # List of directories/files to preserve (new data/ structure)
        local preserve_dirs="data"
        local preserve_files=".env"
        
        # Create temp backup
        local backup_dir=$(mktemp -d /tmp/lampa-backup.XXXXXX)
        debug "Backup dir: $backup_dir"
        
        # Backup preserved directories
        for dir in $preserve_dirs; do
            if [ -d "$INSTALL_DIR/$dir" ]; then
                debug "Backing up: $dir"
                mkdir -p "$backup_dir/$(dirname $dir)"
                cp -a "$INSTALL_DIR/$dir" "$backup_dir/$dir"
            fi
        done
        
        # Backup preserved files
        for file in $preserve_files; do
            if [ -f "$INSTALL_DIR/$file" ]; then
                debug "Backing up: $file"
                cp -a "$INSTALL_DIR/$file" "$backup_dir/$file"
            fi
        done
        
        # Exit the directory before removing it!
        cd /tmp
        
        # Remove old directory and clone fresh
        debug "Removing old directory..."
        rm -rf "$INSTALL_DIR"
        
        debug "Cloning repository..."
        git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
        
        # Restore preserved data
        info "Restoring preserved data..."
        for dir in $preserve_dirs; do
            if [ -d "$backup_dir/$dir" ]; then
                debug "Restoring: $dir"
                mkdir -p "$INSTALL_DIR/$(dirname $dir)"
                cp -a "$backup_dir/$dir" "$INSTALL_DIR/$dir"
            fi
        done
        
        for file in $preserve_files; do
            if [ -f "$backup_dir/$file" ]; then
                debug "Restoring: $file"
                cp -a "$backup_dir/$file" "$INSTALL_DIR/$file"
            fi
        done
        
        # Cleanup backup
        rm -rf "$backup_dir"
        
        cd "$INSTALL_DIR"
        ok "Repository initialized with preserved data"
    else
        # Fresh install
        info "Cloning repository..."
        debug "Creating directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
        debug "Running: git clone --depth 1 --branch $BRANCH $REPO_URL $INSTALL_DIR"
        git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
        ok "Repository cloned"
    fi
}

# =========================================================================
# Generate Jackett API key
# =========================================================================
generate_jackett_key() {
    # Generate a random 32-character hex string
    if command -v openssl &>/dev/null; then
        JACKETT_API_KEY=$(openssl rand -hex 16)
    else
        JACKETT_API_KEY=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1)
    fi
    debug "Generated JACKETT_API_KEY: $JACKETT_API_KEY"
}

# =========================================================================
# Initialize Jackett config with pre-generated API key
# =========================================================================
init_jackett_config() {
    info "Initializing Jackett configuration..."
    
    local jackett_config_dir="$INSTALL_DIR/data/jackett/config/Jackett"
    local indexers_dir="$jackett_config_dir/Indexers"
    local config_file="$jackett_config_dir/ServerConfig.json"
    local template_file="$INSTALL_DIR/source/jackett/ServerConfig.json.template"
    local source_indexers="$INSTALL_DIR/source/jackett/indexers"
    
    mkdir -p "$jackett_config_dir"
    mkdir -p "$indexers_dir"
    
    # Only create config if doesn't exist
    if [ ! -f "$config_file" ]; then
        debug "Creating Jackett ServerConfig.json from template"
        
        # Generate instance ID
        local instance_id
        instance_id=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen 2>/dev/null || echo "lampa-$(date +%s)")
        
        # Copy template and replace placeholders
        if [ -f "$template_file" ]; then
            sed -e "s/{{JACKETT_API_KEY}}/$JACKETT_API_KEY/g" \
                -e "s/{{INSTANCE_ID}}/$instance_id/g" \
                "$template_file" > "$config_file"
            ok "Jackett config created from template"
        else
            err "Jackett template not found: $template_file"
            return 1
        fi
    else
        info "Jackett config already exists, extracting API key..."
        # Extract existing API key from config
        if command -v jq &>/dev/null; then
            JACKETT_API_KEY=$(jq -r '.APIKey' "$config_file")
        else
            JACKETT_API_KEY=$(grep -o '"APIKey"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" | sed 's/.*"\([^"]*\)"$/\1/')
        fi
        debug "Extracted existing JACKETT_API_KEY: $JACKETT_API_KEY"
        
        # Migrate: add BasePathOverride if missing or null
        local existing_base_path
        if command -v jq &>/dev/null; then
            existing_base_path=$(jq -r '.BasePathOverride // empty' "$config_file")
        else
            existing_base_path=$(grep -o '"BasePathOverride"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" | sed 's/.*"\([^"]*\)"$/\1/')
        fi
        
        if [ -z "$existing_base_path" ] || [ "$existing_base_path" = "null" ]; then
            info "Migrating Jackett config: adding BasePathOverride..."
            if command -v jq &>/dev/null; then
                local tmp_file
                tmp_file=$(mktemp)
                jq '.BasePathOverride = "/jacadmin"' "$config_file" > "$tmp_file"
                mv "$tmp_file" "$config_file"
            else
                sed -i 's/"BasePathOverride"[[:space:]]*:[[:space:]]*null/"BasePathOverride": "\/jacadmin"/g' "$config_file"
            fi
            ok "Jackett BasePathOverride migrated"
        fi
        
        ok "Using existing Jackett API key"
    fi
    
    # Copy pre-configured indexers (if any)
    if [ -d "$source_indexers" ]; then
        local copied=0
        for indexer_file in "$source_indexers"/*.json; do
            [ -f "$indexer_file" ] || continue
            local filename=$(basename "$indexer_file")
            local dest_file="$indexers_dir/$filename"
            
            # Don't overwrite existing indexers
            if [ ! -f "$dest_file" ]; then
                cp "$indexer_file" "$dest_file"
                debug "Copied indexer: $filename"
                ((copied++))
            fi
        done
        
        if [ $copied -gt 0 ]; then
            ok "Copied $copied pre-configured indexer(s)"
        fi
    fi
    
    # Ensure init-indexers.sh is executable
    local init_script="$INSTALL_DIR/source/jackett/init-indexers.sh"
    if [ -f "$init_script" ]; then
        chmod +x "$init_script"
        debug "Made init-indexers.sh executable"
    fi
}

# =========================================================================
# Write .env file
# =========================================================================
write_env() {
    info "Writing .env file..."
    debug "Writing to: $INSTALL_DIR/.env"
    debug "DOMAIN=$INPUT_DOMAIN"
    debug "BASE_URL=$PROTOCOL://$INPUT_DOMAIN"
    debug "USE_SSL=$USE_SSL"
    debug "JACKETT_API_KEY=$JACKETT_API_KEY"

    cat > "$INSTALL_DIR/.env" <<EOF
# Lampa Self-Hosted configuration
# Generated by install.sh on $(date -Iseconds)

# Domain
DOMAIN=${INPUT_DOMAIN}

# Base URL (used by the server)
BASE_URL=${PROTOCOL}://${INPUT_DOMAIN}

# Telegram Bot Token
TELEGRAM_BOT_TOKEN=${INPUT_TG_TOKEN}

# Telegram Bot Name (for display in auth screen)
TELEGRAM_BOT_NAME=${INPUT_TG_BOT_NAME}

# Admin phone numbers (comma-separated, e.g. +79001234567,+79007654321)
TELEGRAM_ADMIN_PHONES=${INPUT_ADMIN_PHONES}

# Jackett API Key (auto-generated, do not share!)
JACKETT_API_KEY=${JACKETT_API_KEY}

# Let's Encrypt email
LETSENCRYPT_EMAIL=${INPUT_EMAIL}

# HTTPS enabled
USE_SSL=${USE_SSL}
EOF

    ok ".env written"
}

# =========================================================================
# Generate nginx config from template
# =========================================================================
generate_nginx_conf() {
    local domain="${1:-$INPUT_DOMAIN}"
    local ssl="${2:-$USE_SSL}"
    
    info "Generating nginx config for $domain..."
    debug "Config path: $INSTALL_DIR/data/nginx/lampa.conf"
    debug "SSL enabled: $ssl"

    mkdir -p "$INSTALL_DIR/data/nginx"

    local template_file
    if [ "$ssl" = "true" ]; then
        template_file="$INSTALL_DIR/source/nginx/nginx-ssl.example.conf"
    else
        template_file="$INSTALL_DIR/source/nginx/nginx-http.example.conf"
    fi

    if [ ! -f "$template_file" ]; then
        err "Nginx template not found: $template_file"
        exit 1
    fi

    # Copy template and replace {{DOMAIN}} placeholder
    sed "s/{{DOMAIN}}/$domain/g" "$template_file" > "$INSTALL_DIR/data/nginx/lampa.conf"

    ok "nginx config generated from template"
}

# =========================================================================
# Init Let's Encrypt certificates
# =========================================================================
init_ssl() {
    if [ "$USE_SSL" != "true" ]; then
        info "Skipping SSL setup (HTTP mode)"
        return
    fi

    info "Setting up Let's Encrypt certificates..."
    debug "Domain: $INPUT_DOMAIN"
    debug "Email: ${INPUT_EMAIL:-<none>}"

    local data_path="$INSTALL_DIR/data/certs"
    local cert_path="$data_path/letsencrypt/live/$INPUT_DOMAIN"
    local conf_dir="$INSTALL_DIR/data/certs/letsencrypt"

    # Check if valid Let's Encrypt certificate already exists
    if [ -f "$cert_path/fullchain.pem" ] && [ -f "$cert_path/privkey.pem" ]; then
        # Check if it's a real cert (not self-signed) by looking for renewal config
        if [ -f "$conf_dir/renewal/$INPUT_DOMAIN.conf" ]; then
            info "Valid Let's Encrypt certificate found, skipping certificate setup"
            ok "Using existing SSL certificates"
            return
        fi
    fi

    # Download TLS parameters if needed
    if [ ! -e "$data_path/letsencrypt/options-ssl-nginx.conf" ] || [ ! -e "$data_path/letsencrypt/ssl-dhparams.pem" ]; then
        info "Downloading recommended TLS parameters..."
        debug "Downloading options-ssl-nginx.conf"
        mkdir -p "$data_path/letsencrypt"
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf \
            > "$data_path/letsencrypt/options-ssl-nginx.conf"
        debug "Downloading ssl-dhparams.pem"
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem \
            > "$data_path/letsencrypt/ssl-dhparams.pem"
    fi

    # Create dummy certificate so nginx can start
    info "Creating temporary self-signed certificate..."
    local cert_path="$data_path/letsencrypt/live/$INPUT_DOMAIN"
    # Create dummy certificate so nginx can start
    info "Creating temporary self-signed certificate..."
    debug "Certificate path: $cert_path"
    mkdir -p "$cert_path"

    if [ ! -f "$cert_path/fullchain.pem" ]; then
        debug "Generating self-signed certificate"
        docker compose run --rm --entrypoint "\
            openssl req -x509 -nodes -newkey rsa:4096 -days 1 \
            -keyout '/etc/letsencrypt/live/$INPUT_DOMAIN/privkey.pem' \
            -out '/etc/letsencrypt/live/$INPUT_DOMAIN/fullchain.pem' \
            -subj '/CN=localhost'" certbot
    fi

    # Cleanup old duplicate certbot entries (domain-0001, domain-0002, etc.)
    # but keep the main domain folder so nginx can start
    info "Cleaning up old certificate duplicates..."
    if [ -n "$INPUT_DOMAIN" ] && [ -d "$conf_dir" ]; then
        rm -rf "$conf_dir/live/$INPUT_DOMAIN"-0*
        rm -rf "$conf_dir/archive/$INPUT_DOMAIN"-0*
        rm -f "$conf_dir/renewal/$INPUT_DOMAIN"-0*.conf
    fi

    # Start nginx with dummy cert
    info "Starting nginx..."
    docker compose up --force-recreate -d nginx

    # Wait for nginx to be ready
    sleep 2

    # Now remove the temporary certificate so certbot can create a proper one
    # nginx keeps the cert in memory, so it continues to work
    info "Removing temporary certificate for certbot..."
    rm -rf "$conf_dir/live/$INPUT_DOMAIN"
    rm -rf "$conf_dir/archive/$INPUT_DOMAIN"
    rm -f "$conf_dir/renewal/$INPUT_DOMAIN.conf"

    # Request real certificate
    info "Requesting Let's Encrypt certificate..."
    local email_arg=""
    if [ -n "$INPUT_EMAIL" ]; then
        email_arg="--email $INPUT_EMAIL"
    else
        email_arg="--register-unsafely-without-email"
    fi

    docker compose run --rm --entrypoint "\
        certbot certonly --webroot -w /var/www/certbot \
        $email_arg \
        -d $INPUT_DOMAIN \
        --rsa-key-size 4096 \
        --agree-tos \
        --force-renewal" certbot

    # Restart nginx to load new certs
    docker compose restart nginx

    ok "SSL certificates obtained"
}

# =========================================================================
# Create data directories
# =========================================================================
create_dirs() {
    info "Creating data directories..."
    debug "Creating: $INSTALL_DIR/data/certs/letsencrypt"
    mkdir -p "$INSTALL_DIR/data/certs/letsencrypt"
    debug "Creating: $INSTALL_DIR/data/certs/acme-challenge"
    mkdir -p "$INSTALL_DIR/data/certs/acme-challenge"
    debug "Creating: $INSTALL_DIR/data/database"
    mkdir -p "$INSTALL_DIR/data/database"
    debug "Creating: $INSTALL_DIR/data/transcoding"
    mkdir -p "$INSTALL_DIR/data/transcoding"
    debug "Creating: $INSTALL_DIR/data/plugins"
    mkdir -p "$INSTALL_DIR/data/plugins"
    debug "Creating: $INSTALL_DIR/data/jackett/config"
    mkdir -p "$INSTALL_DIR/data/jackett/config"
    debug "Creating: $INSTALL_DIR/data/jackett/downloads"
    mkdir -p "$INSTALL_DIR/data/jackett/downloads"
    debug "Creating: $INSTALL_DIR/data/nginx"
    mkdir -p "$INSTALL_DIR/data/nginx"
    debug "Creating: $INSTALL_DIR/data/torrserver/config"
    mkdir -p "$INSTALL_DIR/data/torrserver/config"
    debug "Creating: $INSTALL_DIR/data/torrserver/cache"
    mkdir -p "$INSTALL_DIR/data/torrserver/cache"
    ok "Directories created"
}

# =========================================================================
# Build and start
# =========================================================================
build_and_start() {
    info "Building and starting containers (this may take a few minutes)..."
    cd "$INSTALL_DIR"
    debug "Running: docker compose down --remove-orphans"
    docker compose down --remove-orphans 2>/dev/null || true
    debug "Running: docker compose up -d --build"
    docker compose up -d --build
    ok "Containers started"

    # Cleanup old images
    debug "Running: docker image prune -f"
    docker image prune -f 2>/dev/null || true
}

# =========================================================================
# Setup auto-update via cron
# =========================================================================
setup_autoupdate() {
    # Check if crontab is available
    if [ "$CRONTAB_AVAILABLE" != "true" ]; then
        echo ""
        warn "Auto-update is not available (crontab not installed)"
        echo ""
        echo "To enable auto-update, install cron:"
        echo "  Debian/Ubuntu: sudo apt install cron"
        echo "  Alpine:        sudo apk add dcron"
        echo "  RHEL/CentOS:   sudo yum install cronie"
        echo ""
        echo "Or run updates manually: ./install.sh --update"
        return
    fi

    echo ""
    read -rp "$(echo -e "${YELLOW}Enable auto-update?${NC} Checks for updates every 5 minutes (y/N): ")" AUTO_UPDATE < /dev/tty
    AUTO_UPDATE="${AUTO_UPDATE,,}"

    if [ "$AUTO_UPDATE" != "y" ] && [ "$AUTO_UPDATE" != "yes" ]; then
        info "Auto-update skipped"
        return
    fi

    info "Setting up auto-update cron job..."

    # Create update wrapper script that calls install.sh --update
    cat > "$INSTALL_DIR/cron-update.sh" <<'CRONEOF'
#!/bin/bash
# Auto-update wrapper for cron
LOG_FILE="/var/log/lampa-update.log"
INSTALL_DIR="/opt/lampa"

log() {
    echo "[$(date -Iseconds)] $*" >> "$LOG_FILE"
}

cd "$INSTALL_DIR" || exit 1

# Run update silently
if "$INSTALL_DIR/install.sh" --update --quiet >> "$LOG_FILE" 2>&1; then
    log "Update check completed"
else
    log "Update failed with exit code $?"
fi
CRONEOF
    chmod +x "$INSTALL_DIR/cron-update.sh"

    # Add cron job (every 5 minutes)
    local cron_line="*/5 * * * * $INSTALL_DIR/cron-update.sh"
    
    # Remove old entries if exist, then add new
    (crontab -l 2>/dev/null | grep -v "$INSTALL_DIR" | grep -v "lampa"; echo "$cron_line") | crontab -

    AUTO_UPDATE_ENABLED=true
    ok "Auto-update enabled (every 5 minutes)"
    info "Update log: /var/log/lampa-update.log"
}

# =========================================================================
# Disable auto-update
# =========================================================================
disable_autoupdate() {
    if [ "$CRONTAB_AVAILABLE" = "true" ]; then
        info "Removing auto-update cron job..."
        (crontab -l 2>/dev/null | grep -v "$INSTALL_DIR" | grep -v "lampa") | crontab - 2>/dev/null || true
        ok "Auto-update disabled"
    fi
}

# =========================================================================
# Uninstall
# =========================================================================
do_uninstall() {
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════╗${NC}"
    echo -e "${RED}║     Lampa Self-Hosted Uninstaller        ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}This will COMPLETELY remove:${NC}"
    echo "  - All Lampa Docker containers (lampa-*)"
    echo "  - All Lampa Docker images"
    echo "  - All Lampa Docker volumes"
    echo "  - All Lampa Docker networks"
    echo "  - Cron job for auto-updates"
    echo "  - Directory: $INSTALL_DIR"
    echo "  - Update log: /var/log/lampa-update.log"
    echo ""
    echo -e "${YELLOW}Optionally:${NC}"
    echo "  - ALL unused Docker data (containers, images, volumes, networks)"
    echo ""
    echo -e "${GREEN}This will NOT remove:${NC}"
    echo "  - Docker itself"
    echo "  - Running containers from other projects"
    echo ""

    read -rp "$(echo -e "${RED}Are you sure you want to uninstall? Type 'yes' to confirm: ${NC}")" CONFIRM < /dev/tty
    if [ "$CONFIRM" != "yes" ]; then
        echo "Aborted."
        exit 0
    fi

    echo ""

    # Stop and remove containers with volumes
    if [ -d "$INSTALL_DIR" ]; then
        info "Stopping and removing containers..."
        cd "$INSTALL_DIR"
        docker compose down --volumes --remove-orphans --rmi local 2>/dev/null || true
    fi

    # Remove ALL lampa-related containers (even if orphaned)
    info "Removing all Lampa containers..."
    docker ps -a --filter "name=lampa" -q 2>/dev/null | xargs -r docker rm -f 2>/dev/null || true

    # Remove ALL lampa-related images
    info "Removing all Lampa images..."
    docker images --filter "reference=lampa-*" -q 2>/dev/null | xargs -r docker rmi -f 2>/dev/null || true
    docker images --filter "reference=*lampa*" -q 2>/dev/null | xargs -r docker rmi -f 2>/dev/null || true
    
    # Remove specific images
    docker rmi lampa-frontend:local 2>/dev/null || true
    docker rmi lampa-server:local 2>/dev/null || true

    # Remove ALL lampa-related volumes
    info "Removing all Lampa volumes..."
    docker volume ls --filter "name=lampa" -q 2>/dev/null | xargs -r docker volume rm -f 2>/dev/null || true

    # Remove ALL lampa-related networks
    info "Removing all Lampa networks..."
    docker network ls --filter "name=lampa" -q 2>/dev/null | xargs -r docker network rm 2>/dev/null || true

    # Ask about aggressive cleanup
    echo ""
    read -rp "$(echo -e "${YELLOW}Also run docker system prune to clean ALL unused Docker data?${NC} (y/N): ")" PRUNE_ALL < /dev/tty
    PRUNE_ALL="${PRUNE_ALL,,}"
    
    if [ "$PRUNE_ALL" = "y" ] || [ "$PRUNE_ALL" = "yes" ]; then
        warn "Running docker system prune --all --volumes..."
        warn "This will remove ALL unused containers, networks, images, and volumes!"
        docker system prune --all --volumes --force
        ok "Docker system pruned"
    else
        # Just prune dangling images
        info "Pruning dangling images..."
        docker image prune -f 2>/dev/null || true
    fi

    # Remove cron job
    disable_autoupdate

    # Remove log
    info "Removing update log..."
    rm -f /var/log/lampa-update.log 2>/dev/null || true

    # Remove temp files
    info "Removing temp files..."
    rm -f /tmp/lampa-install.*.sh 2>/dev/null || true

    # Remove directory
    info "Removing $INSTALL_DIR..."
    if [ -d "$INSTALL_DIR" ]; then
        cd /
        rm -rf "$INSTALL_DIR"
        ok "Directory removed"
    fi

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Lampa has been uninstalled!          ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
    echo ""
}

# =========================================================================
# Update mode (non-interactive)
# =========================================================================
do_update() {
    info "Running update..."
    cd "$INSTALL_DIR"

    debug "Fetching from origin/$BRANCH"
    git fetch origin "$BRANCH"

    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse "origin/$BRANCH")
    debug "Local commit: $LOCAL"
    debug "Remote commit: $REMOTE"

    if [ "$LOCAL" = "$REMOTE" ]; then
        ok "Already up to date ($LOCAL)"
        return
    fi

    info "Updating $LOCAL -> $REMOTE"
    debug "Running: git reset --hard origin/$BRANCH"
    git reset --hard "origin/$BRANCH"

    # Make install.sh executable
    chmod +x "$INSTALL_DIR/install.sh"

    # Regenerate nginx config from .env
    if [ -f "$INSTALL_DIR/.env" ]; then
        # Source .env to get DOMAIN and USE_SSL
        source "$INSTALL_DIR/.env"
        if [ -n "$DOMAIN" ]; then
            info "Regenerating nginx config..."
            generate_nginx_conf "$DOMAIN" "$USE_SSL"
        fi
        
        # Initialize Jackett if not configured
        if [ -z "$JACKETT_API_KEY" ]; then
            info "Jackett not configured, initializing..."
            generate_jackett_key
            init_jackett_config
            # Append to .env
            echo "" >> "$INSTALL_DIR/.env"
            echo "# Jackett API Key (auto-generated, do not share!)" >> "$INSTALL_DIR/.env"
            echo "JACKETT_API_KEY=${JACKETT_API_KEY}" >> "$INSTALL_DIR/.env"
            ok "Jackett API key added to .env"
        else
            # Ensure Jackett config exists with the key from .env
            init_jackett_config
        fi
    fi

    # Rebuild
    debug "Running: docker compose down --remove-orphans"
    docker compose down --remove-orphans 2>/dev/null || true
    debug "Running: docker compose up -d --build"
    docker compose up -d --build
    debug "Running: docker image prune -f"
    docker image prune -f 2>/dev/null || true

    ok "Update complete"
}

# =========================================================================
# Show help
# =========================================================================
show_help() {
    echo "Lampa Self-Hosted Installer v$VERSION"
    echo ""
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --update          Update to latest version"
    echo "  --uninstall       Remove Lampa completely"
    echo "  --branch=NAME     Use specific branch (default: main)"
    echo "  --verbose, -v     Show debug output"
    echo "  --quiet, -q       Minimal output (for cron)"
    echo "  --help, -h        Show this help"
    echo ""
    echo "Examples:"
    echo "  # Fresh install"
    echo "  curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash"
    echo ""
    echo "  # Install from dev branch"
    echo "  curl ... | bash -s -- --branch=dev"
    echo ""
    echo "  # Update existing installation"
    echo "  cd /opt/lampa && ./install.sh --update"
    echo ""
    echo "  # Update to specific branch"
    echo "  ./install.sh --update --branch=dev"
    echo ""
}

# =========================================================================
# Main
# =========================================================================
main() {
    local QUIET=false
    
    # Parse flags first (before banner)
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --quiet|-q)
                QUIET=true
                shift
                ;;
            --branch=*)
                BRANCH="${1#*=}"
                shift
                ;;
            --branch)
                BRANCH="$2"
                shift 2
                ;;
            --update)
                MODE="update"
                shift
                ;;
            --uninstall)
                MODE="uninstall"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done

    # Show banner (unless quiet mode)
    if [ "$QUIET" != "true" ]; then
        echo ""
        echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║   Lampa Self-Hosted Installer v$VERSION      ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
        echo ""
        
        if [ "$BRANCH" != "main" ]; then
            info "Using branch: $BRANCH"
        fi
    fi

    # Handle modes
    case "$MODE" in
        update)
            check_prerequisites
            if [ ! -d "$INSTALL_DIR/.git" ]; then
                err "Lampa is not installed or not a git repository"
                err "Run without --update to install fresh"
                exit 1
            fi
            do_update
            exit 0
            ;;
        uninstall)
            do_uninstall
            exit 0
            ;;
    esac

    # Interactive install
    check_prerequisites
    
    # Check for existing config first (before setup_repo might move things)
    WRITE_NEW_ENV=false
    if ! load_existing_config; then
        ask_config
    fi
    
    setup_repo
    create_dirs
    
    # Generate Jackett key if not already set
    if [ -z "$JACKETT_API_KEY" ]; then
        generate_jackett_key
    fi
    
    init_jackett_config
    
    # Write .env only if new config or missing
    if [ "$WRITE_NEW_ENV" = "true" ] || [ ! -f "$INSTALL_DIR/.env" ]; then
        write_env
    else
        # Ensure JACKETT_API_KEY is in .env even if using existing config
        if ! grep -q "JACKETT_API_KEY" "$INSTALL_DIR/.env" 2>/dev/null; then
            info "Adding Jackett API key to existing .env..."
            echo "" >> "$INSTALL_DIR/.env"
            echo "# Jackett API Key (auto-generated, do not share!)" >> "$INSTALL_DIR/.env"
            echo "JACKETT_API_KEY=${JACKETT_API_KEY}" >> "$INSTALL_DIR/.env"
        fi
    fi
    
    generate_nginx_conf

    # Make install.sh executable
    chmod +x "$INSTALL_DIR/install.sh"

    # Build containers first (without SSL, nginx needs cert to start)
    if [ "$USE_SSL" = "true" ]; then
        init_ssl
        # Now start everything
        build_and_start
    else
        build_and_start
    fi

    setup_autoupdate

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       Installation complete!             ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Open: ${CYAN}${PROTOCOL}://${INPUT_DOMAIN}${NC}"
    echo ""
    echo -e "  ${YELLOW}⚠ IMPORTANT:${NC} Set Jackett admin password!"
    echo -e "    Go to: ${CYAN}${PROTOCOL}://${INPUT_DOMAIN}/jacadmin/${NC}"
    echo -e "    and configure admin password on first visit."
    echo ""
    echo -e "  Useful commands:"
    echo -e "    ${YELLOW}cd $INSTALL_DIR${NC}"
    echo -e "    ${YELLOW}docker compose logs -f${NC}          — view logs"
    echo -e "    ${YELLOW}docker compose restart${NC}          — restart services"
    echo -e "    ${YELLOW}./install.sh --update${NC}           — update to latest"
    echo -e "    ${YELLOW}./install.sh --uninstall${NC}        — complete removal"
    if [ "$BRANCH" != "main" ]; then
        echo ""
        echo -e "  Branch: ${CYAN}$BRANCH${NC}"
    fi
    if [ "$AUTO_UPDATE_ENABLED" = "true" ]; then
        echo ""
        echo -e "  Auto-update: ${GREEN}enabled${NC} (every 5 min)"
        echo -e "  Update log: /var/log/lampa-update.log"
    fi
    echo ""
}

main "$@"
