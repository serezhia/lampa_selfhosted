#!/usr/bin/env node

/**
 * Production build script for Docker
 * Выполняет полную сборку проекта
 */

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

function runGulpTask(taskName, timeout = 0) {
    return new Promise((resolve, reject) => {
        console.log(`▶ Running: gulp ${taskName}`);

        const gulpProcess = spawn('npx', ['gulp', taskName], {
            stdio: 'inherit',
            shell: true
        });

        let timer = null;

        if (timeout > 0) {
            timer = setTimeout(() => {
                console.log(`⏱ Timeout reached, stopping gulp ${taskName}`);
                gulpProcess.kill('SIGTERM');
                setTimeout(() => {
                    gulpProcess.kill('SIGKILL');
                    resolve(); // Resolve on timeout, don't reject
                }, 2000);
            }, timeout);
        }

        gulpProcess.on('close', (code) => {
            if (timer) clearTimeout(timer);
            if (code !== 0 && timeout === 0) {
                reject(new Error(`gulp ${taskName} failed with code ${code}`));
            } else {
                resolve();
            }
        });

        gulpProcess.on('error', (err) => {
            if (timer) clearTimeout(timer);
            reject(err);
        });
    });
}

async function waitForFile(filePath, maxWait = 60000) {
    const start = Date.now();
    while (Date.now() - start < maxWait) {
        if (fs.existsSync(filePath)) {
            console.log(`✓ File exists: ${filePath}`);
            return true;
        }
        await new Promise(r => setTimeout(r, 1000));
    }
    return false;
}

async function build() {
    console.log('🚀 Starting production build...');

    try {
        // Step 1: Run pack_plugins
        console.log('\\n📦 Step 1: Building plugins...');
        await runGulpTask('pack_plugins');

        // Step 2: Run default gulp task to generate dest/app.js
        // This runs watch mode, so we timeout after 60 seconds
        console.log('\\n📦 Step 2: Generating dest/app.js...');
        await runGulpTask('default', 60000);

        // Verify dest/app.js exists
        const destAppPath = path.join(process.cwd(), 'dest', 'app.js');
        if (!fs.existsSync(destAppPath)) {
            console.log('⚠ dest/app.js not found, waiting...');
            const found = await waitForFile(destAppPath, 10000);
            if (!found) {
                // Try alternative: create dest folder and copy/build manually
                console.log('⚠ Still not found, trying direct merge...');
                await runGulpTask('merge');
            }
        }

        // Step 3: Build production version
        console.log('\\n📦 Step 3: Building production version...');
        await runGulpTask('pack_github');

        // Verify output
        const outputDir = path.join(process.cwd(), 'build', 'github', 'lampa');
        if (!fs.existsSync(outputDir)) {
            throw new Error('Build output directory not found: ' + outputDir);
        }

        console.log('\\n✅ Build complete!');
        console.log('Output: build/github/lampa/');
        process.exit(0);
    } catch (error) {
        console.error('\\n❌ Build failed:', error.message);
        process.exit(1);
    }
}

build();
