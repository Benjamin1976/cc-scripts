# Set log file path

function Write-Log {
    $logFile = "G:\coding\envs\ps-az-setup\$env:computername-process.log"
    param(
        [Parameter(Mandatory = $true)][string] $message,
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO","WARN","ERROR")]
        [string] $level = "INFO"
    )
    # Create timestamp
    $timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    # Append content to log file
    Add-Content -Path $logFile -Value "$timestamp [$level] - $message"
}


function processArgs($rArgs) {
    $rArgs = checkArgs -rArgs $rArgs
    $allFound = foundAll -rArgs $rArgs    # checks if any missing
    # return $allFound
    if ($allFound -eq $false) {
        return $false
    } else {
        return $rArgs
    }
}


function foundAll($rArgs) {
    
    foreach ($arg in $rArgs) {
        if (($arg[2] -eq $true) -and ($arg[0] -eq "")) {
            return $false
            exit
        }
    }
    return $true
}

function checkArgs($rArgs) {
    foreach ($arg in $rArgs) {
        if ((hasL -var ($arg[0])) -eq $false) { $arg[0] = getInput -prompt $arg[1] }
    }
    return $rArgs
}

function hasL($var) {
    return ($var.Length -gt 0)
}

function getInput($prompt) {
    return Read-Host -Prompt "Enter the $prompt"
}

function opHeader($htype, $service) {
    switch($htype) {
        { @("header", "start") -contains $_ } {
        # "header" {
            Write-Output "-------Creating $service---------"
        } 
        { @("footer", "finish") -contains $_ } {
            Write-Output "-------Finished $service---------"
        }
    }
}

function loginToAzure {
    param($u, $p)
    az login -u $u -p $p
}

function logoutFromAzure($u) {
    az logout --username $u
}