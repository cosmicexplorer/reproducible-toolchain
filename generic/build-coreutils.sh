#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='8.32'

# NB: More versions of coreutils are available at .tar.xz URLs for some reason?
export ARCHIVE_URL_EXTENSION="${ARCHIVE_URL_EXTENSION:-.tar.xz}"

exec generic/build-configure-helper.sh \
     coreutils \
     "${1:-latest}" \
     'ftpmirror.gnu.org/coreutils'
