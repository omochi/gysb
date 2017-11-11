#!/bin/bash

set -ue

swift_version="swift-DEVELOPMENT-SNAPSHOT-2017-11-09-a"
swift_package_name="${swift_version}-ubuntu14.04"

repo_dir="$(pwd)"
cd "${repo_dir}/.."

wget https://swift.org/builds/development/ubuntu1404/${swift_version}/${swift_package_name}.tar.gz
tar xzf ${swift_package_name}.tar.gz
export PATH="$(pwd)/${swift_package_name}/usr/bin:${PATH}"

cd "${repo_dir}"