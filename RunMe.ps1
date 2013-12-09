###########################################################
# RunMe.ps1 - Framework by Tim Rayburn & Devlin Liles
# Part of the Highway.RoadCrew project
#
# License and Original Source located at :
# http://github.com/HighwayFramework/HighwayRoadCrew
#
# DO NOT MODIFY THIS FILE, MODIFY RunMeConfig.ps1 INSTEAD
###########################################################

$LogFile = ".\RunMe.log"

###########################################################
# FUNCTIONS
###########################################################

function Out-Warning {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    $Message)

    Write-Warning $Message
    Out-Log $Message
}

function Out-Host {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    $Message)

    Write-Host $Message
    Out-Log $Message
}

function Out-Verbose {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    $Message)

    Write-Verbose -Message $Message
    Out-Log $Message
}

function Out-Log {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    $Message)

    $Message >> $LogFile
}

function Success($msg) {
    "SUCCESS : $msg"
}

function Warning($msg) {
    "ERROR : $msg"
}

function Test-IsAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
        return $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    } catch {
        throw "Failed to determine if the current user has elevated privileges. The error was: '{0}'." -f $_
    }
}

###########################################################
# Main Script
###########################################################

"BEGIN : RunMe.ps1" | Out-Host

# Check for Admin rights
# --------------------------------------------------------------------
if ((Test-IsAdmin) -eq $false) { 
    Warning("Must be running as Administrator") | Out-Warning 
    return;
} else {
    Success("Running as Administrator") | Out-Host
}

# Check for internet connection
# --------------------------------------------------------------------
if ((Test-Connection google.com -Count 1 -ErrorAction SilentlyContinue -Quiet) -eq $false) {
    Warning("Internet connection is required") | Out-Warning
    return;
}
else {
    Success("Internet connection confirmed") | Out-Host
}

# Check for Execution Policy
# --------------------------------------------------------------------
if ((Get-ExecutionPolicy) -ne "Unrestricted") {
    Warning("PowerShell ExecutionPolicy not properly set, attempting to correct") | Out-Warning
    Set-ExecutionPolicy -Scope LocalMachine -Force Unrestricted
    if ((Get-ExecutionPolicy) -ne "Unrestricted") { return; }
    else { Success("PowerShell ExecutionPolicy has been successfully corrected") }
}
else {
    Success("PowerShell ExeuctionPolicy is correctly set") | Out-Host
}