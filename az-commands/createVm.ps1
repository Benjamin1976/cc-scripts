# $resourceGroupName = Read-Host -Prompt "Enter the Resource Group name"
# $location = Read-Host -Prompt "Enter the location (i.e. centralus)"
# $adminUsername = Read-Host -Prompt "Enter the administrator username"
# $adminPassword = Read-Host -Prompt "Enter the administrator password" -AsSecureString
# $dnsLabelPrefix = Read-Host -Prompt "Enter an unique DNS name for the public IP"

# check all parameters
$rArgs = @($args[0], "Resource Group name", $true), @($args[1], "location (i.e. centralus)", $true), @($args[2], "administrator username", $true), @($args[3], "administrator password", $true),  @($args[4], "dns label prefix", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    "Missing required variables, exiting"
    exit 
}
$rg, $location, $u, $p, $dns = $rArgs
# $rg, $location, $usr, $pss =$rg[0], $location[0], $u[0], $p[0]

# $resourceGroupName = Read-Host -Prompt "Enter the Resource Group name"
# $location = Read-Host -Prompt "Enter the location (i.e. centralus)"
# $adminUsername = Read-Host -Prompt "Enter the administrator username"
# $adminPassword = Read-Host -Prompt "Enter the administrator password" -AsSecureString
# $dnsLabelPrefix = Read-Host -Prompt "Enter an unique DNS name for the public IP"

New-AzResourceGroup -Name $rg[0] -Location "$location[0]"
New-AzResourceGroupDeployment `
    -ResourceGroupName $rg[0] `
    -TemplateUri "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.compute/vm-simple-windows/azuredeploy.json" `
    -adminUsername $u[0] `
    -adminPassword $p[0] `
    -dnsLabelPrefix $dns[0]

#  (Get-AzVm -ResourceGroupName $rg[0]).name