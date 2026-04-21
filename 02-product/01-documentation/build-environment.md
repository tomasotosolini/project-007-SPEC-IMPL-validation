# Build Environment

## Versions

| Component | Version |
|---|---|
| Ruby | 3.1.2p20 |
| Rails | 7.2.3.1 |
| SQLite | 3.40.1 |
| Bundler | 2.3.7 (Debian: `bundler3.1`) |

## Application location

`02-product/02-software/xen_manager/`

## Gem installation

Gems are installed locally inside the app (not system-wide) due to write permissions on the system gem cache:

```sh
cd 02-product/02-software/xen_manager
bundler3.1 install          # installs to vendor/bundle/ (gitignored)
```

The local bundle path is stored in `.bundle/config` (gitignored).

## Running the application

```sh
cd 02-product/02-software/xen_manager
bundler3.1 exec rails server
```

## Running the test suite

```sh
cd 02-product/02-software/xen_manager
bundler3.1 exec rails test          # unit, model, controller, integration
bundler3.1 exec rails test:system   # system tests (browser)
```

## Database

SQLite, stored in `storage/`. Both `development.sqlite3` and `test.sqlite3` are created by:

```sh
bundler3.1 exec rails db:create db:migrate
```
