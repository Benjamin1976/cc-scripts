. .\az-commands\general.ps1

$args[1]

$rArgs = @($args[0], "Resource Group", $true), @($args[1], "Vnet Name", $true),  @($args[2], "Vnet Prefix", $true), @($args[3], "Subnet Name", $true), @($args[4], "Subnet Prefix", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    Write-Output "Missing required variables, exiting"
    exit 
}
$r, $v, $vp, $s, $sp = $rArgs
$grp, $vnetName, $vnetPrefix, $subnetName, $subnetPrefix = $r[0], $v[0], $vp[0], $s[0], $sp[0]
$obj = "Vnet & Subnet"

# $sp = az network application-gateway rule show --gateway-name $appGW --resource-group $grp --name $ruleName --http-listener $listenerName
$sp = az network vnet show -g $grp -n $vnetName
if ($null -ne $sp) {
    Write-Output "$obj $vnetName exists."
} else {
    # $sp = $false 
    Write-Output "$obj $vnetName doesn't exist"
    Write-Output "Creating $obj : $vnetName"

    $sp = az network vnet create -g $grp -n $vnetName --address-prefix $vnetPrefix --subnet-name $subnetName --subnet-prefixes $subnetPrefix
}
