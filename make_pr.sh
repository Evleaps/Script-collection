#!/usr/bin/env bash

getTargetBranch() {
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    is_updated_from_main="$(
        git log --graph --decorate --simplify-by-decoration --oneline |
            grep -c "Merge branch 'main' into $current_branch"
    )"

    local target_branch
    if [ "$is_updated_from_main" != 0 ]; then
        target_branch="main"
    else
         git log --pretty=format:'%D' HEAD^ | grep 'origin/' | head -n1 | sed 's@origin/@@' | sed 's@,.*@@'
    fi

    echo "$target_branch"
}

function getTitle() {
    local current_branch current_branch_number current_branch_text

    current_branch=$(git rev-parse --abbrev-ref HEAD)
    current_branch_number=$(awk -F '[^0-9]+' '{ print $2 }' <<<"$current_branch")
    current_branch_text=${current_branch#*$current_branch_number}
    trimmed_current_branch_text=$(
        echo "$current_branch_text" |
            sed -r 's/[-_]+/ /g' |                                     # replace '-' and '_' to ' '
            awk '{gsub(/^[ \t]+/,""); print $0 }' |                    # trim spaces
            awk '{print toupper(substr($0,0,1))tolower(substr($0,2))}' # Uppercase first character
    )

    echo "JIRA-$current_branch_number: $trimmed_current_branch_text"
}

function getPrDescription() {
    local current_branch_number description
    current_branch_number="$(git rev-parse --abbrev-ref HEAD | awk -F '[^0-9]+' '{ print $2 }')"

    description="
### [$(getTitle)](https://companyname.atlassian.net/browse/JIRA-$current_branch_number)
---
### Description: \n
\n
### What was changed: \n
\n
### Screenshots/videos/gif:
"
    echo -e "$description"
}

base_url="https://github.com"
target_branch=$(getTargetBranch)
current_branch="$(git rev-parse --abbrev-ref HEAD)"
path="/company_repo/company_project/compare/$target_branch...$current_branch"

#query params
title=$(getTitle)
body=$(getPrDescription)
assignees="$(git config user.name)"
expand="1"

query="expand=$expand&title=$title&assignees=$assignees&body=$body"
open "$base_url/$path?$query"
