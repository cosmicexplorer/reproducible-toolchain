# -*- mode: sh; sh-shell: bash -*-

source ./utils.v1.sh

readonly ARCHIVE_URL_EXTENSION="${ARCHIVE_URL_EXTENSION:-.tar.gz}"

# TODO: how to declare dependencies on curl and tar?
function fetch_extract_source_release {
  local -r name="$1"
  local -r version="$2"
  local -r release_urls_base="$3"
  local -r extracted_dirname="${name}-${version}"
  local -r archive_filename="${extracted_dirname}${ARCHIVE_URL_EXTENSION}"
  local -r release_url="https://${release_urls_base}/${archive_filename}"

  local -r downloaded_archive="$(curl_file_with_fail "$release_url" "$archive_filename")"
  extract_for "$downloaded_archive" "$extracted_dirname"
}

function make_and_install {
  make "-j${MAKE_JOBS:-2}"
  make install
}

export CONFIGURE_PATH="${CONFIGURE_PATH:-./configure}"

function build_with_configure {
  "$CONFIGURE_PATH" "$@"
  make_and_install
}

function build {
  local -r name="$1"
  local version="$2"
  local -r release_urls_base="$3"
  local -ra configure_args=( "${@:4}" )

  if [[ "$version" == 'latest' ]]; then
    version="$LATEST_VERSION"
  fi

  local -r shard="${name}-${version}"
  local -r shard_dir="$(mkdirp_absolute_path "${shard}-configure-result")"
  local -r source_dir="$(with_pushd "$shard_dir" \
    fetch_extract_source_release "$name" "$version" "$release_urls_base")"

  local -r install_dir="$(with_pushd "$source_dir" mkdirp_absolute_path "../${name}-install")"

  if [[ "${#configure_args[@]:-}" -eq 0 ]]; then
    with_pushd >&2 "$source_dir" \
                   build_with_configure --prefix="$install_dir"
  else
    with_pushd >&2 "$source_dir" \
                   build_with_configure --prefix="$install_dir" "${configure_args[@]}"
  fi

  # NB: The below two lines are debugging info.
  echo >&2 "$source_dir" "$install_dir"
  ls -lAvF >&2 "$install_dir"
  local -ra output_paths=( $(with_pushd "$install_dir" find . -executable -type f) )

  # TODO: checking if this is an empty array is Very Hard.
  if [[ "${#output_paths[@]:-}" -eq 0 ]]; then
    with_pushd "$install_dir" \
               create_gz_package "$name"
  else
    with_pushd "$install_dir" \
               create_gz_package "$name" "${output_paths[@]}"
  fi
}
