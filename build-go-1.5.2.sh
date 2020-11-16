#!/bin/sh

ARCHS=(
  darwin-amd64
  linux-386
  linux-amd64
)

for arch in ${ARCHS[@]}
do
  curl -O https://storage.googleapis.com/golang/go1.5.2.${arch}.tar.gz
done
