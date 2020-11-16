#!/bin/sh

source "$(git rev-parse --show-toplevel)/utils.v1.sh"

set_strict_mode

# TODO: how to declare dependencies on curl and tar?
function fetch_extract_git_source_release {
  _version="$1"
  _extracted_dirname="git-${_version}"
  _archive_filename="${_extracted_dirname}.tar.gz"
  _release_url="https://mirrors.edge.kernel.org/pub/software/scm/git/${_archive_filename}"

  _downloaded_archive="$(curl_file_with_fail "$_release_url" "$_archive_filename")"
  extract_for "$_downloaded_archive" "$_extracted_dirname"
}

function build_git_with_configure {
  ./configure "$@"
  make "-j${MAKE_JOBS:-2}"
  make install
}

function build_git {
  _version="$1"
  _git_source_dir="$(fetch_extract_git_source_release "$_version")"

  _install_dir_abs="$(with_pushd "$_git_source_dir" mkdirp_absolute_path git-install)"

  with_pushd >&2 "$_git_source_dir" \
                 build_git_with_configure --prefix "$_install_dir_abs"

  echo >&2 "$_git_source_dir" "$_install_dir_abs"
  ls -lAvF >&2 "$_install_dir_abs"
  with_pushd "$_install_dir_abs" \
             create_gz_package 'git' \
             'bin/'
}


## Interpret arguments and execute build.

GIT_VERSION="$1"

build_git "$GIT_VERSION"
