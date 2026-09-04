#!/bin/env bash
status=1

last_entry=$(realpath ${1}/$(ls -tr $1 | tail -n 1))

echo $last_entry

status=$?

exit "$status"

