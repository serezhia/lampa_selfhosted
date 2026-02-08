Изменены gulpfiles
Добавлен Dockerfile
изменен manifest.js (сервера cub.red на lampa.serezhia.ru)

Изменен tmdb_proxy.js         path_api: 'apitmdb.'+(Manifest.tmdb_proxy_domain || Manifest.cub_domain)+'/3/',
а так же добавлен в манифест 
 /**
 * Домен для TMDB прокси (используется оригинальный cub.rip так как свой прокси не поднимаем)
 */
Object.defineProperty(object, 'tmdb_proxy_domain', {
    get: () => 'cub.rip',
    set: () => { }
})

изменен proxy.js         path_api: 'apitmdb.'+(Manifest.tmdb_proxy_domain || Manifest.cub_domain)+'/3/',


