#!/bin/env bash

status=1
# yq arguments:
# -y: Output in yaml format (not json)
# -M:  No color
# -e:  Fail if nothing is found

yq -y -M -e \
    '
    # Select the top-level key "$graph"
    .["$graph"]

    # Iterate over the entries in "$graph"
    .[]

    # Extract keys "class" and "id"
    | {
            class: .class,
            id: .id
        }
    ' $1

status=$?

exit "$status"
