#!/bin/sh

source "$(git rev-parse --show-toplevel)/utils.v1.sh"

set_strict_mode

function fetch_cloc_script {
  local -r version="$1"

  local -r script_filename="cloc-${version}.pl"
  # NB: from v1.66 the package goes back and forth on the naming scheme with or without the 'v'.
  # 'v1.76' appears to have been the last such release:
  # https://github.com/AlDanial/cloc/releases?after=1.78.
  # TODO: introduce a URL retrying feature? it could cover for inconsistencies like this in a way
  # that doesn't require constant maintenance?
  local -r release_url="https://github.com/AlDanial/cloc/releases/download/${version}/${script_filename}"
  curl_file_with_fail "$release_url" "$script_filename"
}

## Interpret arguments and execute build.

readonly CLOC_VERSION="${1:-1.88}"
readonly subdir="cloc-${CLOC_VERSION}-build-result"

with_pushd "$(mkdirp_absolute_path "$subdir")" \
           fetch_cloc_script "$CLOC_VERSION"
