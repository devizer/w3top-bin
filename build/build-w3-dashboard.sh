#!/usr/bin/env bash
# wget -q -nv --no-check-certificate -O - https://raw.githubusercontent.com/devizer/KernelManagementLab/master/build-w3-dashboard.sh | bash -s reinstall_service  
set -e
set -u
if [[ $(uname -m) == armv7* ]]; then rid=linux-arm; elif [[ $(uname -m) == aarch64 ]]; then rid=linux-arm64; elif [[ $(uname -m) == x86_64 ]]; then rid=linux-x64; fi; if [[ $(uname -s) == Darwin ]]; then rid=osx-x64; fi;
echo "The current OS architecture: $rid"

function header() { LightGreen='\033[1;32m';Yellow='\033[1;33m';RED='\033[0;31m'; NC='\033[0m'; printf "${LightGreen}$1${NC} ${Yellow}$2${NC}\n"; }
counter=0;
function say() { counter=$((counter+1)); header "STEP $counter" "$1"; }



work=$HOME/transient-builds
if [[ -d "/transient-builds" ]]; then work=/transient-builds; fi
if [[ -d "/ssd" ]]; then work=/ssd/transient-builds; fi

clone=$work/publish/w3top-bin
rm -rf $clone; mkdir -p $(dirname $clone)
git clone git@github.com:devizer/w3top-bin $clone

work=$work/publish/KernelManagementLab;
# work=/mnt/ftp-client/KernelManagementLab;
mkdir -p "$(dirname $work)"
cd $(dirname $work);
rm -rf $work;
git clone https://github.com/devizer/KernelManagementLab;
cd KernelManagementLab/Universe.W3Top
dir=$(pwd)

pushd ../build >/dev/null
./inject-git-info.ps1
popd >/dev/null

cd ClientApp; time (yarn install); cd ..
for r in linux-x64 linux-arm linux-arm64; do
  verFile=../build/AppGitInfo.json
  ver=$(cat $verFile | jq -r ".Version")
  cp $verFile $clone/public/version.json

  say "Building $r [$ver]"
  time dotnet publish -c Release /p:DefineConstants="DUMPS" -o bin/$r/w3top --self-contained -r $r
  pushd bin/$r

  say "Compressing $r [$ver] as GZIP"
  time sudo bash -c "tar cf - w3top | pv | gzip -9 > ../w3top-$r.tar.gz"
  cp ../w3top-$r.tar.gz $clone/public/
  say "Compressing $r [$ver] as XZ"
  time sudo bash -c "tar cf - w3top | pv | xz -1 -z > ../w3top-$r.tar.xz"
  say "Compressing $r [$ver] as 7z"
  7z a "../w3top-$r.7z" -m0=lzma -mx=1 -mfb=256 -md=256m -ms=on 

  popd
done

pushd $clone
git add --all .
git commit "Update $ver"
git push
