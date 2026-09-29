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

# Every output of type Directory (i.e. staged-out EO products) must retrieve the entire
# working directory ("glob": "."). Outputs of other types (e.g. single intermediate
# files passed between workflow steps) are not concerned by the requirement.
all_dirs=$(yq -M -e '
    [
        .["$graph"][]
        | select(.class == "CommandLineTool")
        | .outputs[]
        | select(.type == "Directory")
        | .outputBinding.glob == "."
    ]
    | length > 0 and all
' $1)
status_b=$?

echo Extracts all items from Working directory: $all_dirs

[[ $status_a -eq 0 && $status_b -eq 0 ]]
