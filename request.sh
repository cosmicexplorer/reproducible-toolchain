#!/bin/bash

source ./utils.v1.sh

set_strict_mode

# TODO: what shell requirements do we have now?
if [[ "$#" -lt 1 ]]; then
  die_here <<EOF
Usage: $0 name [version=latest] [target_os=\$(uname)] [arch_subdir=\$(uname -m)]
EOF
  exit 1
fi

# ./request.sh binutils [2.30] [linux] [x86_64]
readonly name="$1"
readonly version="${2:-latest}"
readonly target_os="${3:-$(uname)}"
readonly arch_subdir="${4:-$(uname -m)}"

readonly shard="${name}-${version}-${target_os}-${arch_subdir}"

readonly BOOTSTRAP_OUTPUT_DIR="${BOOTSTRAP_OUTPUT_DIR:-bootstrap-packaged}"
mkdir -pv "$BOOTSTRAP_OUTPUT_DIR" >&2

readonly output="${BOOTSTRAP_OUTPUT_DIR}/${shard}.tar.gz"

if [[ -f "$output" ]]; then
  warn "${output} was already created! returning that path!"
else
  readonly result="$("./generic/build-${name}.sh" \
  "${version}" \
  "${target_os}" \
  "${arch_subdir}")"
  cp >&2 -v "$result" "$output"
fi

echo "$output"
