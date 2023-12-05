

$rArgs = @($args[0], "Resource Group", $true), @($args[1], "Location", $true), @($args[2], "Service Plan", $true), @($args[3], "Subscription", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    Write-Output "Missing required variables, exiting"
    exit 
}
$r, $l, $s, $sb = $rArgs
$grp, $loc, $pln, $sub = $r[0], $l[0], $s[0], $sb[0]
$obj = "Service Plan"

$sp = az appservice plan show --resource-group $grp --name $pln
# $sp = az appservice plan show --resource-group $grp --name $pln --subscription $sub
if ($null -ne $sp) {
    Write-Output "$obj $pln exists."
} else {
    # $sp = $false 
    Write-Output "$obj $pln doesn't exist"
    Write-Output "Creating plan: $pln"
    # $sp = az appservice plan create --name $pln --resource-group $grp --location $loc --sku S1 --subscription $sub
    $sp = az appservice plan create --name $pln --resource-group $grp --location $loc --sku S1
}
