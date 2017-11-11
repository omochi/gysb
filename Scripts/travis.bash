#!/bin/bash

set -ue

swift_package_name="swift-4.0.2-RELEASE-ubuntu14.04"

repo_dir="$(pwd)"
cd "${repo_dir}/.."

wget https://swift.org/builds/swift-4.0.2-release/ubuntu1404/swift-4.0.2-RELEASE/${swift_package_name}.tar.gz
tar xzf ${swift_package_name}.tar.gz
export PATH="$(pwd)/${swift_package_name}/usr/bin:${PATH}"

cd "${repo_dir}"

tree TestResources

set +ue
