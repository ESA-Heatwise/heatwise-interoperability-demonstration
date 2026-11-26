#!/bin/env bash

status=1

yq -y -M -e '
    {
        "s:version": ."s:version",
        "https://schema.org/version": [.. | ."https://schema.org/version"? | select(. != null)] | first

    }
' $1

echo "Found version: " $(yq -e '
    [.. | objects | .["s:version"], .["https://schema.org/version"] | select(. != null)]
    | length > 0
    ' "$1")

status=$?

exit $status
