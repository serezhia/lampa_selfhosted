(function () {
    'use strict';

    // 1. Define a unique name for your plugin
    var plugin_name = 'my_custom_plugin';

    // 2. Main initialization function
    function init() {
        console.log('[Plugin]', plugin_name, 'initialized');

        // Example: Add a button to the main menu
        /*
        Lampa.Menu.addButton('icon_svg_string_here', 'My Plugin', function() {
            // Action on click: open a new screen
            Lampa.Activity.push({
                url: '', 
                title: 'My Page', 
                component: 'my_custom_component'
            });
        });
        */

        // Example: Listen to app state changes
        /*
        Lampa.Listener.follow('state:changed', function(e) {
            console.log('State changed:', e);
        });
        */
    }

    // 3. Safely wait for the main Lampa app to be ready before initializing
    if (window.appready) {
        init();
    } else {
        Lampa.Listener.follow('app', function (e) {
            if (e.type == 'ready') {
                init();
            }
        });
    }
})();
