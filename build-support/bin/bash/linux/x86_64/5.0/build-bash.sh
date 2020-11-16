#!/bin/sh

source "$(git rev-parse --show-toplevel)/utils.v1.sh"

set_strict_mode

# TODO: how to declare dependencies on curl and tar?
function fetch_extract_bash_source_release {
  _version="$1"
  _extracted_dirname="bash-${_version}"
  _archive_filename="${_extracted_dirname}.tar.gz"
  _release_url="https://ftp.gnu.org/gnu/bash/${_archive_filename}"

  _downloaded_archive="$(curl_file_with_fail "$_release_url" "$_archive_filename")"
  extract_for "$_downloaded_archive" "$_extracted_dirname"
}

function build_bash_with_configure {
  ./configure "$@"
  make "-j${MAKE_JOBS:-2}"
  make install
}

function build_bash {
  _version="$1"
  _bash_source_dir="$(fetch_extract_bash_source_release "$_version")"

  _install_dir_abs="$(with_pushd "$_bash_source_dir" mkdirp_absolute_path bash-install)"

  with_pushd >&2 "$_bash_source_dir" \
                 build_bash_with_configure --prefix "$_install_dir_abs"

  echo >&2 "$_bash_source_dir" "$_install_dir_abs"
  ls -lAvF >&2 "$_install_dir_abs"
  with_pushd "$_install_dir_abs" \
             create_gz_package 'bash' \
             'bin/'
}


## Interpret arguments and execute build.

BASH_VERSION="$1"

build_bash "$BASH_VERSION"
