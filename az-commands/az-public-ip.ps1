

$rArgs = @($args[0], "Resource Group", $true), @($args[1], "Location", $true),  @($args[2], "Public IP Name", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    Write-Output "Missing required variables, exiting"
    exit 
}
$r, $l, $pip = $rArgs
$grp, $loc, $publicIpName = $r[0], $l[0], $pip[0]
$obj = "Public IP"

$sp = az network public-ip show --name $publicIpName --resource-group $grp
if ($null -ne $sp) {
    Write-Output "$obj $publicIpName exists."
} else {
    # $sp = $false 
    Write-Output "$obj $publicIpName doesn't exist"
    Write-Output "Creating $obj : $publicIpName"
    # Create a public IP address
    $sp = az network public-ip create --name $publicIpName --resource-group $grp --location $loc --allocation-method Static --sku Standard
}

# Read the created public IP into a variable
$sp = az network public-ip show --name $publicIpName --resource-group $grp --query "{address: ipAddress}" --output json | ConvertFrom-Json
$publicIpAddress = $sp.address

# Use $publicIpAddress in other commands
return $publicIpAddress