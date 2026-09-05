# Local development image for the legacy HKERP Rails app.
#
# Parity with production (hk-server):
#   Ruby   2.3.3p222   — same as the RVM ruby on the server
#   Rails  4.2.5       — from Gemfile
#   Postgres 12        — see docker-compose.yml (matches hkerp_production)
#
# Production runs Ubuntu 20.04, but the app only cares about the Ruby
# patchlevel and the native libraries the gems link against, so the official
# ruby:2.3.3 image (Debian Jessie) is used instead of building Ruby 2.3.3 from
# source on Ubuntu — it is the same interpreter and it is far quicker to
# rebuild.
FROM --platform=linux/amd64 ruby:2.3.3

# Jessie is long past EOL: the repos moved to archive.debian.org and their
# release signatures have expired, so validity checking has to be relaxed and
# packages installed unauthenticated.
RUN set -eux; \
    printf '%s\n' \
      'deb http://archive.debian.org/debian jessie main' \
      'deb http://archive.debian.org/debian-security jessie/updates main' \
      > /etc/apt/sources.list; \
    printf '%s\n' \
      'Acquire::Check-Valid-Until "false";' \
      'APT::Get::AllowUnauthenticated "true";' \
      'Acquire::AllowInsecureRepositories "true";' \
      > /etc/apt/apt.conf.d/99-jessie-archive

ENV DEBIAN_FRONTEND=noninteractive

# Jessie ships dpkg 1.17, which unpacks by creating a hard backup link of every
# file it replaces. On BuildKit's snapshotter that link can land across devices
# and the unpack aborts — it showed up here as libdpkg-perl failing and apt
# exiting 100, even though the identical apt command succeeds in `docker run`.
# force-unsafe-io skips the backup link, and --force-overwrite lets a package
# take ownership of a path another package already shipped.
RUN set -eux; \
    echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/01-docker-unsafe-io; \
    echo 'Dpkg::Options { "--force-overwrite"; };' > /etc/apt/apt.conf.d/99-force-overwrite

# --no-install-recommends is essential here. Pulling recommends drags in the
# whole X11 / xserver / dbus / systemd chain (via wkhtmltopdf), whose dpkg
# triggers fail inside a container and abort the build with apt exit 100.
#
# Deliberately NOT installed:
#   wkhtmltopdf        the wkhtmltopdf-binary gem vendors its own binary
#   libmagickwand-dev  only needed by rmagick; this app uses mini_magick,
#                      which shells out to the imagemagick CLI
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends --force-yes \
      build-essential \
      libpq-dev \
      libxml2-dev \
      libxslt1-dev \
      zlib1g-dev \
      imagemagick \
      mdbtools \
      nodejs \
      git \
      ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# Bundler 2.x is needed to read the committed Gemfile.lock; 2.2.21 is the last
# release that still supports Ruby 2.3.
RUN gem install bundler -v 2.2.21 --no-document
ENV BUNDLER_VERSION=2.2.21

WORKDIR /app

# Dependencies first so the (slow, emulated) bundle install layer is cached
# across source changes.
COPY Gemfile Gemfile.lock ./
RUN bundle _2.2.21_ install --jobs 4 --retry 3

COPY . .

RUN mkdir -p shared/sockets shared/pids shared/log tmp/pids tmp/cache tmp/sockets log

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
