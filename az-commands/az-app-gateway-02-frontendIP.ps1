

$rArgs = @($args[0], "Resource Group", $true), @($args[1], "Front End IP Name", $true), @($args[2], "App Gateway Name", $true), @($args[2], "Public IP Name", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    Write-Output "Missing required variables, exiting"
    exit 
}
$r, $l, $a, $p = $rArgs
$grp, $feIP, $appGW, $pip = $r[0], $l[0], $a[0], $p[0]
$obj = "App Gateway Front End IP"


$sp = az network application-gateway frontend-ip show --name $feIP --gateway-name $appGW --resource-group $grp
if ($null -ne $sp) {
    Write-Output "$obj $feIP exists."
} else {
    # $sp = $false 
    Write-Output "$obj $feIP doesn't exist"
    Write-Output "Creating $obj : $feIP"
    $sp = az network application-gateway frontend-ip create --name $feIP --gateway-name $appGW --resource-group $grp --public-ip-address $pip
}
