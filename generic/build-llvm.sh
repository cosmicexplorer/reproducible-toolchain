#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.sh"

set_strict_mode

# TODO: how to declare a (runtime!! because it ***stays xz-compressed!***) dependency on xz?
function fetch_llvm_binary_release_archive {
  local -r system_id="$1"

  local -r archive_dirname="clang+llvm-${LLVM_VERSION}-x86_64-${system_id}"
  local -r archive_filename="${archive_dirname}.tar.xz"
  local -r release_url="https://releases.llvm.org/${LLVM_VERSION}/${archive_filename}"

  curl_file_with_fail "$release_url" "$archive_filename"
}

readonly LLVM_VERSION="${1:-11.0.0}" TARGET_OS="${2:-$(uname)}"

case "$TARGET_OS" in
  Darwin)
    with_pushd "$(mkdirp_absolute_path "llvm-${LLVM_VERSION}-osx")" \
               fetch_llvm_binary_release_archive 'apple-darwin'
    ;;
  Linux)
    with_pushd "$(mkdirp_absolute_path "llvm-${LLVM_VERSION}-linux")" \
               fetch_llvm_binary_release_archive 'linux-gnu-ubuntu-16.04'
    ;;
  *)
    die "llvm does not support building for OS '${TARGET_OS}' (from 'uname')!"
    ;;
esac
