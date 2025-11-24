# Hallo kawan!! ini setUp framework pribadi ku
tujuan pembuatan dari repo ini adalah ribet nya mulai dari awal bikin folder file dll nya di express, jadi saya research dan nemu cara otomisasi nya dengan node, Semoga membantu !

## - set up express
untuk jalankan file ini silakan di clone terlebi dahulu dan pastikan bahwa anda ada di file yg sama dengan file setup,
lalu jalan kan promt ini di bash
```
    node expressSetUp
``` 
### hasil folder structure yg didapat
```
src/
├── config/
├── core/
│   ├── middleware/
│   └── utils/
├── features/
│   └── user/
│       ├── user.controller.js
│       ├── user.model.js
│       └── user.routes.js
├── app.js
└── server.js
tools/
.env
.env.example
.gitignore
package-lock.json
package.json
setUpExpress.js
```

### Command yg dapat di gunakan dengan tools yg di sediakan dari set up

### membuat feature bagi routes, models dan controller
```
    npm run models ${namaFile} all // untuk menciptakan file secara menyeluruh
```
```
    npm run models ${namaFile} routes // hanya akan membuat routes
```

### mengahapus feature
```
    npm run delete ${namaFile}
```