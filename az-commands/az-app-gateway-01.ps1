

$rArgs = @($args[0], "Resource Group", $true), @($args[1], "Location", $true), @($args[2], "App Gateway Name", $true), @($args[3], "VNET Name", $true), @($args[4], "Subnet Name", $true),  @($args[5], "Public IP Name", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    Write-Output "Missing required variables, exiting"
    exit 
}
$r, $l, $a, $v, $s, $p = $rArgs
$grp, $loc, $appGW, $vnet, $subnet, $pip = $r[0], $l[0], $a[0], $v[0], $s[0], $p[0]
$obj = "App Gateway"

# $sp = az network application-gateway show --name $appGW --resource-group $grp
# $sp = az network application-gateway create -g $grp -n $appGW --capacity 2 --sku Standard_Medium --vnet-name $vnet --subnet $subnet --http-settings-cookie-based-affinity Enabled --public-ip-address MyAppGatewayPublicIp --servers 10.0.0.4 10.0.0.5
$sp = az network application-gateway show -g $grp -n $appGW
if ($null -ne $sp) {
    Write-Output "$obj $appGW exists."
} else {
    # $sp = $false 
    Write-Output "$obj $appGW doesn't exist"
    Write-Output "Creating $obj : $appGW"
    # $sp = az network application-gateway create --name $appGW --resource-group $grp --location $loc --capacity 2 --sku WAF_v2
    $sp = az network application-gateway create -g $grp -n $appGW --vnet-name $vnet --subnet $subnet --http-settings-cookie-based-affinity Enabled --priority 100  --public-ip-address $pip --sku Standard_v2
}
