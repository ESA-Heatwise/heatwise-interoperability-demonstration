#!/bin/env bash

status_a=1
status_b=1

yq -y -M -e '
# Select the CommandLineTool(s) from the graph
    (
        # From the top-level graph
        .["$graph"]

        # iterate over all entries (these are the Workflows and CommandLine Tools)
        []

        # Select the entries of type CommandLineTool
        | select(.class == "CommandLineTool")
    )

    # Check for presence of fields required by EOAP best practice
    | .outputs

' $1

status_a=$?

echo Extracts all items from Working directory: $(
    yq -M -e '
        # Select the CommandLineTool(s) from the graph
        .["$graph"][]
        | select(.class == "CommandLineTool")
        # Check all entires in the outputs field:
        | .outputs[]
        # The outputBinding is "glob": "." which means that all files from the working directory are included as outputs
        .outputBinding.glob == "."
    ' $1
)

status_b=$?

exit $status_a || $status_b
