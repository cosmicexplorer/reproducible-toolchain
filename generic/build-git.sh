#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='2.29.2'

exec generic/build-configure-helper.sh \
 git \
 "${1:-latest}" \
 'mirrors.edge.kernel.org/pub/software/scm/git'
