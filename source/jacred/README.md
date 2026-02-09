# Jacred Configuration

This directory contains templates for Jacred (Jackett-compatible torrent indexer aggregator).

## Files

- `init.conf.template` - Template for Jacred configuration. Used by `install.sh` to generate `data/jacred/config/init.conf` with the API key.

## About Jacred

[Jacred](https://github.com/jacred-fdb/jacred) is a Jackett-compatible API that aggregates torrent search results from multiple sources.

Docker image: `ghcr.io/pavelpikta/jacred-fdb:latest`

## Configuration

The `init.conf` file supports the following options:

- `listenip` - IP address to listen on (default: `0.0.0.0`)
- `listenport` - Port to listen on (default: `9117`)
- `apikey` - API key for authentication (required in our setup)
- `openstats` - Open stats endpoint (default: `false`)
- `opensync` - Open sync endpoint (default: `false`)
- `mergeduplicates` - Merge duplicate torrents (default: `true`)

## API Endpoints

Jacred is compatible with Jackett API:

- `GET /api/v2.0/indexers/all/results?apikey=KEY&Query=SEARCH` - Search torrents
- `GET /health` - Health check
- `GET /version` - Version info
