#!/bin/bash

source "$TOOLCHAIN_ROOT"/utils.v1.sh

set_strict_mode

readonly PATCH_FILE="${PATCH_FILE:-}"

function fetch_extract_clingo_source_release {
  local -r version="$1"
  local -r archive_filename="v${version}.tar.gz"
  local -r release_url="https://github.com/potassco/clingo/archive/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"

  local -r extracted_dirname="clingo-${version}"
  extract_for "$downloaded_archive" "$extracted_dirname"
}

function run_cmake {
  local -r source_dir="$1"
  local -r build_dir="$2"

  if [[ -f "$PATCH_FILE" ]]; then
    check_cmd_or_err 'patch'
    with_pushd "$source_dir" \
               patch -p1 <"$PATCH_FILE"
  fi

  cmake -H"$source_dir" -B"$build_dir" -DCMAKE_BUILD_TYPE=Release
  cmake --build "$build_dir"
}

function build_clingo {
  local -r version="$1"

  local -r source_dir="$(fetch_extract_clingo_source_release "$version")"
  local -r build_dir="$(with_pushd "$source_dir" mkdirp_absolute_path "../clingo-build")"

  local -r cmake_bin_dir="$(declare_bin_dependency 'cmake')"
  local -r gcc_bin_dir="$(declare_bin_dependency 'gcc')"
  local -r make_bin_dir="$(declare_bin_dependency 'make')"
  PATH="${cmake_bin_dir}:${gcc_bin_dir}:${make_bin_dir}:${PATH}" \
      run_cmake "$source_dir" "$build_dir" \
      >&2

  with_pushd "$build_dir" \
             create_gz_package 'clingo' 'bin'
}


readonly CLINGO_LATEST_VERSION='5.4.0'
## Interpret arguments and execute build.

readonly _CLINGO_VERSION_ARG="${1:-latest}" TARGET_OS="${2:-$(uname)}"
if [[ "$_CLINGO_VERSION_ARG" == 'latest' ]]; then
  readonly CLINGO_VERSION="$CLINGO_LATEST_VERSION"
else
  readonly CLINGO_VERSION="$_CLINGO_VERSION_ARG"
fi


with_pushd "$(mkdirp_absolute_path "clingo-${CLINGO_VERSION}-${TARGET_OS}")" \
           build_clingo "$CLINGO_VERSION"
