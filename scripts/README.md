# Continuous-Delphi GitHub Automation Scripts

This directory contains PowerShell automation scripts used to manage the
Continuous-Delphi organization roadmap and cross-repository
coordination.

These scripts are intended to:

-   Create issues programmatically
-   Add issues to the organization-level GitHub Project
-   Set project custom fields (CD Milestone, CD Area, CD Priority, etc.)
-   Enforce repeatable governance operations

These scripts are part of the Continuous-Delphi governance layer and
should be treated as organizational infrastructure and are not intended
as general-purpose GitHub automation utilities.

------------------------------------------------------------------------

## Stable Scripts
- `cd-project-add-issue.ps1` (v1.0.0)
  
  Creates a GitHub issue and wires it into the Continuous-Delphi ProjectV2 roadmap with all required fields set.
  
  Capabilities:
  - Issue creation
  - Label assignment
  - Issue Type assignment
  - ProjectV2 board integration
  - Status / Milestone / Area / Priority / Dates / Quarter automation
  - Strict taxonomy validation
  Status: Production (v1.0.0)
   
## Planned / Future Scripts
- cd-project-report.ps1 (planned)
- cd-project-bulk-create.ps1 (planned)
- cd-project-link-dependencies.ps1 (planned)

------------------------------------------------------------------------

## Environment Requirements

### PowerShell

-   PowerShell 7.0 or later
-   Tested with: PowerShell 7.5.4

### GitHub CLI

-   Required: GitHub CLI (`gh`)
-   Tested with `gh --version`

```bash
gh version 2.87.3 (2026-02-23)
https://github.com/cli/cli/releases/tag/v2.87.3
```

Earlier versions may not support all GraphQL project operations used in
these scripts.

------------------------------------------------------------------------

## Required GitHub CLI Authentication Scopes

The GitHub CLI must have project read/write permissions.

Run:

```bash
gh auth refresh -s read:project,project
```

This grants:

-   read:project --- required to inspect project fields
-   project --- required to add items and update project field values

If permission errors occur during execution, re-run the command above.

------------------------------------------------------------------------

## Authentication Check

You can verify authentication using:

````bash
gh auth status
````

Ensure you are authenticated to the correct GitHub account with access
to the `continuous-delphi` organization.

Example output:
```text
github.com
  ✓ Logged in to github.com account {yourname} (keyring)
  - Active account: true
  - Git operations protocol: https
  - Token: gho_************************************
  - Token scopes: 'gist', 'project', 'read:org', 'repo', 'workflow'
```

------------------------------------------------------------------------

## Project Assumptions

These scripts assume the following organization-level project
configuration exists:

Project Name: Continuous-Delphi Ecosystem Roadmap

Owner: continuous-delphi

Project Number: 1

### Custom Fields

#### CD Milestone (Text)

Used for roadmap milestone identifiers (e.g., CD-M01).

#### CD Area (Single Select)

Options:

-   Governance
-   Standards
-   Documentation
-   CI
-   Specification
-   Tooling
-   Reference
-   Integration
-   Security
-   Packaging
-   Incubator

These option names must match exactly or the script will fail
validation.

#### CD Priority (Single Select)

Options:

-   Strategic
-   High
-   Medium
-   Low

These option names must match exactly or the script will fail
validation.

------------------------------------------------------------------------

## Script Philosophy

These scripts follow these principles:

-   No hardcoded field IDs
-   Dynamic discovery of project and field metadata
-   Fail fast on configuration mismatch
-   ASCII-only output
-   Idempotent design where possible

Governance automation should be deterministic and reproducible.

------------------------------------------------------------------------

## Typical Workflow

Example usage:

.`\cd`{=tex}-project-add-issue.ps1 `-Owner continuous-delphi`
-ProjectNumber 1 `-Repo cd-meta-org` -Title "CD-M02 --- Standards &
Templates"
`-Body "Define and publish organization-wide standards and templates."`
-CdMilestone "CD-M02" `-CdArea "Standards"` -CdPriority "Strategic"
`-StartDate "2026-02-27"` -TargetDate "2026-03-31" \` -QuarterTitle
"Quarter 1"

The script will:

1.  Create the issue in the target repository
2.  Add it to the Continuous-Delphi Ecosystem Roadmap project
3.  Set all configured project custom fields

------------------------------------------------------------------------

## Governance Notes

These scripts are not general-purpose automation tools.

They are organizational governance tools.

Changes to:

-   Field names
-   Option values
-   Project number
-   Owner name

must be reflected in the scripts.

If the project configuration changes, update these scripts immediately
to prevent drift.

------------------------------------------------------------------------

## Future Expansion

Planned additional scripts may include:

-   Bulk milestone creation
-   Label standardization across all repositories
-   Automatic repo bootstrap scaffolding
-   Roadmap reporting export

All governance automation should remain centralized in this directory.
