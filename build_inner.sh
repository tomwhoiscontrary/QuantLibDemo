#! /bin/bash -eu

ql_version=$1

grep PRETTY_NAME /etc/os-release

cd

apt update

if [[ -f gcc.tar.gz ]]
then
    echo "Using GCC from tarball"

    apt -y remove gcc g++ binutils
    apt -y autoremove
    apt-mark hold gcc g++ binutils

    mkdir gcc
    tar xf gcc.tar.gz -C gcc
    export PATH=/root/gcc/bin:$PATH
    extra_library_path=/root/gcc/lib64

    # our packaged GCC has multiarch disabled, so add paths necessary on Debian
    export CPATH=/usr/include/x86_64-linux-gnu
    export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu
else
    extra_library_path=
fi

gcc --version | head -1

apt -y install libc6-dev make libboost-all-dev gfortran-

mkdir --parents ql

git clone QuantLib.origin QuantLib
(
    cd QuantLib
    git checkout $ql_version
    # apply fix for #1967 from 6bdb1e3f3
    sed -r -i '/^namespace QuantLib/ {h; s/.*/#include <algorithm>/; p; g;}' ql/time/schedule.cpp
    mkdir build
    cd build
    export CXXFLAGS="-O2 -ggdb -Wall -Wno-unknown-pragmas -std=c++14 -fno-math-errno -fno-trapping-math -DBOOST_MATH_NO_LONG_DOUBLE_MATH_FUNCTIONS"
    ~/cmake/bin/cmake .. \
        -G "Unix Makefiles" \
        -D CMAKE_BUILD_TYPE=Release \
        -D QL_USE_STD_CLASSES=ON \
        -D QL_USE_INDEXED_COUPON=ON \
        -D QL_ERROR_LINES=ON \
        -D QL_INSTALL_BENCHMARK=OFF \
        -D QL_INSTALL_EXAMPLES=OFF \
        -D QL_INSTALL_TEST_SUITE=OF \
        -D CMAKE_INSTALL_PREFIX=../../ql
    make -j 8
    make install
)

g++ -std=c++17 -Wall -fno-math-errno -fno-trapping-math -ggdb -O2 -I ql/include -l QuantLib -L ql/lib DiscountingCurveDemo.cpp -o DiscountingCurveDemo

LD_LIBRARY_PATH=${extra_library_path}:QuantLib/build/ql ./DiscountingCurveDemo
