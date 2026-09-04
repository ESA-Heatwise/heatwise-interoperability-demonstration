#!/bin/env bash

# Fails, if there are no directory typed inputs in the workflow

echo "Running"

status=1

# yq arguments:
# -M:  No color
# -e:  Fail if nothing is found

CWL_CLASS=${1:Workflow}

yq -y -M -e "
    # Select the workflow from the graph
    (
        # From the top-level graph
        .[\"\$graph\"]

        # iterate over all entries (these are the Workflows and CommandLine Tools)
        []

        # Select the entries of type workflow (just one)
        | select(.class == \"${CWL_CLASS}\")
     )
     # Iterate over all entries of the \"inputs\" array
     .inputs

     # Select those that have type Directory
     | map(select(.type == \"Directory\"))

     # Wrap into an object with directory type
     | {\"inputs_with_directory_type\": .}
     " $2

status=$?

exit "$status"

