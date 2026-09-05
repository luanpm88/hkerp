# Local development environment (Docker)

A containerised copy of the legacy HKERP Rails app so changes can be exercised
before they reach production.

## Production it mirrors

| | Production (`hk-server`) | This environment |
|---|---|---|
| OS | Ubuntu 20.04.6 LTS | Debian Jessie (base of `ruby:2.3.3`) |
| Ruby | 2.3.3p222 (RVM) | 2.3.3p222 (official image) |
| Rails | 4.2.5 | 4.2.5 (same `Gemfile.lock`) |
| PostgreSQL | 12.22 | 12.22 |
| OpenSSL behind Ruby | 1.0.2n (RVM-bundled, *not* the system 1.1.1f) | 1.0.2 (Jessie system) |
| App server | Unicorn, 2 workers | `rails server` |
| Arch | x86_64 | x86_64 (emulated — see below) |

Ruby patchlevel, Rails version, Postgres major/minor and the OpenSSL major line
all match. The base OS differs because building Ruby 2.3.3 on Ubuntu 20.04
requires compiling OpenSSL 1.0.2 first — production only manages it because RVM
does exactly that behind the scenes. The official `ruby:2.3.3` image already
ships that combination, so it is both closer to production's *runtime* and far
quicker to rebuild.

## Apple Silicon: Rosetta is required

`ruby:2.3.3` is amd64-only (2016, no arm64 build). Under Colima's default QEMU
emulation, Debian Jessie's glibc 2.19 binaries **segfault** — `ca-certificates`
and `libdpkg-perl` fail their post-install scripts and `apt-get` aborts with
exit code 100:

```
Segmentation fault (core dumped)
dpkg: error processing package ca-certificates (--configure):
 subprocess installed post-installation script returned error exit status 139
```

Rosetta handles these binaries correctly. Start Colima with it:

```bash
colima stop
colima start --vz-rosetta
```

Verify before building:

```bash
docker run --rm --platform=linux/amd64 ruby:2.3.3 ruby -v
# => ruby 2.3.3p222 (2016-11-21 revision 56859) [x86_64-linux]
```

The Dockerfile additionally sets `force-unsafe-io` and `--force-overwrite`
because Jessie's dpkg 1.17 creates a hard backup link for every replaced file,
which is unreliable on container snapshotters.

## First run

```bash
cd rails

# 1. Database
docker compose up -d db
until docker compose exec -T db pg_isready -U hoangkhang -d hkerp_development; do sleep 2; done

# 2. Load a production dump (plain-SQL pg_dump, not tracked in git)
gzcat data.dump.gz | docker compose exec -T db psql -U hoangkhang -d hkerp_development

# 3. Application image (slow the first time: native gems under emulation)
docker compose build web

# 4. Boot
docker compose up -d web
docker compose logs -f web
```

The app is then on <http://localhost:3000>.

## https://hkerp.local

An nginx vhost terminates TLS and proxies to the container.

```bash
# certificate (mkcert's CA is already trusted by the system keychain)
mkcert -cert-file ssl/hkerp.local.pem -key-file ssl/hkerp.local-key.pem \
       hkerp.local "*.hkerp.local" localhost 127.0.0.1

# hosts entry — needs sudo, run once
echo "127.0.0.1 hkerp.local" | sudo tee -a /etc/hosts

# vhost is at /opt/homebrew/etc/nginx/servers/hkerp.local.conf
nginx -t && brew services restart nginx
```

## Configuration notes

`config/database.yml` is **not** tracked (`.gitignore`), so production keeps its
own copy. The development and test sections read the host from the environment:

```yaml
host: <%= ENV['DATABASE_HOST'] || 'localhost' %>
```

`docker-compose.yml` sets `DATABASE_HOST: db`, so the same file works both in
the container and for a native `rails server` on the host.

## Verifying the Cash - Pay / Cash - Receive split

```bash
docker compose exec web bundle exec rails runner script/verify_cash_split.rb
```

The script creates its own records (note prefixed `VERIFY_CASH_SPLIT`), asserts
the direction contract, and destroys them again. It exits non-zero on failure.

## Everyday commands

```bash
docker compose exec web bash                      # shell
docker compose exec web bundle exec rails console # console
docker compose exec web bundle exec rake db:migrate
docker compose exec -T db psql -U hoangkhang -d hkerp_development
docker compose logs -f web
docker compose down                               # stop (keeps the pgdata volume)
docker compose down -v                            # stop and wipe the database
```

## Gotchas

- **Never point this at production.** `DATABASE_HOST` must stay `db`; the
  production database is only reachable from `hk-server`.
- `data.dump.gz` is a real production dump. It is gitignored (`*.dump`,
  `/data.dump`) — keep it that way.
- The first `bundle install` compiles native extensions (`therubyracer`, `pg`,
  `nokogiri`) under emulation and takes a long while. It is cached afterwards
  as long as `Gemfile`/`Gemfile.lock` do not change.
- Jessie's apt repositories are archived and their signatures have expired; the
  Dockerfile relaxes validity checking deliberately. Do not "fix" it by
  removing those apt options — the build will stop working.
