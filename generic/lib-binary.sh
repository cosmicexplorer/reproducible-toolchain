# TODO: how to declare a (build time!! because it occurs when creating bootstrap artifacts!!)
# dependency on git?
source "$(git rev-parse --show-toplevel)/utils.v1.sh"

set_strict_mode

function fetch_binary_release_archive {
  local -r url_base="$1"
  local -r archive_filename="$2"

  local -r release_url="${url_base}/${archive_filename}"

  curl_file_with_fail "$release_url" "$archive_filename"
}

export BOOTSTRAP_REPACKAGE_DIR="${BOOTSTRAP_REPACKAGE_DIR:-bootstrap-repackage}"

# TODO: how to declare a (build time!!) dependency on xz and tar?
function repackage_xz {
  local -r archive_base="$1"
  local -r gz_package_name="$2"

  local -r extracted="$(extract_for "${archive_base}.tar.xz" "$archive_base")"

  create_gz_package "$gz_package_name" \
                    "${extracted}"
}
