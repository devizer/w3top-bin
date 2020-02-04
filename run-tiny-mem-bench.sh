#!/usr/bin/env bash
set -eu
url=https://github.com/ssvb/tinymembench/archive/v0.4.tar.gz
work=~/build/tinymembench-src
mkdir -p $work
pushd $work
curl -kLS -o $(basename $url) $url
tar xzf $(basename $url)
cd tinymembench*
time make
echo "Success: tinymembench build"
./tinymembench 
popd
