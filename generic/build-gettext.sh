#!/bin/sh

## Interpret arguments and execute build.

readonly GETTEXT_VERSION="${1:-0.21}"

exec ./build-configure-helper.sh \
     gettext \
     "$GETTEXT_VERSION" \
     'ftpmirror.gnu.org/gettext'
