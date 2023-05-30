#!/bin/bash

NIM_VERSIONS=( "1.0.0" "1.6.0" "1.6.10" "1.6.12" "#head" "stable" )
TEST_RESULTS=()

COL_RED='\033[0;31m'
COL_GREEN='\033[0;32m'


function test_version() {
    version=$1
    echo -e "Testing with Nim version $version"

    # Run tests:
    choosenim "$version"
    nimble test
}

for version in "${NIM_VERSIONS[@]}"; do
    test_version "$version"
    exit_code=$?
    colour="0"
    if [ "$exit_code" -eq "0" ]
        then colour="$COL_GREEN"  # Set output to green
        else colour="$COL_RED"    # Set output to red
    fi

    TEST_RESULTS+=("$colour""Nim $version\texit code: $exit_code \033[0m")
done


# Tests complete:
echo -e "\nTest results complete:"
for result in "${TEST_RESULTS[@]}"; do
    echo -e "\t$result"
done

