

$rArgs = @($args[0], "Resource Group", $true), @($args[1], "Front End IP Name", $true), @($args[2], "App Gateway Name", $true), , @($args[3], "Listener Name", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    Write-Output "Missing required variables, exiting"
    exit 
}
$r, $f, $a, $l = $rArgs
$grp, $feIP, $appGW, $listenerName = $r[0], $f[0], $a[0], $l[0]
$obj = "App Gateway Listener"

$sp = az network application-gateway http-listener show --name $listenerName --resource-group $grp --gateway-name $appGW
if ($null -ne $sp) {
    Write-Output "$obj $listenerName exists."
} else {
    # $sp = $false 
    Write-Output "$obj $listenerName doesn't exist"
    Write-Output "Creating $obj : $appGW"
    $sp = az network application-gateway http-listener create --name $listenerName --frontend-ip $feIP --frontend-port 80 --resource-group $grp --gateway-name $appGW --rule-name ""
}
