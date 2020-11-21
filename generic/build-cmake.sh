#!/bin/bash

source "$TOOLCHAIN_ROOT"/utils.v1.sh

set_strict_mode

source "$TOOLCHAIN_ROOT"/generic/lib-configure.sh

function build_cmake {
  local -r version="$1"
  local -r release_urls_base="github.com/Kitware/CMake/releases/download/v${version}"

  # TODO: we  generally assume that  (as in README.rst  in the cmake repo)  we already have  a C++11
  # compiler and 'make' on the PATH.
  # local -r gcc_bin_dir="$(declare_bin_dependency 'gcc')"
  # local -r make_bin_dir="$(declare_bin_dependency 'make')"
  # PATH="${gcc_bin_dir}:${make_bin_dir}:${PATH}"

  CONFIGURE_PATH="./bootstrap" \
                build 'cmake' "$version" "$release_urls_base"
}

readonly CMAKE_LATEST_VERSION='3.19.0'
## Interpret arguments and execute build.

readonly _CMAKE_VERSION_ARG="${1:-latest}" TARGET_OS="${2:-$(uname)}"
if [[ "$_CMAKE_VERSION_ARG" == 'latest' ]]; then
  readonly CMAKE_VERSION="$CMAKE_LATEST_VERSION"
else
  readonly CMAKE_VERSION="$_CMAKE_VERSION_ARG"
fi


with_pushd "$(mkdirp_absolute_path "cmake-${CMAKE_VERSION}-${TARGET_OS}")" \
           build_cmake "$CMAKE_VERSION"
