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

echo "Required keys present: $(yq -M -e 'has("geometry") and (.geometry | has("coordinates"))' $1)"

status_b=$?

exit $status_a || $status_b
