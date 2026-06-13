# scaffold — Express Project Scaffolder

Bosan setiap kali mulai project Express harus bikin folder, file, config, dan instal dependencies dari nol?  
Ini toolsnya — sekali install, tinggal jalanin `scaffold` dari direktori mana aja.

---

## Install

### Lewat `curl` (recommended, ga perlu `git`)

```bash
bash <(curl -s https://raw.githubusercontent.com/aussenseiter-VsRB/setUpFile/main/install.sh)
```

Installer akan:
- Download repo sebagai zip via `curl`
- Extract ke `~/.scaffold`
- Set permission
- Daftarin alias `scaffold` di `~/.zshrc` / `~/.bashrc` / `config.fish`
- Kalau `~/.scaffold` udah ada, bakal nanya update atau skip

Selesai, jalanin ini biar alias aktif:

```bash
source ~/.zshrc           # atau ~/.bashrc / config.fish
```

### Manual (clone)

```bash
git clone https://github.com/aussenseiter-VsRB/setUpFile.git
cd setUpFile/express
```

Terus tinggal jalanin langsung:
```bash
bash scaffold.sh
```

---

## Cara Pake

Jalanin `scaffold` dari folder project yang mau di-setup:

```bash
scaffold
```

Bakal nanya dua hal:

1. **ORM** yang dipake:
```
Select an ORM:
  1. Prisma
  2. Sequelize
  3. Mongoose
```

2. **Docker** — mau include `Dockerfile` + `docker-compose.yml`? `y` / `n`

Abis itu semua file, folder, dependencies, config database kepasang otomatis.

---

## Hasil Folder Structure

```
src/
├── config/
│   └── db.js
├── core/
│   ├── middleware/
│   └── utils/
├── features/
├── app.js
└── server.js
tools/
├── createModule.js
└── deleteModule.js
prisma/
└── schema.prisma        ← hanya kalau pilih Prisma
.env
.env.example
.gitignore
package.json
Dockerfile              ← hanya kalau pilih Docker
docker-compose.yml      ← hanya kalau pilih Docker
.dockerignore           ← hanya kalau pilih Docker
```

---

## Command yang Tersedia

### Membuat feature module

```bash
npm run module <namaFile>             # bikin semua file (model, service, controller, routes)
npm run module <namaFile> controller  # cuma controller
npm run module <namaFile> routes      # cuma routes
npm run module <namaFile> model       # cuma model (Sequelize & Mongoose)
```

> **Prisma:** model ga di-generate karena didefinisikan di `prisma/schema.prisma`.  
> Abis nambah model di schema, jalankan:
> ```bash
> npx prisma migrate dev --name add_<namaFile>
> ```

### Menghapus feature

```bash
npm run delete <namaFile>
```

### Menjalankan server

```bash
npm run dev
```

---

## Catatan per ORM

| ORM | Koneksi DB | Model |
|---|---|---|
| **Prisma** | `DATABASE_URL` di `.env` | Didefinisikan di `schema.prisma` |
| **Sequelize** | `DB_HOST`, `DB_NAME`, `DB_USER`, dll di `.env` | File `.model.js` di dalam feature |
| **Mongoose** | `MONGO_URI` di `.env` | File `.model.js` di dalam feature |

Sesuaikan isi `.env` dengan konfigurasi database kamu sebelum menjalankan server.

---

## Docker Support

Kalau milih include Docker, file berikut dibuat:

```
Dockerfile
docker-compose.yml
.dockerignore
```

Database service sesuai ORM:

| ORM | Service | Port |
|---|---|---|
| **Prisma** | PostgreSQL | 5432 |
| **Sequelize** | PostgreSQL | 5432 |
| **Mongoose** | MongoDB | 27017 |

### Command Docker

```bash
npm run docker         # build image
npm run docker:up      # start containers
npm run docker:down    # stop containers
```

---

## Vanilla JS SPA

Pilih **Vanilla JS** dari menu scaffold untuk bikin Single Page App tanpa framework.

### Hasil Folder Structure

```
<project>/
├── assets/
├── components/
│   ├── layout/
│   ├── ui/
│   └── shared/
├── css/
│   └── global.css
├── data/
├── dist/
├── features/
├── js/
│   ├── core/
│   │   ├── config.js
│   │   ├── main.js
│   │   ├── router.js
│   │   └── theme.js
│   ├── data/
│   ├── services/
│   └── utils/
│       ├── api.js
│       ├── dom.js
│       ├── format.js
│       ├── styleLoader.js
│       └── url.js
├── tools/
│   ├── newComponent.sh
│   ├── newFeature.sh
│   └── newService.sh
├── index.html
└── package.json
```

### Generator Tools

Tools berikut otomatis tercopy ke folder `tools/` dan bisa dipanggil lewat npm:

```bash
npm run new:component    # Bikin komponen UI (PascalCase, misal UserCard)
npm run new:feature      # Bikin fitur baru (kebab-case, misal user-profile)
npm run new:service      # Bikin service singleton (camelCase, misal bookmarks)
```

Semua tool bersifat interaktif — bakal nanya nama, kategori, dan opsi lainnya.

#### new:component

- Nama harus **PascalCase** (contoh: `Navbar`, `UserCard`)
- Pilih kategori: `layout`, `ui`, atau `shared`
- Hasil: `components/<kategori>/<nama>/` berisi `.js` + `.css`

#### new:feature

- Nama path dengan **kebab-case**, bisa nested dengan `/` (contoh: `blog`, `blog/post/comments`)
- Opsi bikin file data JSON sendiri atau pake yang udah ada
- Hasil: `features/<path>/` berisi `.js`, `.css`, dan opsi helper stubs
- Import path dan route otomatis menyesuaikan kedalaman nesting

#### new:service

- Nama harus **camelCase** (contoh: `bookmarks`, `auth`)
- Hasil: `js/services/<nama>.js` — singleton class dengan method `getAll()` dan `create()`

### Command Lain

```bash
npm run build:css     # Build Tailwind CSS
npm run watch:css     # Watch mode Tailwind CSS
```
