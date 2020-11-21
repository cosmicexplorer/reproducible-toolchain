#!/bin/bash

## Interpret arguments and execute build.

export LATEST_VERSION='1.16.2'

export WITHIN_AUTOMAKE='y'

source "$TOOLCHAIN_ROOT"/utils.v1.sh
if [[ -z "${WITHIN_AUTOCONF:-}" ]]; then
  export PATH="$(declare_bin_dependency 'autoconf'):${PATH}"
fi

exec generic/build-configure-helper.sh \
     automake \
     "${1:-latest}" \
     'ftpmirror.gnu.org/automake'
