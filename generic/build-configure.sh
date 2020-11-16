#!/bin/sh

source "$(git rev-parse --show-toplevel)/utils.v1.sh"

set_strict_mode

# TODO: how to declare dependencies on curl and tar?
function fetch_extract_source_release {
  local -r name="$1"
  local -r version="$2"
  local -r release_urls_base="$3"
  _extracted_dirname="${name}-${version}"
  _archive_filename="${_extracted_dirname}.tar.gz"
  _release_url="https://${release_urls_base}/${_archive_filename}"

  _downloaded_archive="$(curl_file_with_fail "$_release_url" "$_archive_filename")"
  extract_for "$_downloaded_archive" "$_extracted_dirname"
}

function build_with_configure {
  ./configure "$@"
  make "-j${MAKE_JOBS:-2}"
  make install
}

function build {
  local -r name="$1"
  local -r version="$2"
  local -r release_urls_base="$3"
  local -a output_paths=( "${@:4}" )

  local -r source_dir="$(fetch_extract_source_release "$name" "$version" "$release_urls_base")"

  local -r install_dir="$(with_pushd "$source_dir" mkdirp_absolute_path "${name}-install")"

  with_pushd >&2 "$source_dir" \
                 build_with_configure --prefix "$install_dir"

  # NB: The below two lines are debugging info.
  echo >&2 "$source_dir" "$install_dir"
  ls -lAvF >&2 "$install_dir"
  # TODO: checking if this is an empty array is Very Hard.
  if [[ "${#output_paths[@]}" -eq 0 || "${output_paths[1]:-}" == '' ]]; then
    output_paths=( $(with_pushd "$install_dir" find . -executable -type f) )
  fi
  with_pushd "$install_dir" \
             create_gz_package "$name" "${output_paths[@]}"
}

## Interpret arguments and execute build.

if [[ "$#" -lt 3 ]]; then
  die "Usage: $0 NAME VERSION RELEASE_URLS_BASE [OUTPUT_PATHS...]"
fi

readonly NAME="$1"
readonly VERSION="$2"
readonly RELEASE_URLS_BASE="$3"
readonly -a OUTPUT_PATHS=( "${@:4}" )

build "$NAME" "$VERSION" "$RELEASE_URLS_BASE" "${OUTPUT_PATHS[@]}"
