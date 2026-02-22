---
name: lampa-web-plugin
description: Creates or modifies frontend plugins for the Lampa SPA. Use this when working with Lampa UI, Lampa APIs (Storage, Activity, Network), or custom_plugins.
---

# Lampa Web Plugin Development

This skill provides instructions for developing frontend plugins for the Lampa Self-Hosted project.

## Core Architecture

- **Environment:** Lampa is a Single Page Application (SPA).
- **Syntax:** ES5 syntax only (no ES6 modules, no let/const if targeting older TVs, though ar is preferred).
- **Encapsulation:** Wrap everything in an IIFE (Immediately Invoked Function Expression).
- **Global API:** All Lampa functionality is accessed via the global window.Lampa object.

## DeepWiki Usage (CRITICAL)

When developing frontend plugins or working with the Lampa UI, you **MUST** use the mcp_deepwiki tool to search the yumata/lampa-source repository for documentation, API usage examples, and source code references. 

- Use mcp_deepwiki_ask_question to ask specific questions about how Lampa components work (e.g., "How to use Lampa.Activity?", "How does the player component work?").
- Use mcp_deepwiki_read_wiki_structure and mcp_deepwiki_read_wiki_contents to browse the available documentation.

## Advanced Plugin Development (TypeScript & Bundling)

While simple plugins can be written in a single JS file, complex features should be split into multiple files or written in TypeScript.

Since our project clones the original Lampa repository and builds it via Docker (source/web/Dockerfile), we don't have a built-in Webpack/Rollup setup for *our custom plugins* out of the box. 

**If you need to write a complex plugin in TypeScript or split it into modules:**
1. Create a subfolder in source/web/custom_plugins/ (e.g., my_complex_plugin/).
2. Set up a local package.json and a bundler (like sbuild, webpack, or ollup) inside that folder.
3. Configure the bundler to output a **single ES5 IIFE file** (e.g., my_complex_plugin.bundle.js) into the root of source/web/custom_plugins/.
4. The Docker build process will automatically pick up my_complex_plugin.bundle.js and serve it.

*Note: Do not use ES6 import/xport in the final output file, as older Smart TVs do not support ES modules.*

## References & Templates

Please refer to the following files for specific implementation details and templates:

- [Plugin Boilerplate Template](./plugin-template.js) - Standard IIFE structure and initialization logic.
- [Lampa API Reference](./api-reference.md) - Detailed documentation of Lampa.Storage, Lampa.Activity, Lampa.Listener, etc.

## Workflow

1. Create or edit plugins in source/web/custom_plugins/.
2. If adding a new plugin, ensure it's loaded by modification.js or added to patches.json.
3. User plugins in data/plugins/ override builtin plugins by filename.
4. To apply changes, rebuild the frontend container: docker compose up -d --build lampa-frontend.
