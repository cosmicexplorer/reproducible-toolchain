#!/bin/sh

source "$(git rev-parse --show-toplevel)/utils.v1.sh"

set_strict_mode

_result="$(./build-git.sh 2.29.2)"
cp "$_result" ./git.tar.gz
