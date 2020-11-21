#!/bin/bash

## Interpret arguments and execute build.

export LATEST_VERSION='1.4'

export WITHIN_M4='y'

# This fails on OSX otherwise looking for <string.h>.
export CFLAGS='-Wno-implicit-function-declaration'

source "$TOOLCHAIN_ROOT"/utils.v1.sh
if [[ -z "${WITHIN_AUTOCONF:-}" ]]; then
  export PATH="$(declare_bin_dependency 'autoconf'):${PATH}"
fi
if [[ -z "${WITHIN_AUTOMAKE:-}" ]]; then
  export PATH="$(declare_bin_dependency 'automake'):${PATH}"
fi

exec generic/build-configure-helper.sh \
     m4 \
     "${1:-latest}" \
     'ftpmirror.gnu.org/m4'
