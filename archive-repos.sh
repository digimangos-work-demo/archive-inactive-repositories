#!/bin/bash

DAYS_AGO=365  # Default number of days
EXECUTE=false

while getopts "o:d:e" opt; do
  case $opt in
    o)
      ORG_NAME="$OPTARG"
      ;;
    d)
      DAYS_AGO="$OPTARG"
      ;;
    e)
      EXECUTE=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

if [ -z "$ORG_NAME" ]; then
  echo "Organization name (-o) is mandatory."
  exit 1
fi

if [ "$EXECUTE" = true ]; then
  echo "Executing"
else
  echo "Executing as Dry run mode"
fi

# Set the number of days ago as a date (compatible with macOS and Linux)
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  DATE_SINCE=$(date -v -${DAYS_AGO}d +%Y-%m-%d)
else
  # Linux (Ubuntu and others)
  DATE_SINCE=$(date -d "$DAYS_AGO days ago" +%Y-%m-%d)
fi

query=$(cat <<EOF
query(\$owner: String!, \$dateSince: GitTimestamp!, \$cursor: String) {
  organization(login: \$owner) {
    repositories(first: 100, after: \$cursor) {
        pageInfo {
            hasNextPage
            endCursor
        }
        nodes {
          name
          isArchived
          refs(refPrefix: "refs/heads/", last: 1) {
            nodes {
              target {
                ... on Commit {
                  history(first: 1, since: \$dateSince) {
                    totalCount
                  }
                }
              }
            }
          }
        }
    }
  }
}
EOF
)

# Execute the query using the GitHub GraphQL API
response=$(gh api graphql --paginate -f query="${query}" -f owner="${ORG_NAME}" -f dateSince="${DATE_SINCE}T00:00:00")

# Extract and process the data
repositories=$(echo "$response" | jq -r '.data.organization.repositories.nodes[] | select(.isArchived == false) | select(.refs.nodes[0].target.history.totalCount == 0) | .name')

for repo in $repositories; do
  # Archive the repository
  echo "  Archiving $repo..."
  if [ "$EXECUTE" = true ]; then
    gh repo archive -y "${ORG_NAME}/${repo}"
  fi
done

echo "Script completed."
