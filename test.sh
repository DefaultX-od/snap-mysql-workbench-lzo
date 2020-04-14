#!/bin/bash
set -euo pipefail
# Simple script to rebuild and run

# Latest version from mysql
VERSION_ONLINE=$(curl -sS "http://repo.mysql.com/apt/ubuntu/dists/bionic/mysql-tools/binary-amd64/Packages" | grep -PA2 '^Package: mysql-workbench-community$'| grep -Po '^Version: \K(\d+\.\d+\.\d+)')

VERSION_LOCAL=$(grep 'version' snapcraft.yaml |awk '{print $2}')

if [ "$VERSION_LOCAL" != "$VERSION_ONLINE" ]; then
    echo >&2 "Version to be installed and local version don't match"
    echo >&2 " - Online: $VERSION_ONLINE"
    echo >&2 " - Local:  $VERSION_LOCAL"
    exit 1
fi

# Unistall old snap
sudo snap remove mysql-workbench-community

# Clean up old builds
rm -f mysql-workbench*.snap

# clean all cache
snapcraft clean --use-lxd

# Build new image
snapcraft --use-lxd --debug

# Install new image
sudo snap install --devmode mysql-workbench*.snap

# Run new snap
snap run mysql-workbench-community

# Deploy
# snapcraft push --release=beta mysql-workbench*.snap