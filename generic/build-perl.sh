#!/bin/sh

source "$TOOLCHAIN_ROOT"/generic/lib-configure.sh

## Interpret arguments and execute build.

export LATEST_VERSION='5.32.0'

function build_with_Configure {
  local -r prefix="$1"
  ./Configure -des "-Dprefix=${prefix}" "${@:2}"
  make_and_install
}

function build_perl {
  local -r name="$1"
  local -r version="$2"
  local -r release_urls_base="$3"
  local -ra configure_args=( "${@:4}" )

  local -r source_dir="$(fetch_extract_source_release "$name" "$version" "$release_urls_base")"

  local -r install_dir="$(with_pushd "$source_dir" mkdirp_absolute_path "${name}-install")"

  with_pushd >&2 "$source_dir" \
                 build_with_Configure "$install_dir" "${configure_args[@]}"

  # NB: The below two lines are debugging info.
  echo >&2 "$source_dir" "$install_dir"
  ls -lAvF >&2 "$install_dir"
  # TODO: checking if this is an empty array is Very Hard.
  # if [[ "${#configure_args[@]}" -eq 0 || "${configure_args[1]:-}" == '' ]]; then
  local -ra output_paths=( $(with_pushd "$install_dir" find . -executable -type f) )
  with_pushd "$install_dir" \
             create_gz_package "$name" "${output_paths[@]}"
}

build_perl \
  perl \
  "${1:-latest}" \
  'www.cpan.org/src/5.0'
