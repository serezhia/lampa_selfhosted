#!/bin/sh
# Entrypoint script for Lampa frontend
# Generates plugins manifest and starts nginx

MANIFEST_PATH="/usr/share/nginx/html/plugins/manifest.json"
BUILTIN_DIR="/plugins/builtin"
CUSTOM_DIR="/plugins/custom"

echo "[Entrypoint] Generating plugins manifest..."

# Create plugins directory if not exists
mkdir -p /usr/share/nginx/html/plugins

# Start JSON
echo '{' > "$MANIFEST_PATH"
echo '  "plugins": [' >> "$MANIFEST_PATH"

# Track which plugins we've added (for deduplication)
ADDED_PLUGINS=""
FIRST=true

# First, add all custom plugins (they have priority)
if [ -d "$CUSTOM_DIR" ]; then
    for file in "$CUSTOM_DIR"/*.js; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            name="${filename%.js}"
            
            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                echo ',' >> "$MANIFEST_PATH"
            fi
            
            # Copy to served location
            cp "$file" "/usr/share/nginx/html/plugins/$filename"
            
            printf '    {"name": "%s", "source": "custom", "url": "/plugins/%s"}' "$name" "$filename" >> "$MANIFEST_PATH"
            ADDED_PLUGINS="$ADDED_PLUGINS $name "
            echo "[Entrypoint] Added custom plugin: $name"
        fi
    done
fi

# Then, add builtin plugins (skip if already added from custom)
if [ -d "$BUILTIN_DIR" ]; then
    for file in "$BUILTIN_DIR"/*.js; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            name="${filename%.js}"
            
            # Skip if already added from custom (override)
            case "$ADDED_PLUGINS" in
                *" $name "*) 
                    echo "[Entrypoint] Skipping builtin plugin '$name' (overridden by custom)"
                    continue
                    ;;
            esac
            
            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                echo ',' >> "$MANIFEST_PATH"
            fi
            
            # Copy to served location
            cp "$file" "/usr/share/nginx/html/plugins/$filename"
            
            printf '    {"name": "%s", "source": "builtin", "url": "/plugins/%s"}' "$name" "$filename" >> "$MANIFEST_PATH"
            echo "[Entrypoint] Added builtin plugin: $name"
        fi
    done
fi

# Close JSON
echo '' >> "$MANIFEST_PATH"
echo '  ]' >> "$MANIFEST_PATH"
echo '}' >> "$MANIFEST_PATH"

echo "[Entrypoint] Plugins manifest generated:"
cat "$MANIFEST_PATH"

echo "[Entrypoint] Starting nginx..."
exec nginx -g 'daemon off;'
