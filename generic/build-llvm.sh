#!/bin/sh

# TODO: how to declare a (build time!! because it occurs when creating bootstrap artifacts!!)
# dependency on git?
readonly BUILDROOT="$(git rev-parse --show-toplevel)"

source "${BUILDROOT}/utils.v1.sh"

set_strict_mode

source "${BUILDROOT}/generic/lib-binary.sh"

function fetch_llvm_binary_release_archive {
  local -r version="$1"
  local -r shard="$2"

  local -r archive_filename="${shard}.tar.xz"
  local -r release_url="https://github.com/llvm/llvm-project/releases/download/llvmorg-${version}/${archive_filename}"

  curl_file_with_fail "$release_url" "$archive_filename"
}

# TODO: how to declare a (build time!!) dependency on xz?
function fetch_repackage_llvm_xz_into_gz {
  local -r version="$1"
  local -r system_id="$2"

  # https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang+llvm-11.0.0-x86_64-alinux-gnu-ubuntu-16.04.tar.xz
  local -r archive_base="clang+llvm-${version}-x86_64-${system_id}"
  local -r xz_result="$(fetch_llvm_binary_release_archive "$version" "$archive_base")"

  local -r work_dir="$(mkdirp_absolute_path "${archive_base}-work-dir")"
  with_pushd "$work_dir" \
             repackage_xz "$archive_base" "$xz_result" "$archive_base"
}

readonly LATEST_LLVM_VERSION='11.0.0'
## Interpret arguments and execute build.

readonly _LLVM_VERSION_ARG="${1:-latest}"
readonly TARGET_OS="${2:-$(uname)}"

if [[ "$_LLVM_VERSION_ARG" == 'latest' ]]; then
  readonly LLVM_VERSION="$LATEST_LLVM_VERSION"
else
  readonly LLVM_VERSION="$_LLVM_VERSION_ARG"
fi

case "$TARGET_OS" in
  Darwin)
    readonly download_tag='apple-darwin'
    ;;
  Linux)
    readonly download_tag='linux-gnu-ubuntu-16.04'
    ;;
  *)
    die "llvm does not support building for OS '${TARGET_OS}' (from 'uname')!"
    ;;
esac

fetch_repackage_llvm_xz_into_gz "$LLVM_VERSION" "$download_tag"
