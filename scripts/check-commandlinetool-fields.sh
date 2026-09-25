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
    | {
        "id": .id,
        "baseCommand": .baseCommand,
        "requirements": .requirements

    }

' $1

status_a=$?

# All CommandLineTools must have the required keys. "requirements" may be given as a
# mapping (class name as key) or as a list of objects with a "class" field.
found_keys=$(yq -M -e '
    [
        .["$graph"][]
        | select(.class == "CommandLineTool")
        | has("id") and has("baseCommand") and has("inputs") and has("requirements")
          and (.requirements
               | if type == "array" then any(.[]; .class == "DockerRequirement")
                 else has("DockerRequirement") end)
    ]
    | length > 0 and all
' $1)
status_b=$?

echo Required keys present: $found_keys

[[ $status_a -eq 0 && $status_b -eq 0 ]]
