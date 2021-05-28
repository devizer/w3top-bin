script=https://raw.githubusercontent.com/devizer/test-and-build/master/install-build-tools-bundle.sh; (wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
Say "Building fio 2.26"
sudo apt-get update -qq
sudo apt-get install libc6-dev build-essential autoconf autoconf make wget -y -qq
url=https://brick.kernel.dk/snaps/fio-2.21.tar.gz
url=https://brick.kernel.dk/snaps/fio-3.26.tar.gz
libaio=https://pagure.io/libaio/archive/libaio-0.3.112/libaio-libaio-0.3.112.tar.gz
mkdir -p /build && cd /build
wget -q -nv --no-check-certificate -O _fio.tgz $url 
wget -q -nv --no-check-certificate -O _libaio.tgz $libaio 
tar xzf _fio.tgz
tar xzf _libaio.tgz

# build libaio
cd lib*
sudo make prefix=/usr install

# build fio --build-static
cd ../fio*
./configure --prefix=/usr/local | tee configure.log
make -j && sudo make install && echo "SUCCESS. $(fio --version) engines:" && fio --enghelp | tail -n +2 | sort
cat configure.log | grep "AIO"

export File_IO_BENCHMARK_OPTIONS="--time_based"
for engine in libaio io_uring posixaio pvsync2; do
  export File_IO_BENCHMARK_ENGINE=libaio
  Say "FIO Benchmark using $engine engine"
  File-IO-Benchmark $engine ~ 5G 30 1
done
