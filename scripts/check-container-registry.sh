#!/bin/env bash

# Skopeo inspects the manifest in a docker registry.
# The command fails, if the image is not available.

# The latest version of skopeo on conda-forge has an issue with its configuration, we overwrite
# it here with a minimal configuration to avoid that error:
REGISTRIES_CONF_V2=/tmp/test-registries.conf
echo "unqualified-search-registries = [\"docker.io\"]" > $REGISTRIES_CONF_V2
export CONTAINERS_REGISTRIES_CONF=$REGISTRIES_CONF_V2

# We do not want to see the full output in case of success
skopeo inspect "docker://$1" >> /dev/null
status=$?

if [[ "$status" == 0 ]]; then
    echo "SUCCESS: Image $1 found on registry"
else
    echo "FAILURE: Image $1 not found on registry"
fi

exit $status
