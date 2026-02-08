---
description: Frontend code - use DeepWiki MCP for Lampa source docs
applyTo: "**/*.{js,ts,css,html,json},lampa_web/**"
---

# Lampa Frontend Rules

## Required: Consult DeepWiki BEFORE coding
Repository: `yumata/lampa-source`

1. `read_wiki_structure` → найти релевантные страницы
2. `read_wiki_contents` → извлечь контент
3. `ask_question` → уточнить детали
4. Только потом — код

## Scope (когда применять)
- UI/компоненты/стили
- Клиентский JS/состояние
- Билд/бандлинг
- Темы/CSS

## Do NOT
- Угадывать архитектуру без DeepWiki
- Добавлять новые библиотеки без явного запроса
- Менять глобальные стили

## Diagnostics checklist
- [ ] Энтрипоинт/инициализация
- [ ] События/хендлеры
- [ ] Владелец состояния
- [ ] Рендер-механизм
- [ ] CSS специфичность