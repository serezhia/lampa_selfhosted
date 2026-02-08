/**
 * Скрипт для применения модификаций к lampa-source после обновления из оригинального репозитория
 * 
 * Использование: node apply-modifications.js
 * 
 * Или с кастомным доменом: node apply-modifications.js --domain=your-domain.com
 */

const fs = require('fs');
const path = require('path');

// Загружаем патчи
const patchesFile = path.join(__dirname, 'patches.json');
if (!fs.existsSync(patchesFile)) {
    console.error('❌ Файл patches.json не найден!');
    process.exit(1);
}

const patchesData = JSON.parse(fs.readFileSync(patchesFile, 'utf8'));

// Конфигурация - можно переопределить через аргументы командной строки
const CONFIG = {
    SELF_HOSTED_DOMAIN: process.argv.find(a => a.startsWith('--domain='))?.split('=')[1] || patchesData.config.SELF_HOSTED_DOMAIN,
    CUB_API_DOMAIN: process.argv.find(a => a.startsWith('--cub-api='))?.split('=')[1] || patchesData.config.CUB_API_DOMAIN
};

console.log('🔧 Применение модификаций для Lampa Self-Hosted');
console.log(`   Домен: ${CONFIG.SELF_HOSTED_DOMAIN}`);
console.log(`   CUB API: ${CONFIG.CUB_API_DOMAIN}`);
console.log('');

function replaceTemplates(str) {
    return str
        .replace(/\{\{SELF_HOSTED_DOMAIN\}\}/g, CONFIG.SELF_HOSTED_DOMAIN)
        .replace(/\{\{CUB_API_DOMAIN\}\}/g, CONFIG.CUB_API_DOMAIN);
}

let totalChanges = 0;
let errors = 0;
const modifiedFiles = new Map();

// Применяем патчи
for (const patch of patchesData.patches) {
    const filePath = path.join(__dirname, patch.file);

    if (!fs.existsSync(filePath)) {
        console.log(`❌ Файл не найден: ${patch.file}`);
        errors++;
        continue;
    }

    // Читаем файл (или берём из кеша)
    let content = modifiedFiles.get(patch.file) || fs.readFileSync(filePath, 'utf8');

    const searchStr = patch.search;
    const replaceStr = replaceTemplates(patch.replace);

    if (content.includes(searchStr)) {
        content = content.replace(searchStr, replaceStr);
        modifiedFiles.set(patch.file, content);
        console.log(`✓ ${patch.file}: ${patch.description}`);
        totalChanges++;
    } else if (content.includes(replaceStr)) {
        console.log(`⏭ ${patch.file}: ${patch.description} (уже применено)`);
    } else {
        console.log(`⚠ ${patch.file}: ${patch.description} (паттерн не найден)`);
    }
}

// Добавляем код в manifest.js
if (patchesData.appendToFile) {
    const appendConfig = patchesData.appendToFile;
    const filePath = path.join(__dirname, appendConfig.file);

    let content = modifiedFiles.get(appendConfig.file) || fs.readFileSync(filePath, 'utf8');

    // Проверяем, не добавлено ли уже
    if (!content.includes('tmdb_proxy_domain')) {
        const appendContent = replaceTemplates(appendConfig.content);
        content = content.replace(appendConfig.before, appendContent + appendConfig.before);
        modifiedFiles.set(appendConfig.file, content);
        console.log(`✓ ${appendConfig.file}: Добавлены tmdb_proxy_domain и cub_api_domain`);
        totalChanges++;
    } else {
        console.log(`⏭ ${appendConfig.file}: Новые свойства уже добавлены`);
    }
}

// Сохраняем изменённые файлы
for (const [file, content] of modifiedFiles) {
    const filePath = path.join(__dirname, file);
    fs.writeFileSync(filePath, content, 'utf8');
}

console.log('');
console.log('═'.repeat(50));
console.log(`✅ Применено изменений: ${totalChanges}`);
console.log(`📁 Изменено файлов: ${modifiedFiles.size}`);
if (errors > 0) {
    console.log(`❌ Ошибок: ${errors}`);
}
console.log('');
console.log('Не забудьте пересобрать: gulp pack_github');
