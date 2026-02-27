#requires -Version 7.0

param(
  [Parameter(Mandatory)]
  [string] $Owner,                      # continuous-delphi

  [Parameter(Mandatory)]
  [int]    $ProjectNumber,              # 1

  [Parameter(Mandatory)]
  [string] $Repo,                       # cd-meta-org (or any repo under the org)

  [Parameter(Mandatory)]
  [string] $Title,                      # "CD-M02 - ..."

  [Parameter()]
  [string] $Body = '',

  # Optional: repo labels to apply at issue creation time.
  # Example: -Labels @('roadmap','standards')
  [Parameter()]
  [string[]] $Labels = @(),

  # Optional: GitHub Issue Type (not a label). Example: -IssueType 'Epic'
  # This is set via GraphQL after creation.
  [Parameter()]
  [string] $IssueType = '',

  [Parameter(Mandatory)]
  [ValidatePattern('^CD-M\d{2,4}$')]
  [string] $CdMilestone,                # "CD-M05"

  [Parameter(Mandatory)]
  [ValidateSet(
    'Governance',
    'Standards',
    'Documentation',
    'CI',
    'Specification',
    'Tooling',
    'Reference',
    'Integration',
    'Security',
    'Packaging',
    'Incubator'
  )]
  [string] $CdArea,                     # must match allowed values above

  [Parameter(Mandatory)]
  [ValidateSet('Strategic','High','Medium','Low')]
  [string] $CdPriority,                 # must match allowed values above

  [Parameter()]
  [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
  [string] $StartDate,                  # "2026-02-27"

  [Parameter()]
  [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
  [string] $TargetDate,                 # "2026-03-31"

  [Parameter()]
  [string] $QuarterTitle = 'Quarter 1',  # must match iteration title exactly

  [Parameter()]
  [ValidateSet('Todo','In progress','Done')]
  [string] $StatusName = 'Todo'          # must match Status option exactly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Gh {
  $null = Get-Command gh -ErrorAction Stop
}

function Invoke-GhJson {
  param(
    [Parameter(Mandatory)][string[]] $GhArgs
  )

  $out = & gh @GhArgs
  if ([string]::IsNullOrWhiteSpace($out)) {
    throw "gh returned no output for: gh $($GhArgs -join ' ')"
  }

  return ($out | ConvertFrom-Json)
}

function Invoke-GhGraphQL {
  param(
    [Parameter(Mandatory)][string] $Query,
    [Parameter()][hashtable] $Variables = @{}
  )

  # NOTE:
  # gh api graphql expects variables to be passed as individual flags (not a JSON string):
  # -f for strings, -F for non-strings (ints, bools, etc).
  # Example:
  #   gh api graphql -f query='query($login:String!, $number:Int!){...}' -f login=foo -F number=1
  $ghArgs = @('api', 'graphql', '-f', "query=$Query")

  foreach ($k in $Variables.Keys) {
    $v = $Variables[$k]

    if ($null -eq $v) {
      continue
    }

    if ($v -is [int] -or $v -is [long] -or $v -is [double] -or $v -is [bool]) {
      $ghArgs += @('-F', "$k=$v")
    }
    else {
      # Treat everything else as a string
      $ghArgs += @('-f', "$k=$v")
    }
  }

  return Invoke-GhJson -GhArgs $ghArgs
}

function New-RepoIssue {
  param(
    [Parameter(Mandatory)][string]   $Owner,
    [Parameter(Mandatory)][string]   $Repo,
    [Parameter(Mandatory)][string]   $Title,
    [Parameter()][string]            $Body   = '',
    [Parameter()][string[]]          $Labels = @()
  )

  $payload = [ordered]@{ title = $Title }

  if (-not [string]::IsNullOrWhiteSpace($Body)) {
    $payload.body = $Body
  }

  if ($Labels -and $Labels.Count -gt 0) { $payload.labels = $Labels }

  # Write payload to a temp file to avoid shell quoting and escaping issues
  # with titles/bodies that contain special characters.
  # UTF-8 without BOM -- GitHub API returns HTTP 400 "Problems parsing JSON" if
  # the payload contains a BOM. [System.Text.Encoding]::UTF8 includes a BOM on
  # some .NET versions; UTF8Encoding($false) is always BOM-free.
  $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
  $jsonPath  = Join-Path $env:TEMP ("cd-new-issue-{0}.json" -f [guid]::NewGuid().ToString('N'))
  try {
    $json = $payload | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($jsonPath, $json, $utf8NoBom)

    $resp = Invoke-GhJson -GhArgs @(
      'api', '-X', 'POST',
      "repos/$Owner/$Repo/issues",
      '--input', $jsonPath
    )
  }
  finally {
    Remove-Item -LiteralPath $jsonPath -Force -ErrorAction SilentlyContinue
  }

  if (-not $resp.node_id) {
    throw "Issue creation succeeded but node_id was missing from response."
  }

  [pscustomobject]@{
    Number = $resp.number
    Url    = $resp.html_url
    NodeId = $resp.node_id
  }
}

function Get-RepoIssueTypeIdByName {
  param(
    [Parameter(Mandatory)][string] $Owner,
    [Parameter(Mandatory)][string] $Repo,
    [Parameter(Mandatory)][string] $IssueTypeName
  )

  $q = @'
query($owner:String!, $name:String!, $first:Int!) {
  repository(owner: $owner, name: $name) {
    issueTypes(first: $first) {
      nodes {
        id
        name
      }
    }
  }
}
'@

  $r = Invoke-GhGraphQL -Query $q -Variables @{
    owner = $Owner
    name  = $Repo
    first = 100
  }

  $nodes = $r.data.repository.issueTypes.nodes
  if (-not $nodes) {
    throw "No issue types returned. Issue types may not be enabled for this repository."
  }

  $match = $nodes | Where-Object { $_.name -eq $IssueTypeName } | Select-Object -First 1
  if (-not $match) {
    $names = ($nodes | ForEach-Object { $_.name }) -join ', '
    throw "Issue type '$IssueTypeName' not found. Available: $names"
  }

  return $match.id
}

function Set-IssueType {
  param(
    [Parameter(Mandatory)][string] $IssueId,
    [Parameter(Mandatory)][string] $IssueTypeId
  )

  $m = @'
mutation($id:ID!, $issueTypeId:ID!) {
  updateIssue(input: { id: $id, issueTypeId: $issueTypeId }) {
    issue {
      id
      issueType {
        name
      }
    }
  }
}
'@

  $null = Invoke-GhGraphQL -Query $m -Variables @{
    id          = $IssueId
    issueTypeId = $IssueTypeId
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
          ... on ProjectV2FieldCommon { id name dataType }
          ... on ProjectV2SingleSelectField {
            id
            name
            options { id name }
          }
          ... on ProjectV2IterationField {
            id
            name
            configuration {
              iterations { id title startDate duration }
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

function Set-FieldSingleSelect {
  param(
    [Parameter(Mandatory)][string] $ProjectId,
    [Parameter(Mandatory)][string] $ItemId,
    [Parameter(Mandatory)][string] $FieldId,
    [Parameter(Mandatory)][string] $OptionId
  )

  $m = @'
mutation($projectId:ID!, $itemId:ID!, $fieldId:ID!, $optionId:String!) {
  updateProjectV2ItemFieldValue(
    input:{projectId:$projectId, itemId:$itemId, fieldId:$fieldId, value:{singleSelectOptionId:$optionId}}
  ) { projectV2Item { id } }
}
'@

  $null = Invoke-GhGraphQL -Query $m -Variables @{
    projectId = $ProjectId
    itemId    = $ItemId
    fieldId   = $FieldId
    optionId  = $OptionId
  }
}

function Set-FieldText {
  param(
    [Parameter(Mandatory)][string] $ProjectId,
    [Parameter(Mandatory)][string] $ItemId,
    [Parameter(Mandatory)][string] $FieldId,
    [Parameter(Mandatory)][string] $Text
  )

  $m = @'
mutation($projectId:ID!, $itemId:ID!, $fieldId:ID!, $text:String!) {
  updateProjectV2ItemFieldValue(
    input:{projectId:$projectId, itemId:$itemId, fieldId:$fieldId, value:{text:$text}}
  ) { projectV2Item { id } }
}
'@

  $null = Invoke-GhGraphQL -Query $m -Variables @{
    projectId = $ProjectId
    itemId    = $ItemId
    fieldId   = $FieldId
    text      = $Text
  }
}

function Set-FieldDate {
  param(
    [Parameter(Mandatory)][string] $ProjectId,
    [Parameter(Mandatory)][string] $ItemId,
    [Parameter(Mandatory)][string] $FieldId,
    [Parameter(Mandatory)][string] $Date
  )

  $m = @'
mutation($projectId:ID!, $itemId:ID!, $fieldId:ID!, $date:Date!) {
  updateProjectV2ItemFieldValue(
    input:{projectId:$projectId, itemId:$itemId, fieldId:$fieldId, value:{date:$date}}
  ) { projectV2Item { id } }
}
'@

  $null = Invoke-GhGraphQL -Query $m -Variables @{
    projectId = $ProjectId
    itemId    = $ItemId
    fieldId   = $FieldId
    date      = $Date
  }
}

function Set-FieldIteration {
  param(
    [Parameter(Mandatory)][string] $ProjectId,
    [Parameter(Mandatory)][string] $ItemId,
    [Parameter(Mandatory)][string] $FieldId,
    [Parameter(Mandatory)][string] $IterationId
  )

  $m = @'
mutation($projectId:ID!, $itemId:ID!, $fieldId:ID!, $iterationId:String!) {
  updateProjectV2ItemFieldValue(
    input:{projectId:$projectId, itemId:$itemId, fieldId:$fieldId, value:{iterationId:$iterationId}}
  ) { projectV2Item { id } }
}
'@

  $null = Invoke-GhGraphQL -Query $m -Variables @{
    projectId    = $ProjectId
    itemId       = $ItemId
    fieldId      = $FieldId
    iterationId  = $IterationId
  }
}

Assert-Gh

# 1) Create the issue (repo metadata: title/body/labels)
$issue = New-RepoIssue -Owner $Owner -Repo $Repo -Title $Title -Body $Body -Labels $Labels
Write-Host "Created issue: $($issue.Url)"

# 2) Optional: set Issue Type (repo metadata)
if (-not [string]::IsNullOrWhiteSpace($IssueType)) {
  $issueTypeId = Get-RepoIssueTypeIdByName -Owner $Owner -Repo $Repo -IssueTypeName $IssueType
  Set-IssueType -IssueId $issue.NodeId -IssueTypeId $issueTypeId
  Write-Host "Set issue type: $IssueType"
}

# 3) Load project + fields
$proj = Get-ProjectV2 -Owner $Owner -ProjectNumber $ProjectNumber
Write-Host "Using project: $($proj.title) (#$ProjectNumber)"

# 4) Add issue to project
$itemId = Add-IssueToProject -ProjectId $proj.id -ContentNodeId $issue.NodeId
Write-Host "Added to project item: $itemId"

# 5) Resolve fields
$fStatus      = Get-FieldByName -Project $proj -Name 'Status'
$fCdMilestone = Get-FieldByName -Project $proj -Name 'CD Milestone'
$fCdArea      = Get-FieldByName -Project $proj -Name 'CD Area'
$fCdPriority  = Get-FieldByName -Project $proj -Name 'CD Priority'
$fStart       = Get-FieldByName -Project $proj -Name 'Start Date'
$fTarget      = Get-FieldByName -Project $proj -Name 'Target Date'
$fQuarter     = Get-FieldByName -Project $proj -Name 'Quarter'

# 6) Set project values

# Status (single select)
$stId = Get-SingleSelectOptionId -Field $fStatus -OptionName $StatusName
Set-FieldSingleSelect -ProjectId $proj.id -ItemId $itemId -FieldId $fStatus.id -OptionId $stId

# CD Milestone (text)
Set-FieldText -ProjectId $proj.id -ItemId $itemId -FieldId $fCdMilestone.id -Text $CdMilestone

# CD Area (single select)
$areaId = Get-SingleSelectOptionId -Field $fCdArea -OptionName $CdArea
Set-FieldSingleSelect -ProjectId $proj.id -ItemId $itemId -FieldId $fCdArea.id -OptionId $areaId

# CD Priority (single select)
$prioId = Get-SingleSelectOptionId -Field $fCdPriority -OptionName $CdPriority
Set-FieldSingleSelect -ProjectId $proj.id -ItemId $itemId -FieldId $fCdPriority.id -OptionId $prioId

# Start/Target dates (date)
if (-not [string]::IsNullOrWhiteSpace($StartDate)) {
  Set-FieldDate -ProjectId $proj.id -ItemId $itemId -FieldId $fStart.id -Date $StartDate
}
if (-not [string]::IsNullOrWhiteSpace($TargetDate)) {
  Set-FieldDate -ProjectId $proj.id -ItemId $itemId -FieldId $fTarget.id -Date $TargetDate
}

# Quarter (iteration)
$quarterIterId = Get-IterationIdByTitle -Field $fQuarter -Title $QuarterTitle
Set-FieldIteration -ProjectId $proj.id -ItemId $itemId -FieldId $fQuarter.id -IterationId $quarterIterId

Write-Host "Done."
Write-Host "Issue: $($issue.Url)"
