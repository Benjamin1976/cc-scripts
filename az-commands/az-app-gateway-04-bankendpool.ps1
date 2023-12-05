

$rArgs = @($args[0], "Resource Group", $true), @($args[1], "App Gateway Name", $true),  @($args[2], "Web App Name 1", $true), @($args[3], "Web App Name 2", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    Write-Output "Missing required variables, exiting"
    exit 
}
$r, $a, $wa1, $wa1 = $rArgs
$grp, $appGW, $webApp1Name, $webApp2Name = $r[0], $a[0], $wa1[0], $wa2[0]
$obj = "Address Pool"

$sp = az network application-gateway address-pool show --gateway-name $appGW --resource-group $grp --name "backendPool"
if ($null -ne $sp) {
    Write-Output "$obj $ruleName exists."
} else {
    # $sp = $false 
    Write-Output "$obj $ruleName doesn't exist"
    Write-Output "Creating $obj : $ruleName"
    $sp = az network application-gateway address-pool create --gateway-name $appGW --resource-group $grp --name "backendPool" --servers $webApp1Name $webApp2Name
}
