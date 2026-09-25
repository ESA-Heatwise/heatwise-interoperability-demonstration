#!/bin/env bash

status_a=1
status_b=1

yq -y -M -e '
# Select the Workflow from the graph
    (
        # From the top-level graph
        .["$graph"]

        # iterate over all entries (these are the Workflows and CommandLine Tools)
        []

        # Select the entries of type workflow (just one)
        | select(.class == "Workflow")
    )

    # Check for presence of fields required by EOAP best practice
    | {
        "id": .id,
        "label": .label,
        "doc": .doc,
    }

' $1

status_a=$?

found_keys=$(yq -M -e '
    [
        .["$graph"][]
        | select(.class == "Workflow")
        | has("id") and has("label") and has("doc")
    ]
    | length > 0 and all
' $1)
status_b=$?

echo Required keys present: $found_keys

[[ $status_a -eq 0 && $status_b -eq 0 ]]
