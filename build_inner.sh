#! /bin/bash -eu

ql_version=$1

grep PRETTY_NAME /etc/os-release
gcc --version | head -1

cd

apt update
apt -y install libc6-dev make libboost-all-dev gfortran-

git clone QuantLib.origin QuantLib
(
    cd QuantLib
    git checkout $ql_version
    # apply fix for #1967 from 6bdb1e3f3
    sed -r -i '/^namespace QuantLib/ {h; s/.*/#include <algorithm>/; p; g;}' ql/time/schedule.cpp
    mkdir build
    cd build
    export CXXFLAGS="-O2 -ggdb -Wall -Wno-unknown-pragmas -std=c++14 -fno-math-errno -fno-trapping-math -DBOOST_MATH_NO_LONG_DOUBLE_MATH_FUNCTIONS"
    ~/cmake/bin/cmake .. -G "Unix Makefiles" -D CMAKE_BUILD_TYPE=Release -D QL_USE_STD_CLASSES=ON -D QL_USE_INDEXED_COUPON=ON -D QL_ERROR_LINES=ON
    make -j 8
)

g++ -std=c++17 -I QuantLib/build -I QuantLib -l QuantLib -L QuantLib/build/ql DiscountingCurveDemo.cpp -o DiscountingCurveDemo

LD_LIBRARY_PATH=QuantLib/build/ql ./DiscountingCurveDemo
