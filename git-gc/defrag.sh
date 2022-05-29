#!/usr/bin/env bash

set -eu;
pushd "$(dirname $0)" >/dev/null; ScriptDir="$(pwd)"; popd >/dev/null

repo=w3top-bin
work=/transient-builds/defrag
Say "Degrag/strip [$repo] repo using [$work] working folder"
echo "Current folder: [$(pwd)]"

mkdir -p $work
pushd $work
rm -rf $repo.git
git clone --mirror git@github.com:devizer/$repo
java -jar $ScriptDir/bfg-1.13.0.jar --strip-blobs-bigger-than 1M $repo.git

cd $repo.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
Say "Push stripped [$repo] repo"
git push
popd

if [[ -z "${TRIGGER_COMMIT_MESSAGE:-}" ]]; then exit 0; fi

Say "Trigger [$repo] pipelines using [$work-again] folder"
echo "Current folder: [$(pwd)]"
git clone $w3topBinRepo $work-again
pushd $work-again
ver=$(cat ./public/version.txt)
echo "VERSION [$ver]"
git commit --allow-empty -m "Update $ver"
git push
popd
