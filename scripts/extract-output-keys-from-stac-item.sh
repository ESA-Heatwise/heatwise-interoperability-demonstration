#!/bin/env bash

# Fails, if there required keys are not present

status_a=1
status_b=1

# yq arguments:
# -M:  No color
# -e:  Fail if nothing is found

yq -y -M -e '
    {
        geometry: {
            type: .geometry.type,
            coordinates: "[...truncated...]"
        },
        bbox: .bbox,
        properties: {
            datetime: .properties.datetime
        }
    }
    ' $1

status_a=$?

found_keys=$(yq -M -e '(has("geometry") and (.geometry | has("coordinates"))) and (.geometry != null and .bbox != null) and (.properties | has("datetime"))' $1)
status_b=$?

echo ""
echo "Required keys present: $found_keys"


[[ $status_a -eq 0 && $status_b -eq 0 ]]
