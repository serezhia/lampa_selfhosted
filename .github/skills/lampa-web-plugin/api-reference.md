# Lampa API Reference

All Lampa functionality is accessed via the global `window.Lampa` object.

## Storage (`Lampa.Storage`)
Persistent key-value storage (wrapper around `localStorage`).
- `Lampa.Storage.get('key', 'default_value')` - Retrieve data.
- `Lampa.Storage.set('key', 'value')` - Store data.

## Activity (`Lampa.Activity`)
Manages the application's screen stack (navigation).
- `Lampa.Activity.push(options)` - Adds a new screen. Options include `url`, `title`, `component`, and `page`.
- `Lampa.Activity.replace(options)` - Replaces the current screen.
- `Lampa.Activity.backward()` - Navigates back to the previous screen.

## Listener (`Lampa.Listener`)
Event bus for inter-module communication.
- `Lampa.Listener.follow('event_name', callback)` - Subscribe to an event.
- `Lampa.Listener.send('event_name', data)` - Dispatch an event.
- *Common events:* `app` (type: `ready`), `state:changed`.

## Component (`Lampa.Component`)
Registers UI components that can be pushed to the Activity stack.
- `Lampa.Component.add('component_name', ComponentClass)`

## Template (`Lampa.Template`)
Manages HTML templates.
- `Lampa.Template.add('template_name', '<div>...</div>')` - Define a template.
- `Lampa.Template.get('template_name', data, true)` - Render and retrieve a template as a DOM element.

## Network (`Lampa.Network` / `Lampa.Reguest`)
Making network requests.
```javascript
var network = new Lampa.Reguest();
network.silent('https://api.example.com/data', function(response) {
    console.log(response);
}, function(error) {
    console.error(error);
});
```

## UI Elements (`Lampa.Head`, `Lampa.Menu`)
- `Lampa.Head.addIcon(svg_icon, action)` - Add icon to header.
- `Lampa.Menu.addButton(svg_icon, title, action)` - Add button to main menu.
