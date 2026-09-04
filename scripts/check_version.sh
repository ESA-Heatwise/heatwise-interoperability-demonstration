#!/bin/env bash

status=1

yq -y -M -e '
    {
        "s:version": ."s:version"
    }
' $1

status=$?

exit $status
