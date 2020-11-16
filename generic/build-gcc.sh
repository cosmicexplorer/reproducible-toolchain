#!/bin/bash

source "$(git rev-parse --show-toplevel)/utils.v1.sh"

set_strict_mode

source ./lib-configure.sh

function build_gcc_out_of_tree {
  local -r name="$1"
  local -r version="$2"
  local -r release_urls_base="$3"
  local -ra configure_args=( "${@:4}" )

  local -r source_dir="$(fetch_extract_source_release "$name" "$version" "$release_urls_base")"

  check_cmd_or_err 'wget'
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

function build_osx {
  local -r version="$1"
  local -r osx_release_numeric="$2"
  local -r target_desc="x86_64-apple-darwin${osx_release_numeric}"
  build_gcc_out_of_tree \
    gcc \
    "$version" \
    "ftpmirror.gnu.org/gnu/gcc/gcc-${version}" \
    --host="$target_desc" \
    --target="$target_desc" \
    "${CONFIGURE_BASE_ARGS[@]}"
}

function build_linux {
  local -r version="$1"
  # Note: gcc seems to be the only gnu project with this sharded download URL format.
  build_gcc_out_of_tree \
    gcc \
    "$version" \
    "ftpmirror.gnu.org/gnu/gcc/gcc-${version}" \
    "${CONFIGURE_BASE_ARGS[@]}"
}

## Interpret arguments and execute build.

# TODO: (on  OSX): I haven't been  able to get  this to build  without appending $(uname -r)  to the
# --host and --target  specs -- this is  again what is done in  homebrew. I don't know  if this will
# cause subtle or non-subtle incompatibilities with earlier versions of OSX.
# Tested on High Sierra, where $(uname -r)=='17.4.0'

readonly GCC_VERSION="${1:-10.2.0}" TARGET_OS="${2:-$(uname)}" TARGET_ARCH="${3:-$(uname -r)}"

case "$TARGET_OS" in
  Darwin)
    # There are race conditions with parallel make, or at least, I have found
    # weird errors occur whenever I try to use make with parallelism. This might
    # be worth investigating at some point. This may be related to this comment
    # on the homebrew formula for gcc 7.3.0: https://github.com/Homebrew/homebrew-core/blob/a58c7b32c9ab679bc5f1afecc45f315710676ba1/Formula/gcc.rb#L56
    readonly MAKE_JOBS=1
    with_pushd "$(mkdirp_absolute_path "gcc-${GCC_VERSION}-osx")" \
               build_osx "$GCC_VERSION" "$TARGET_ARCH"
    ;;
  Linux)
    # TODO: use $TARGET_ARCH in this branch somehow (to tag things?)?
    # Default to 2 parallel make jobs if unspecified.
    with_pushd "$(mkdirp_absolute_path "gcc-${GCC_VERSION}-linux")" \
               build_linux "$GCC_VERSION"
    ;;
  *)
    die "gcc does not support building for OS '${TARGET_OS}' (as per 'uname')!"
    ;;
esac
