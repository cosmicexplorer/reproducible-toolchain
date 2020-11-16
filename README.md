reproducible-toolchain
======================

A home for scripts to build self-bootstrappable sets of binaries.

# CLI API
`./request.sh <name> [version=latest] [os=$(uname)] [arch=$(uname -m)]` generates a binary file representing `name` at `version` for the given `os` and `arch`.

## Formula for accepting pull requests
See [bootstrap/tree/master/README.md#tool-selection](https://github.com/cosmicexplorer/bootstrap/tree/master/README.md#tool-selection).

## Supported Platforms

See [bootstrap/tree/master/README.md#supported-platforms](https://github.com/cosmicexplorer/bootstrap/tree/master/README.md#supported-platforms).

# workflow

The general workflow for publishing new binaries is:

1. Create a script that will generate a binary file according to a set of parameters, and write it to stdout.
2. Get the script and links reviewed. During review, the reviewer should confirm that the script
   successfully produces a binary on their machine(s), on all supported platforms.
3. The script should then be merged *without* the produced binaries.

## building

### linux

*Requires [docker](https://www.docker.com/).*

1. Change directories to the root of this repository, and run:
  ```
  docker run -v "$(pwd):/pantsbuild-binaries" -w '/pantsbuild-binaries' --rm -it pantsbuild/centos6:latest /bin/bash
  ```
  ...to pop yourself in a controlled image back at this repo's root.

2. Run `./request.sh ...` to produce a file path pointing to the built binary tool over stdout.

### osx

We have no controlled build environment solution like we do for linux, so you'll need to get your hands on an OSX machine (TODO: yet!!!).  With that in hand:

1. Change directories to the root of this repository.
2. Run `./request.sh ...` to produce a file path pointing to the built binary tool over stdout.

## syncing

After merging, the reviewer should (re-)execute the script (if necessary), confirm that binaries have been created in all relevant symlinked directories, and then run:
     ```
     ./sync-s3.sh
     ```
  ...to upload the produced binaries to s3.

- TODO: produce an analogy that uploads using [pants's `fs_util`](https://github.com/pantsbuild/pants/tree/master/src/rust/engine/fs/fs_util)!
