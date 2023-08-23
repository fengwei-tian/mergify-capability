#!/usr/bin/env bash
# Create a batch of github branches and trigger a Buildkite builds on each

if [[ $# != 3 ]]; then
    script=$(basename "$0")
    cat <<EOF
usage: $script [branch_name_prefix] [sequence start] [sequence end]"

optional environement variable:
- DEFAULT_BRANCH: default is master

This script will iterate from start to end, for each iteration it will:
- checkout the default branch
- create a github branch
- apply a simple change
- commit and push the branch
- trigger a buildkite build

ex: 
$script $USER-branch 01 10 # will create 10 branches $USER-XX and trigger a buidlkite build for each.
EOF
    exit 1
fi

# read args
branch_prefix=$1
start=$2
end=$3

# optional env variables
default_branch=${DEFAULT_BRANCH-master}

function pause() {
    # shellcheck disable=SC2162
    read -s -n 1 -p "Press any key to continue . . ."
    echo ""
}

# SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
temp_file=$(mktemp)

#get current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# create a sequence (2 digits)
for i in $(seq -f "%02g" "$start" "$end"); do
    RUN=$i

    branch="${branch_prefix}-${RUN}"

    # go back to master
    git checkout "$default_branch"

    # create the branch
    git checkout -b "$branch"

    # apply a simple change
    filename="README.md"
    echo >>$filename

    # create the commit
    git add $filename
    # addig '[ci full]' will trigger all tests
    git commit -n -m "do not merge - test buildkite ${RUN} [ci full]"

    # push the branch
    git push origin "$branch"

    # trigger bk
    # build=$("$SCRIPT_DIR/create-build.sh" "rippling-main-pr-tests" "$branch")
    # echo "Branch $branch, build $build" | tee -a "$temp_file"

    # (optional) open the pr
    #   open https://github.com/Rippling/rippling-main/pull/new/$branch

    # uncomment this line to wait after the branch is created
    #  pause
done

#cleanup - switching back to the branch (where the user started from)
git checkout "$current_branch"

#printing a new line for clarity
printf "\n"
# show summary
cat "$temp_file"
