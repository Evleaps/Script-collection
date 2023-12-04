#!/usr/bin/env bash

getTargetBranch() {
    # Tried determine the parent branch but didn't find no one stable solution
    # Will change main to your target branch
    echo "dev"
}

# Current branch is: JIRA-1916-fix-crash-on-main-screen
# Will be converted to: JIRA-1916: Fix crash on main screen
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

    # Will change `JIRA` to your real Jira project abbreviation (from the jira task link)
    echo "JIRA-$current_branch_number: $trimmed_current_branch_text"
}

function getPrDescription() {
    local current_branch_number description
    current_branch_number="$(git rev-parse --abbrev-ref HEAD | awk -F '[^0-9]+' '{ print $2 }')"

    # Will change `JIRA` to your real Jira project abbreviation (from the jira task link)
    description="
[$(getTitle)](https://globalradio.atlassian.net/browse/JIRA-$current_branch_number)
---
<h3>Description:</h3> \n
\n
<h3>What was changed:</h3> \n
\n
<h3>Screenshots/videos/gif:</h3>
\n
\n
<details>
  <summary>PR Tips</summary>

  - How to build the template script: ./gradlew makepr
  - The bash script name is: make_pr.sh
  - The table example for copy paste:

  | Before | After |
  |------|------|
  |Your image before|Your image after|

</details>
"
    echo -e "$description"
}

base_url="https://github.com"
target_branch=$(getTargetBranch)
current_branch="$(git rev-parse --abbrev-ref HEAD)"
# Will change company_repo and company_project ro real values of your project
path="/company_repo/company_project/compare/$target_branch...$current_branch"

#query params
title=$(getTitle)
body=$(getPrDescription)
assignees="$(git config user.name)"
expand="1"

query="expand=$expand&title=$title&assignees=$assignees&body=$body"
open "$base_url/$path?$query"
