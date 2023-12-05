

$rArgs = @($args[0], "Resource Group", $true), @($args[1], "App Gateway Name", $true),  @($args[2], "Rule Name", $true), @($args[3], "Listener Name", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    Write-Output "Missing required variables, exiting"
    exit 
}
$r, $a, $rn, $ln = $rArgs
$grp, $appGW, $ruleName, $listenerName = $r[0], $a[0], $rn[0], $ln[0]
$obj = "Rule Name"

$sp = az network application-gateway rule show --gateway-name $appGW --resource-group $grp --name $ruleName --http-listener $listenerName
if ($null -ne $sp) {
    Write-Output "$obj $ruleName exists."
} else {
    # $sp = $false 
    Write-Output "$obj $ruleName doesn't exist"
    Write-Output "Creating $obj : $ruleName"
    $sp = az network application-gateway rule create --gateway-name $appGW --resource-group $grp --name $ruleName --http-listener $listenerName --rule-type PathBasedRoutingRule --backend-address-pool "backendPool"
}
