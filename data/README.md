# Data Directory

This directory contains all user data and is **not tracked by git** (except this README and .gitkeep files).

## Structure

```
data/
├── plugins/           # Custom user plugins (override builtin by same name)
├── nginx/             # Generated nginx config (conf.d/)
├── jackett/
│   ├── config/        # Jackett configuration and indexers
│   └── downloads/     # Jackett downloads
├── database/          # SQLite database (lampa.db)
├── torrserver/
│   ├── config/        # TorrServer configuration
│   └── cache/         # TorrServer cache
├── transcoding/       # Transcoding cache
└── certs/
    ├── letsencrypt/   # Let's Encrypt certificates (or custom SSL certs)
    └── acme-challenge/ # ACME challenge files
```

## Custom Plugins

Place your `.js` plugin files in `data/plugins/`. They will be loaded alongside builtin plugins from `source/web/custom_plugins/`.

**To override a builtin plugin:** Create a file with the same name in `data/plugins/`. For example, to replace the builtin `auth.js`, create `data/plugins/auth.js`.

**To disable a builtin plugin without replacement:** Create an empty file with the same name, or a file that does nothing.

## Backup

To backup your data, simply copy this entire `data/` directory.

## Custom SSL Certificates

To use your own SSL certificates instead of Let's Encrypt:
1. Place your certificate as `data/certs/letsencrypt/live/your-domain/fullchain.pem`
2. Place your private key as `data/certs/letsencrypt/live/your-domain/privkey.pem`
