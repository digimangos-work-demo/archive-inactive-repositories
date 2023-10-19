# GitHub Repository Archive Script

This Bash script helps you archive GitHub repositories that haven't received any commits since a specified number of days in the past. It uses the GitHub GraphQL API and the GitHub CLI tool (gh) for this purpose. You can use this script to perform the archive operation or perform a dry run to report the repositories that meet the archiving criteria.

## Usage

1. Make sure you have the GitHub CLI (gh) installed and authenticated.

2. Download the script or copy the script content to a file (e.g., `archive-repos.sh`).

3. Make the script executable:

   - `chmod +x archive-repos.sh`

4. Run the script with the following command-line options:

   - `-o`: Specify the GitHub organization name (mandatory).
   - `-d`: Specify the number of days (default is 365) to identify inactive repositories.
   - `-e`: Execute the archive operation. Omitting this option will perform a dry run to report repositories without actually archiving them.

**Example usages:**

- To perform a dry run and report repositories without archiving:

  - `./archive-repos.sh -o your_organization`

- To execute the archive operation:

  - `./archive-repos.sh -o your_organization -e`

- To specify a custom number of days (e.g., 180) and execute the archive operation:

  - `./archive-repos.sh -o your_organization -d 180 -e`

## Executing as an action

- Create a token with the following scopes:
  - `read:org`
  - `repo`

- You can execute this script as an action using the following example worfklow:

  ```yaml
  name: Archive Repositories

  on:
    schedule:
      - cron: '0 0 * * *' # Schedule the workflow to run daily at midnight
    workflow_dispatch:    # Allow manual execution of the workflow

  jobs:
    archive:
      runs-on: ubuntu-latest

      env:
        GH_ORG: your_organization # Organization name
        DAYS_AGO: 365 # Default number of days (adjust as needed)

      steps:
        - name: Checkout code
          uses: actions/checkout@v2

        - name: Run Archive Script
          env:
            GH_TOKEN: ${{ secrets.GH_TOKEN }}
          run: |
            # Make the script executable
            chmod +x archive-repos.sh

            # Execute the script with GitHub token and environment variables
            ./archive-repos.sh -o "$GH_ORG" -d "$DAYS_AGO" -e
  ```

## Notes

- When performing the archive operation, make sure you have the necessary permissions.

- Be cautious when archiving repositories, especially in an organization setting. Ensure you have the necessary permissions and that the action aligns with your organization's policies.

- At the time of writing this script, the archive operation has the following warnings:
  - This repository will become read-only.
    You will still be able to fork the repository and unarchive it at any time.
  - All scheduled workflows will stop running.
  - Before you archive, please consider:
    - Updating any repository settings
    - Closing all open issues and pull requests
    - Making a note in your README

## License

This script is provided under the ISC License.

Feel free to modify and adapt it according to your needs.
