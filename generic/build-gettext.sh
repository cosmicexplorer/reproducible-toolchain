#!/bin/bash

## Interpret arguments and execute build.

export LATEST_VERSION='0.21'

export WITHIN_GETTEXT='y'

source "$TOOLCHAIN_ROOT"/utils.v1.sh
if [[ -z "${WITHIN_AUTOCONF:-}" ]]; then
  export PATH="$(declare_bin_dependency 'autoconf'):${PATH}"
fi
if [[ -z "${WITHIN_AUTOMAKE:-}" ]]; then
  export PATH="$(declare_bin_dependency 'automake'):${PATH}"
fi
if [[ -z "${WITHIN_M4:-}" ]]; then
  export PATH="$(declare_bin_dependency 'm4'):${PATH}"
fi

exec generic/build-configure-helper.sh \
     gettext \
     "${1:-latest}" \
     'ftpmirror.gnu.org/gettext'
