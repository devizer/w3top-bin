#!/usr/bin/env bash

repo=w3top-bin
work=/transient-builds/defrag
pushd "$(dirname $0)" >/dev/null; ScriptDir="$(pwd)"; popd >/dev/null
mkdir -p $work
pushd $work
rm -rf $repo.git
git clone --mirror git@github.com:devizer/$repo
java -jar $ScriptDir/bfg-1.13.0.jar --strip-blobs-bigger-than 1M $repo.git

cd $repo.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
ver=$(cat ../public/version.txt)
echo "VERSION $ver"
git commit --allow-empty -m "Update $ver"
git push

popd
