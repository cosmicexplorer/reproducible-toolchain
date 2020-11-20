#!/bin/sh

source ./utils.v1.sh

set_strict_mode

source generic/lib-configure.sh

## Interpret arguments and execute build.

if [[ "$#" -lt 3 ]]; then
  die "Usage: $0 NAME VERSION RELEASE_URLS_BASE [OUTPUT_PATHS...]"
fi

readonly NAME="$1"
readonly VERSION="$2"
readonly RELEASE_URLS_BASE="$3"
readonly -a CONFIGURE_ARGS=( "${@:4}" )

build "$NAME" "$VERSION" "$RELEASE_URLS_BASE" "${CONFIGURE_ARGS[@]}"
