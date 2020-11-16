#!/bin/sh

source "$(git rev-parse --show-toplevel)/utils.v1.sh"

set_strict_mode

_result="$(./build-bash.sh 5.0)"
cp "$_result" ./bash.tar.gz
