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

mount_opt() {
    local source_path=$1
    local dest_name=$2
    echo --mount type=bind,source=${source_path},destination=/root/${dest_name},readonly
}

if [[ $gcc_version =~ / ]]
then
    image_coords=buildpack-deps:bullseye
    extra_docker_args=$(mount_opt $gcc_version gcc.tar.gz)
    echo "Using base image ${image_coords} and GCC tarball ${gcc_version}"
else
    image_coords=gcc:${gcc_version}
    extra_docker_args=
    echo "Using GCC image ${image_coords}"
fi

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

container_name=$(mktemp -u $(basename $0 .sh).XXXXXXXXXXXXXXXX)
echo "container_name=${container_name}"

trap "docker kill ${container_name} || true" EXIT

docker run \
    --name $container_name \
    $(mount_opt $cmake_dir cmake) \
    $(mount_opt $ql_dir QuantLib.origin) \
    $(mount_opt ${project_dir}/build_inner.sh build_inner.sh) \
    $(mount_opt ${project_dir}/DiscountingCurveDemo.cpp DiscountingCurveDemo.cpp) \
    $extra_docker_args \
    --rm \
    $image_coords \
    /root/build_inner.sh $ql_version

echo "Finished in ${SECONDS} sec"
