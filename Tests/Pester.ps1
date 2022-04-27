<#
.SYNOPSIS
Runs the Pester tests

.DESCRIPTION
Sets up the tests and runs them

.PARAMETER TestsPath
[Mandatory] Path to the test files

.PARAMETER Publish
[Optional] switch to decide whether to publish results or not

.PARAMETER ResultsPath
[Mandatory] Path to the test results file.

.PARAMETER TestResultsFile
[Mandatory] Name of the test results file.

.PARAMETER CodeCoverageResultsFile
[Mandatory] Name of the CodeCoverageResultsFile

.PARAMETER Tag
[Mandatory] Name of the CodeCoverageResultsFile

.EXAMPLE
Pester.ps1 -TestsPath $(System.DefaultWorkingDirectory)\${{ parameters.TestsPath }} -ResultsPath $(System.DefaultWorkingDirectory)\${{ parameters.ResultsPath }} -Publish -TestResultsFile ${{ parameters.TestResultsFile }} -CodeCoverageResultsFile ${{ parameters.CodeCoverageResultsFile }}

#>

param (
    [Parameter(Mandatory = $true)]
    [string]
    $TestsPath,

    [Parameter(Mandatory = $false)]
    [switch]
    $Publish,

    [Parameter(Mandatory=$true)]
    [string]
    $ResultsPath,

    [Parameter(Mandatory=$true)]
    [string]
    $TestResultsFile,

    [Parameter(Mandatory=$true)]
    [string]
    $CodeCoverageResultsFile,

    [Parameter(Mandatory=$true)]
    [string]
    $Tag
)

$pesterModule = Get-Module -Name Pester -ListAvailable | Where-Object {$_.Version -like '5.*'}
if (!$pesterModule) {
    try {
        Install-Module -Name Pester -Scope CurrentUser -Force -SkipPublisherCheck -MinimumVersion "5.0"
        $pesterModule = Get-Module -Name Pester -ListAvailable | Where-Object {$_.Version -like '5.*'}
    }
    catch {
        Write-Error "Failed to install the Pester module."
    }
}

Write-Host "Pester version: $($pesterModule.Version.Major).$($pesterModule.Version.Minor).$($pesterModule.Version.Build)"
$pesterModule | Import-Module

if ($Publish) {
    if (!(Test-Path -Path $ResultsPath)) {
        New-Item -Path $ResultsPath -ItemType Directory -Force | Out-Null
    }
}

# Write-Host "Fetching tests:"
$Tests = (Get-ChildItem -Path $($TestsPath) -Recurse | Where-Object {$_.Name -like "*.Tests.ps1"}).FullName

$Powershellfiles = (Get-ChildItem -Recurse | Where-Object {$_.Name -like "*.psm1" -or $_.Name -like "*.ps1" -and $_.FullName -notlike "*\tests\*"}).FullName
Write-Host "Powershell files count $($Powershellfiles.Count)"

$Params = [ordered]@{
    Path = $Tests;
}

$Container = New-PesterContainer @Params

$Configuration = [PesterConfiguration]@{
    Run          = @{
        Container = $Container
    }
    Output       = @{
        Verbosity = 'Diagnostic'
    }
    Filter = @{
        Tag = $Tag
    }
    TestResult   = @{
        Enabled      = $true
        OutputFormat = "NUnitXml"
        OutputPath   = "$($ResultsPath)\$($TestResultsFile)"
    }
    CodeCoverage = @{
        Enabled      = $false
        Path         = $Powershellfiles
        OutputFormat = "JaCoCo"
        OutputPath   = "$($ResultsPath)\$($CodeCoverageResultsFile)"
    }
    Should = @{
        ErrorAction = 'Continue'
    }
}

if ($Publish) {
    Invoke-Pester -Configuration $Configuration
}
else {
    Invoke-Pester -Container $Container -Output Detailed
}