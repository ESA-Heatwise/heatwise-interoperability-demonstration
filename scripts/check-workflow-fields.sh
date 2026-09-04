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

echo Required keys present: $(yq -M -e '.["$graph"][] | select(.class == "CommandLineTool") | has("requirements") and (.requirements | has("DockerRequirement"))' $1)

status_b=$?

exit $status_a || $status_b
