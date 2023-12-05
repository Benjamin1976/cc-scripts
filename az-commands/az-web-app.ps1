
$rArgs = @($args[0], "Resource Group", $true), @($args[1], "Service Plan", $true), @($args[2], "App Name", $true), @($args[3], "Subscription", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    "Missing required variables, exiting"
    exit 
}
$r, $p, $a, $s = $rArgs
$grp, $pln, $appname, $sub = $r[0], $p[0], $a[0], $s[0]

$obj = "Web App"

# $ap = az webapp show --resource-group $grp --name $appname --subscription $sub
$ap = az webapp show --resource-group $grp --name $appname
if ($null -ne $ap) {
    Write-Output "$obj $appname exists."
} else {
    $Error.Clear() 
    Write-Output "$obj $appname doesn't exist, creating it."
    # $ap = az webapp create --resource-group $grp --name $appname --plan $pln --subscription $sub
    $ap = az webapp create --resource-group $grp --name $appname --plan $pln --vnet --subnet --tags
    # You can also print additional error information
    # Write-Host "Error message: " $Error[0]
}
