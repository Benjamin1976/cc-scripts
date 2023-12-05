. .\az-commands\general.ps1

$rArgs = @($args[0], "Resource Group Name", $true), @($args[1], "Resource Group Location", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    "Missing required variables, exiting"
    exit 
}
$names, $locations = $rArgs
$name, $location = $names[0], $locations[0] 

function RgExists ($name) {
    $grouplist = az group list
    $groups =$grouplist | ConvertFrom-Json
    
    $rgexists = $false
    foreach ($grp in $groups) {
        if ($name -eq $grp.name) {
            Write-Host "[CreateRG] Resource group exists"
            $rgexists = $true
            break
        }
    }
    return $rgexists
}

function CreateRG($name) {
    Write-Host "[CreateRG] Resource group doesn't exist, creating"
    $cmdout = az group create -l $location -n $name
    return $cmdout
}

$rgExists = RgExists($name)
If ($rgExists -eq $false) {
    $cmdout = CreateRG($name)
}

return $cmdout
