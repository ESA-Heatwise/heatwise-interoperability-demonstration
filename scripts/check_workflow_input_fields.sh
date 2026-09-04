#!/bin/env bash

status=1

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
    .inputs

    # Convert to normalized format (CWL allows explict id or using the id as the key for a mapping instead)
    | to_entries

    # Check for presence of fields required by EOAP best practice
    | {
        inputs: map({
            "id": .key,
            "label": .value.label,
            "doc": .value.doc,
        })
    }
' $1

status=$?

exit $status
