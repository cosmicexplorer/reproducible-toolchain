#!/bin/bash

source ./utils.v1.sh

set_strict_mode

source generic/lib-configure.sh

function build_gcc_out_of_tree {
  local -r name="$1"
  local -r version="$2"
  local -r release_urls_base="$3"
  local -ra configure_args=( "${@:4}" )

  local -r source_dir="$(fetch_extract_source_release "$name" "$version" "$release_urls_base")"

  # This script is a great tool, it saves a ton of time downloading and
  # configuring gmp, mpc, isl, and mpfr per-platform.
  # Redirect to stderr because we "return" a path to our .tar.gz by stdout.
  with_pushd >&2 "$source_dir" \
                 ./contrib/download_prerequisites

  local -r build_dir="$(mkdirp_absolute_path 'gcc-build')"
  local -r install_dir="$(with_pushd "$source_dir" mkdirp_absolute_path "${name}-install")"

  CONFIGURE_PATH="${source_dir}/configure" \
                with_pushd >&2 "$build_dir" \
                               build_with_configure --prefix "$install_dir" \
                               "${configure_args[@]}"

  # NB: The below two lines are debugging info.
  echo >&2 "$source_dir" "$build_dir" "$install_dir"
  ls -lAvF >&2 "$source_dir" "$build_dir" "$install_dir"
  # TODO: checking if this is an empty array is Very Hard.
  # if [[ "${#configure_args[@]}" -eq 0 || "${configure_args[1]:-}" == '' ]]; then
  with_pushd "$install_dir" \
             create_gz_package "$name"
}

readonly SUPPORTED_LANGS='c,c++'

readonly -a CONFIGURE_BASE_ARGS=(
  --disable-multilib
  --without-gstabs
  --enable-languages="${SUPPORTED_LANGS}"
  --with-pkgversion="bootstrap-packaged"
  --with-bugurl='https://github.com/cosmicexplorer/bootstrap/issues'
)

function build_gcc {
  local -r version="$1"
  # Note: gcc seems to be the only gnu project with this sharded download URL format.
  build_gcc_out_of_tree \
    gcc \
    "$version" \
    "ftpmirror.gnu.org/gnu/gcc/gcc-${version}" \
    "${CONFIGURE_BASE_ARGS[@]}"
}

readonly LATEST_VERSION='10.2.0'
## Interpret arguments and execute build.

readonly _GCC_VERSION_ARG="${1:-latest}"
readonly TARGET_OS="${2:-$(uname)}"
# TODO: (on  OSX): I haven't been  able to get  this to build  without appending $(uname -r)  to the
# --host and --target  specs -- this is  again what is done in  homebrew. I don't know  if this will
# cause subtle or non-subtle incompatibilities with earlier versions of OSX.
# Tested on High Sierra, where $(uname -r)=='17.4.0'
readonly TARGET_ARCH="${3:-$(uname -r)}"

if [[ "$_GCC_VERSION_ARG" == 'latest' ]]; then
  readonly GCC_VERSION="$LATEST_VERSION"
else
  readonly GCC_VERSION="$_GCC_VERSION_ARG"
fi

with_pushd "$(mkdirp_absolute_path "gcc-${GCC_VERSION}-${TARGET_OS}")" \
           build_gcc "$GCC_VERSION"
