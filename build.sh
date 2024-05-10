#! /bin/bash -eu

gcc_version=13.2.0
cmake_version=3.29.3
ql_version=v1.34
while getopts "g:c:q:" flag
do
    case $flag in
        g) gcc_version=$OPTARG ;;
        c) cmake_version=$OPTARG ;;
        q) ql_version=$OPTARG ;;
    esac
done
shift $((OPTIND - 1))

echo "Building QuantLib ${ql_version} using GCC ${gcc_version}"

image_coords=gcc:${gcc_version}
docker pull $image_coords

project_dir=$(dirname $0)
tmp_dir=${project_dir}/tmp
mkdir -p $tmp_dir

cmake_name=cmake-${cmake_version}-linux-x86_64
cmake_archive=${tmp_dir}/${cmake_name}.tar.gz
cmake_dir=${tmp_dir}/${cmake_name}
if [[ ! -d $cmake_dir ]]
then
    curl --fail --location -o $cmake_archive https://github.com/Kitware/CMake/releases/download/v${cmake_version}/${cmake_name}.tar.gz
    tar xf $cmake_archive -C $tmp_dir
fi

ql_dir=${tmp_dir}/QuantLib
if [[ ! -d $ql_dir ]]
then
    git clone https://github.com/lballabio/QuantLib.git $ql_dir
else
    git -C $ql_dir pull --ff-only
fi

docker run \
    --mount type=bind,source=${cmake_dir},destination=/root/cmake,readonly \
    --mount type=bind,source=${ql_dir},destination=/root/QuantLib.origin,readonly \
    --mount type=bind,source=${project_dir}/build_inner.sh,destination=/root/build_inner.sh,readonly \
    --mount type=bind,source=${project_dir}/DiscountingCurveDemo.cpp,destination=/root/DiscountingCurveDemo.cpp,readonly \
    --rm \
    $image_coords \
    /root/build_inner.sh $ql_version
