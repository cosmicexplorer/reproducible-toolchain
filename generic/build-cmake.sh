#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.sh"

set_strict_mode

readonly CMAKE_VERSION_PATTERN='^([0-9]+\.[0-9]+)\.[0-9]+$'

function extract_minor_version {
  local -r version_string="$1"

  echo "$version_string" | sed -Ee "s#${CMAKE_VERSION_PATTERN}#\\1#g"
}

function fetch_extract_cmake_binary_release {
  local -r version="$1"
  local -r extracted_dirname="$2"

  local -r cmake_minor_version="$(extract_minor_version "$version")"

  local -r archive_filename="${extracted_dirname}.tar.gz"
  local -r release_url="https://cmake.org/files/v${cmake_minor_version}/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  extract_for "$downloaded_archive"  "$extracted_dirname"
}

function package_cmake {
  local -r installed_dir_abs="$1"

  with_pushd "$installed_dir_abs" \
             create_gz_package 'cmake' bin share
}

function build_osx {
  local -r extracted_dir="$(fetch_extract_cmake_binary_release "$@")"

  package_cmake "${extracted_dir}/CMake.app/Contents"
}

function build_linux {
  local -r extracted_dir="$(fetch_extract_cmake_binary_release "$@")"

  package_cmake "$extracted_dir"
}

readonly CMAKE_LATEST_VERSION='3.18.4'
## Interpret arguments and execute build.

readonly _CMAKE_VERSION_ARG="${1:-latest}" TARGET_OS="${2:-$(uname)}"
if [[ "$_CMAKE_VERSION_ARG" == 'latest' ]]; then
  readonly CMAKE_VERSION="$CMAKE_LATEST_VERSION"
else
  readonly CMAKE_VERSION="$_CMAKE_VERSION_ARG"
fi

case "$TARGET_OS" in
  Darwin)
    build_osx "$CMAKE_VERSION" "cmake-${CMAKE_VERSION}-Darwin-x86_64"
    ;;
  Linux)
    build_linux "$CMAKE_VERSION" "cmake-${CMAKE_VERSION}-Linux-x86_64"
    ;;
  *)
    die "cmake does not support building for OS '${TARGET_OS}' (from 'uname')!"
    ;;
esac
