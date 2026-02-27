#requires -Version 7.0

param(
  [Parameter(Mandatory)]
  [string] $Owner,                     # continuous-delphi

  [Parameter(Mandatory)]
  [int]    $ProjectNumber,             # 1

  [Parameter(Mandatory)]
  [string] $Repo,                      # cd-meta-org (or any repo under the org)

  [Parameter(Mandatory)]
  [string] $Title,                     # "CD-M02 - ..."

  [Parameter()]
  [string] $Body = '',

  [Parameter(Mandatory)]
  [string] $CdMilestone,               # "CD-M01"

  [Parameter(Mandatory)]
  [string] $CdArea,                    # "Governance" (must match option name)

  [Parameter(Mandatory)]
  [string] $CdPriority,                # "Strategic" (must match option name)

  [Parameter()]
  [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
  [string] $StartDate,                 # "2026-02-27"

  [Parameter()]
  [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
  [string] $TargetDate,                # "2026-03-31"

  [Parameter()]
  [string] $QuarterTitle = 'Quarter 1', # iteration title in Quarter field

  [Parameter()]
  [string] $StatusName = 'Todo'         # "Todo", "In progress", "Done"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Gh {
  $null = Get-Command gh -ErrorAction Stop
}

function Invoke-GhJson {
  param(
    [Parameter(Mandatory)][string[]] $Args
  )
  $out = & gh @Args
  if ([string]::IsNullOrWhiteSpace($out)) { throw "gh returned no output for: gh $($Args -join ' ')" }
  return ($out | ConvertFrom-Json)
}

function Invoke-GhGraphQL {
  param(
    [Parameter(Mandatory)][string] $Query,
    [Parameter()][hashtable] $Variables = @{}
  )

  $varsJson = ($Variables | ConvertTo-Json -Compress -Depth 12)
  return Invoke-GhJson -Args @('api', 'graphql', '-f', "query=$Query", '-f', "variables=$varsJson")
}

function New-RepoIssue {
  param(
    [Parameter(Mandatory)][string] $Owner,
    [Parameter(Mandatory)][string] $Repo,
    [Parameter(Mandatory)][string] $Title,
    [Parameter()][string] $Body
  )

  $args = @('api', '-X', 'POST', "repos/$Owner/$Repo/issues", '-f', "title=$Title")
  if (-not [string]::IsNullOrWhiteSpace($Body)) {
    $args += @('-f', "body=$Body")
  }

  $resp = Invoke-GhJson -Args $args
  if (-not $resp.node_id) { throw "Issue creation succeeded but node_id was missing." }

  [pscustomobject]@{
    Number = $resp.number
    Url    = $resp.html_url
    NodeId = $resp.node_id
  }
}

function Get-ProjectV2 {
  param(
    [Parameter(Mandatory)][string] $Owner,
    [Parameter(Mandatory)][int] $ProjectNumber
  )

  $q = @'
query($login:String!, $number:Int!) {
  organization(login: $login) {
    projectV2(number: $number) {
      id
      title
      fields(first: 50) {
        nodes {
          __typename
          ... on ProjectV2FieldCommon {
            id
            name
            dataType
          }
          ... on ProjectV2SingleSelectField {
            id
            name
            options {
              id
              name
            }
          }
          ... on ProjectV2IterationField {
            id
            name
            configuration {
              iterations {
                id
                title
                startDate
                duration
              }
            }
          }
        }
      }
    }
  }
}
'@

  $r = Invoke-GhGraphQL -Query $q -Variables @{ login = $Owner; number = $ProjectNumber }

  $proj = $r.data.organization.projectV2
  if (-not $proj) { throw "ProjectV2 not found for $Owner / #$ProjectNumber" }

  return $proj
}

function Add-IssueToProject {
  param(
    [Parameter(Mandatory)][string] $ProjectId,
    [Parameter(Mandatory)][string] $ContentNodeId
  )

  $m = @'
mutation($projectId:ID!, $contentId:ID!) {
  addProjectV2ItemById(input:{projectId:$projectId, contentId:$contentId}) {
    item { id }
  }
}
'@

  $r = Invoke-GhGraphQL -Query $m -Variables @{ projectId = $ProjectId; contentId = $ContentNodeId }
  $itemId = $r.data.addProjectV2ItemById.item.id
  if (-not $itemId) { throw "Failed to add issue to project (no item id returned)." }
  return $itemId
}

function Set-ProjectFieldValue {
  param(
    [Parameter(Mandatory)][string] $ProjectId,
    [Parameter(Mandatory)][string] $ItemId,
    [Parameter(Mandatory)][string] $FieldId,
    [Parameter(Mandatory)][hashtable] $Value
  )

  $m = @'
mutation($projectId:ID!, $itemId:ID!, $fieldId:ID!, $value:ProjectV2FieldValue!) {
  updateProjectV2ItemFieldValue(
    input:{projectId:$projectId, itemId:$itemId, fieldId:$fieldId, value:$value}
  ) {
    projectV2Item { id }
  }
}
'@

  $null = Invoke-GhGraphQL -Query $m -Variables @{
    projectId = $ProjectId
    itemId    = $ItemId
    fieldId   = $FieldId
    value     = $Value
  }
}

function Get-FieldByName {
  param(
    [Parameter(Mandatory)] $Project,
    [Parameter(Mandatory)][string] $Name
  )

  $f = $Project.fields.nodes | Where-Object { $_.name -eq $Name } | Select-Object -First 1
  if (-not $f) { throw "Project field not found: $Name" }
  return $f
}

function Get-SingleSelectOptionId {
  param(
    [Parameter(Mandatory)] $Field,
    [Parameter(Mandatory)][string] $OptionName
  )

  $opt = $Field.options | Where-Object { $_.name -eq $OptionName } | Select-Object -First 1
  if (-not $opt) {
    $names = ($Field.options | ForEach-Object { $_.name }) -join ', '
    throw "Option '$OptionName' not found in single-select field '$($Field.name)'. Options: $names"
  }
  return $opt.id
}

function Get-IterationIdByTitle {
  param(
    [Parameter(Mandatory)] $Field,
    [Parameter(Mandatory)][string] $Title
  )

  $iters = $Field.configuration.iterations
  $it = $iters | Where-Object { $_.title -eq $Title } | Select-Object -First 1
  if (-not $it) {
    $names = ($iters | ForEach-Object { $_.title }) -join ', '
    throw "Iteration '$Title' not found in iteration field '$($Field.name)'. Iterations: $names"
  }
  return $it.id
}

Assert-Gh

# 1) Create the issue
$issue = New-RepoIssue -Owner $Owner -Repo $Repo -Title $Title -Body $Body
Write-Host "Created issue: $($issue.Url)"

# 2) Load project + fields
$proj = Get-ProjectV2 -Owner $Owner -ProjectNumber $ProjectNumber
Write-Host "Using project: $($proj.title) (#$ProjectNumber)"

# 3) Add issue to project
$itemId = Add-IssueToProject -ProjectId $proj.id -ContentNodeId $issue.NodeId
Write-Host "Added to project item: $itemId"

# 4) Resolve fields
$fStatus     = Get-FieldByName -Project $proj -Name 'Status'
$fCdMilestone= Get-FieldByName -Project $proj -Name 'CD Milestone'
$fCdArea     = Get-FieldByName -Project $proj -Name 'CD Area'
$fCdPriority = Get-FieldByName -Project $proj -Name 'CD Priority'
$fStart      = Get-FieldByName -Project $proj -Name 'Start Date'
$fTarget     = Get-FieldByName -Project $proj -Name 'Target Date'
$fQuarter    = Get-FieldByName -Project $proj -Name 'Quarter'

# 5) Set values

# Status (single select)
$stId = Get-SingleSelectOptionId -Field $fStatus -OptionName $StatusName
Set-ProjectFieldValue -ProjectId $proj.id -ItemId $itemId -FieldId $fStatus.id -Value @{ singleSelectOptionId = $stId }

# CD Milestone (text)
Set-ProjectFieldValue -ProjectId $proj.id -ItemId $itemId -FieldId $fCdMilestone.id -Value @{ text = $CdMilestone }

# CD Area (single select)
$areaId = Get-SingleSelectOptionId -Field $fCdArea -OptionName $CdArea
Set-ProjectFieldValue -ProjectId $proj.id -ItemId $itemId -FieldId $fCdArea.id -Value @{ singleSelectOptionId = $areaId }

# CD Priority (single select)
$prioId = Get-SingleSelectOptionId -Field $fCdPriority -OptionName $CdPriority
Set-ProjectFieldValue -ProjectId $proj.id -ItemId $itemId -FieldId $fCdPriority.id -Value @{ singleSelectOptionId = $prioId }

# Start/Target dates (date)
if (-not [string]::IsNullOrWhiteSpace($StartDate)) {
  Set-ProjectFieldValue -ProjectId $proj.id -ItemId $itemId -FieldId $fStart.id -Value @{ date = $StartDate }
}
if (-not [string]::IsNullOrWhiteSpace($TargetDate)) {
  Set-ProjectFieldValue -ProjectId $proj.id -ItemId $itemId -FieldId $fTarget.id -Value @{ date = $TargetDate }
}

# Quarter (iteration)
$quarterIterId = Get-IterationIdByTitle -Field $fQuarter -Title $QuarterTitle
Set-ProjectFieldValue -ProjectId $proj.id -ItemId $itemId -FieldId $fQuarter.id -Value @{ iterationId = $quarterIterId }

Write-Host "Done."
Write-Host "Issue: $($issue.Url)"