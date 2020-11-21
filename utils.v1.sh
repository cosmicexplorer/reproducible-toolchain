# -*- mode: sh; sh-shell: bash -*-

# Not an executable. Can be sourced by other scripts in this repo for some free
# error checking for common operations. Uses bash-specific features including
# `local`.

# see bash(1)
function set_strict_mode {
  set -euxo pipefail
}

# Display a message to stderr.
function warn {
  echo >&2 "$@"
}

# Display a message to stderr, then exit with failure.
function die {
  warn "$@"
  exit 1
}

# Display a message read from stdin to stderr, then exit with failure. This can
# be used with heredocs (<<EOF and friends).
function die_here {
  cat >&2
  exit 1
}

# Check for the existence of a command, and fail if it's not there. If a command
# has variations in functionality between Linux and OSX, additional checks may
# be required.
function check_cmd_or_err {
  local -r cmd_name="$1"
  if ! hash "$cmd_name"; then
    die_here <<EOF
The command '${cmd_name}' is required to run this script. You may have to
install it using your operating system's package manager.
EOF
  fi
}

# Verify that a path exists, and echo the absolute path (not canonical or
# normalized!).
function get_existing_absolute_path {
  local -r path_arg="$1"
  # -f is an "illegal option" for OSX readlink, so this may have e.g. `/../`
  # within it.
  local -r abs_path="$(readlink -f "$path_arg")"

  if ! [[ -f "$abs_path" || -d "$abs_path" ]]; then
    die "File at path '${path_arg}' (relative to pwd '$(pwd)') was expected to exist, but does not."
  fi

  echo "$abs_path"
}

function _bootstrap_gawk {
  local -r gawk_bin="$(declare_bin_dependency gawk)"
  PATH="${gawk_bin}:$PATH" \
      gawk "$@"
}

function _checksum {
  sha256sum "$@" | _bootstrap_gawk '{print $1}'
}

function _count_bytes {
  wc -c "$@" | _bootstrap_gawk '{print $1}'
}

declare BOOTSTRAP_CURL_OUTPUT_DIR="${BOOTSTRAP_CURL_OUTPUT_DIR:-bootstrap-curl-output}"
export NO_CURL_CHECKSUM="${NO_CURL_CHECKSUM:-}"

function _curl_and_check {
  local -r url="$1" expected_outfile="$2"
  local -ra curl_args=( "${@:3}" )

  local -r checksum_file="${expected_outfile}.digest"
  local -r size_file="${expected_outfile}.size_bytes"
  if [[ -z "$NO_CURL_CHECKSUM" && -f "$expected_outfile" && -f "$checksum_file" && -f "$size_file" ]]; then
    local checksum="$(_checksum "$expected_outfile")"
    local size="$(_count_bytes "$expected_outfile")"
    if [[ "$checksum" == "$(cat "$checksum_file")" && "$size" == "$(cat "$size_file")" ]]; then
      get_existing_absolute_path "$expected_outfile"
      return "$?"
    fi
  fi

  if [[ "${#curl_args[@]:-}" -eq 0 ]]; then
    curl >&2 -L --fail -O "$url"
  else
    curl >&2 -L --fail -O "$url" "${curl_args[@]}"
  fi


  if [[ -z "$NO_CURL_CHECKSUM" ]]; then
    local checksum="$(_checksum "$expected_outfile")"
    local size="$(_count_bytes "$expected_outfile")"
    echo "$checksum" > "$checksum_file"
    echo "$size" > "$size_file"
  fi

  get_existing_absolute_path "$expected_outfile"
}

# Download a file from a given URL, with verbose output, and exiting with
# failure on server errors. --fail should probably be on by default, so probably
# keep that if you add any other curl wrappers.
function curl_file_with_fail {
  with_pushd "$(mkdirp_absolute_path "$BOOTSTRAP_CURL_OUTPUT_DIR")" \
             _curl_and_check "$@"
}

# Make a new directory (that may already exist) and echo the absolute path.
function mkdirp_absolute_path {
  local -r dir_relpath="$1"
  mkdir -p "$dir_relpath"
  get_existing_absolute_path "$dir_relpath"
}

# TODO: note that expected_output can be any of the extracted entries in the
# archive, not just a "root dir" or whatever
function do_extract {
  local -r archive_path="$1"

  case "$archive_path" in
    *.tar.xz)
      if [[ -z "${WITHIN_XZ:-}" ]]; then
        PATH="$(declare_bin_dependency 'xz'):${PATH}"
      fi
      tar xf "$archive_path"
      ;;
    *.tar.gz)
      tar zxf "$archive_path"
      ;;
    *.tgz)
      tar zxf "$archive_path"
      ;;
    *)
      die "Unrecognized file extension for compressed archive at '${archive_path}'."
      ;;
  esac
}

function _check_path {
  local -r result_path="$1"
  if [[ -e "$result_path" ]]; then
    get_existing_absolute_path "$result_path"
  else
    warn "Note: candidate '${result_path}' was not found!"
    return 1
  fi
}

export BOOTSTRAP_INTERMEDIATE_DIR="${BOOTSTRAP_INTERMEDIATE_DIR:-"$TOOLCHAIN_ROOT"/bootstrap-intermediates}"

function _extract_and_check_paths {
  local -r archive_path="$1"
  local -ra result_path_candidates=( "${@:2}" )

  do_extract "$archive_path" >&2

  for result_path in "${result_path_candidates[@]}"; do
    _check_path "$result_path"
  done
}

function extract_for {
  local -r archive_path="$(get_existing_absolute_path "$1")"
  local -ra result_path_candidates=( "${@:2}" )

  local -r intermediate_dir="$(mkdirp_absolute_path "$BOOTSTRAP_INTERMEDIATE_DIR")"

  with_pushd "$intermediate_dir" \
             _extract_and_check_paths "$archive_path" "${result_path_candidates[@]}"
}

function create_gz_package {
  local -r pkg_name="$1"
  local -a from_paths=("${@:2}")

  local -r pkg_archive_name="${pkg_name}.tar.gz"

  rm >&2 -fv "$pkg_archive_name"

  if [[ "${#from_paths[@]}" -eq 0 ]]; then
    tar >&2 cvzf "$pkg_archive_name" *
  else
    tar >&2 cvzf "$pkg_archive_name" "${from_paths[@]}"
  fi

  get_existing_absolute_path "$pkg_archive_name"
}

function with_pushd {
  local -r dest="$1"
  local -a cmd_line=("${@:2}")

  pushd >&2 "$dest"
  "${cmd_line[@]}"
  popd >&2
}

function declare_bin_dependency {
  local -ra request_args=( "$@" )

  local -r packed_archive="$(with_pushd "$TOOLCHAIN_ROOT" ./request.sh "${request_args[@]}")"

  # Return the 'bin' directory of the unpacked archive.
  extract_for "$packed_archive" 'bin'
}
