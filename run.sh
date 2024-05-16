#! /bin/bash -eu

mkdir -p tmp/results
for ql_version in v1.31 v1.31.1 v1.32 v1.33 v1.34
do
    for gcc_version in 7.5.0 8.5.0 9.5.0 10.5.0 11.4.0 12.3.0 13.2.0
    do
        echo -n "${ql_version} ${gcc_version} ... "
        ./build.sh -q $ql_version -g $gcc_version >tmp/results/ql.${ql_version}_gcc${gcc_version}.log 2>&1 && echo ok || echo NO
    done
done
