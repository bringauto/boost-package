#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BOOST_VERSION="1_76_0"
BUILD_DIR="${SCRIPT_DIR}/boost_build"
INSTALL_DIR="${SCRIPT_DIR}/boost_install"
ARCHIVE_DIR="${SCRIPT_DIR}/boost_archive"

get_suffix() {
	local system_version=$(lsb_release -sr | tr -d '.')
	local system_name=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
	local system_machine=$(uname -m | tr '_' '-')
	echo "${system_machine}-${system_name}-${system_version}"
}


build_options="cxxflags=-std=c++14"
build_options="${build_options} cxxflags=-fPIC cflags=-fPIC"

echo "Additional build options: ${build_options}"

mkdir -p "${BUILD_DIR}"
pushd "${BUILD_DIR}" || exit 1
	boost_version_with_dots="$(echo ${BOOST_VERSION} | sed 's/_/./g' )"
	wget https://boostorg.jfrog.io/artifactory/main/release/${boost_version_with_dots}/source/boost_${BOOST_VERSION}.tar.gz
	tar -xf "boost_${BOOST_VERSION}.tar.gz"

	mkdir -p "${INSTALL_DIR}"
	pushd boost_${BOOST_VERSION} || exit 1
		./bootstrap.sh
		./b2 --prefix="${INSTALL_DIR}" \
			runtime-link=shared,static link=shared,static variant=debug,release threading=multi \
			${build_options} \
			--without-python \
			address-model=64 --layout=tagged \
			-j 16 install 
	popd || exit 1

	mkdir -p "${ARCHIVE_DIR}"
	pushd "${ARCHIVE_DIR}" || exit 1
		platform_string=$(get_suffix)
		archive_name="libboost-dev_v${boost_version_with_dots}-${platform_string}.tar.bz2"
		tar -jcf ${archive_name} -C ${SCRIPT_DIR}/boost_install/ .
	popd || exit 1
	mv ${ARCHIVE_DIR}/*.tar.bz2 ./
popd || exit 1

mv ${BUILD_DIR}/*.tar.bz2 ./

