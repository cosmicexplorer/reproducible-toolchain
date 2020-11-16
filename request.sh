#!/bin/sh

# We only assume the barest POSIX environment at this point, hence a /bin/sh shebang.
# TODO: really? /bin/sh redirects to bash for me on Arch Linux.
if [[ "$#" -ne 3 ]]; then
  echo >&2 "Usage: $0 name version arch_subdir"
  exit 1
fi

_name="$1"
_version="$2"
_arch_subdir="$3"

# ./request.sh binutils 2.30 linux/x86_64
_full_path="./build-support/bin/${_name}/${_arch_subdir}/${_version}"
cd "$_full_path"
echo >&2 "_full_path=${_full_path}"
./build.sh >&2
echo "$(pwd)/${_name}.tar.gz"
