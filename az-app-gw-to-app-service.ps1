. .\general.ps1

$usr = "odl_user_1139641@simplilearnhol40.onmicrosoft.com"
$pss = "euuq04DON*oO"

$vmUsr = "benjamin"
$vmPass = "benjamin_123"
$dnsPrefix = "bens-vm-win-"

$ver = "01"

$sub = "Simplilearn HOL 42"
$loc = "eastus"
$grp = "ronnie-rg-" + $ver + "1"

$pln = "ronnie-sp-" + $ver + "1" 
$appname = "demoes-images-ronnie-" + $ver + "1"

$pln2 = "ronnie-sp-" + $ver + "2" 
$appname2 = "demoes-videos-ronnie-" + $ver + "1"

$appGatewayName = "app-gateway-" + $ver + "1"
$frontendIPName = "pip-app-gw-" + $ver + "1"
$httpListenerName = "http-listener-" + $ver + "1"
$ruleName = "http-rule-" + $ver + "1"
$publicIpName = "ronnie-ip-std-" + $ver + "1"

$vnetName = "ronnie-app-vnet-" + $ver + "1"
$vnetPrefix = "10.0.0.0/16"
$subnetName = "app-gw-01-subnet" + $ver + "1"
$subnetIP = "10.0.0.0/24"


# Write-Output "Checking Resource Group"
$obj = "Resource Group"
Write-Output "[$obj] Checking $obj"
.\az-commands\az-rg-check.ps1 $grp $loc
Write-Output "[$obj] Finished"

# az group create --name $grp --location $loc
$obj = "Service Plan"
Write-Output "[$obj] Checking $obj"
.\az-commands\az-service-plan.ps1 $grp $loc $pln $sub
Write-Output "[$obj] Finished"

$obj = "Web App"
Write-Output "[$obj] Checking $obj"
.\az-commands\az-web-app.ps1 $grp $pln $appname $sub
Write-Output "[$obj] Finished"

$obj = "Service Plan"
Write-Output "[$obj] Checking $obj"
.\az-commands\az-service-plan.ps1 $grp $loc $pln2 $sub
Write-Output "[$obj] Finished"

$obj = "Web App"
Write-Output "[$obj] Checking $obj"
.\az-commands\az-web-app.ps1 $grp $pln $appname2 $sub
Write-Output "[$obj] Finished"

# public IP 
$obj = "Public IP"
Write-Output "[$obj] Checking $obj"
$publicIP = .\az-commands\az-public-ip.ps1 $grp $loc $publicIpName
Write-Output "[$obj] Finished"

# vNET
$obj = "VNET"
Write-Output "[$obj] Checking $obj"
.\az-commands\az-network-vnet.ps1 $grp $vnetName $vnetPrefix $subnetName $subnetIP
Write-Output "[$obj] Finished"

# app gateway
$obj = "App Gateway"
Write-Output "[$obj] Checking $obj"
.\az-commands\az-app-gateway-01.ps1 $grp $loc $appGatewayName $vnetName $subnetName $publicIpName
Write-Output "[$obj] Finished"
Exit



# update backend pool to add 1 server

# create 2nd backend pool to the other 1 server


# update rule to point to app services & add multi rules

# path, targetname, backendsettings, backendtarget




# healthprobe

# vnet - service endpoint

# backend settings - with hostname override from backend pool


# az network application-gateway routing-rule -g ronnie-rg-011 --gateway-name app-gateway-011
# az network application-gateway rule list --resource-group "ronnie-rg-011" --gateway-name "app-gateway-011"
# az network application-gateway rule show --resource-group "ronnie-rg-011" --gateway-name "app-gateway-011"
# az network application-gateway rule update --resource-group "ronnie-rg-011" --gateway-name "app-gateway-011"
# az network application-gateway url-path-map show -g "ronnie-rg-011" --gateway-name "app-gateway-011" -n "subfolder-routing-8080"


  
# # frontend configuration
# $obj = "FrontEndIP"
# Write-Output "[$obj] Checking $obj"
# .\az-commands\az-app-gateway-02-frontendIP.ps1 $grp $frontendIPName $appGatewayName $publicIP
# Write-Output "[$obj] Finished"

# # listener
# $obj = "HTTP Listener"
# Write-Output "[$obj] Checking $obj"
# .\az-commands\az-app-gateway-03-listener.ps1 $grp $frontendIPName $appGatewayName $httpListenerName
# Write-Output "[$obj] Finished"

# backend pools - 2 maybe
$obj = "Backend Pools"
Write-Output "[$obj] Checking $obj"
.\az-commands\az-app-gateway-04-bankendpool.ps1 $grp $appGatewayName $appname $appname2
Write-Output "[$obj] Finished"

# rules 
$obj = "Rule"
Write-Output "[$obj] Checking $obj"
.\az-commands\az-app-gateway-05-rule.ps1 $grp $appGatewayName $ruleName $httpListenerName
Write-Output "[$obj] Finished"

# healthprobe

# vnet - service endpoint

# backend settings - with hostname override






