
$usr = "odl_user_1139641@simplilearnhol40.onmicrosoft.com"
$pss = "euuq04DON*oO"


$vmUsr = "benjamin"
$vmPass = "benjamin_123"
$subscription = "951a0254-05ce-4ed4-b8fc-904d8a959c7f"

# $grp = "az305-rg-test"
$grp = "az305-project-004"
$ver = "004"
# $subscriptionFull = "/subscriptions/$subscription/resourceGroups/$grp/providers/Microsoft.Web/serverfarms/"
$subscriptionFull = "/subscriptions/$subscription/resourceGroups/$grp/providers/Microsoft.Web/sites/"
$subs = @("eastus", "eastus",  "10", "US-NY"), @("australiasoutheast", "aus", "20", "AU-VIC"), @("eastasia", "asia", "30", "SG")
# $subs = @("eastus", "eastus",  "10", "GEO-NA US US-NY"), @("australiasoutheast", "aus", "20", "GEO-AP AU AU-VIC"), @("eastasia", "asia", "30", "GEO-AS SG")
# $regions = @("WORLD GEO-NA US US-NY", "WORLD GEO-AS SG", "WORLD GEO-AP AU AU-VIC")
$types = @("imgs", "reg")
$sppname = "tyrell-plan"
$appname = "tyrell-webapp"
$runtime =  "ASPNET:V4.8"

$trafficmgrpath = "/hostingstart.html"


$File = "G:\coding\envs\ps-az-setup\az-creation-log.txt"
Clear-Content -Path $File
# $From = Get-Content -Path $File

# az webapp list-runtimes
# $config =
$createAppsService = $true
$createTrafficMgr = $true
$createAppGW = $true

$appservices = @()
$trafficmgrs = @()
$appgws = @()

foreach ($sub in  $subs) {
    foreach ($type in  $types) {

        $location = $sub[0]
        $locCode = $sub[1]
        $vnetName = "tyrell", $type, "vnet", $locCode, $ver -join "-"
        $vnetPrefix = "10." + $sub[2] + ".0.0/16"
        $subnetName = "tyrell", $type, "subnet", $locCode, $ver -join "-"
        $subnetPrefix = "10." + $sub[2] + ".0.0/24"
        
        Write-Output "****************************"
        Write-Output "Creating App Services"
        Write-Output "----------------------------"
        Write-Output "creating vnet & subnet"
        Write-Output "vnet: $vnetName, $vnetPrefix"
        Write-Output "subnet: $subnetName, $subnetPrefix"
        Write-Output "location: $location"
        if ($createAppsService) {
            $sp = az network vnet create -g $grp --location $location -n $vnetName --address-prefix $vnetPrefix `
                                        --subnet-name $subnetName --subnet-prefixes $subnetPrefix
        }
    
        Add-Content -Path $File -Value "----------------------------"
        Add-Content -Path $File -Value "vnet & subnet"
        # Add-Content -Path $File -Value $sp

        $sp_plan = $sppname, $type, $locCode, $ver  -join "-"
        $app_name = $appname, $type, $locCode, $ver -join "-"

        Write-Output "----------------------------"
        Write-Output "creating service plan"
        Write-Output "service plan: $sp_plan"
        Write-Output "service loc: $($location)"
        if ($createAppsService) {
            $sp = az appservice plan create --name $sp_plan --resource-group $grp --location $location --sku S1
            $sp
        }

        Add-Content -Path $File -Value "----------------------------"
        Add-Content -Path $File -Value "creating service plan"
        # Add-Content -Path $File -Value $sp

        Write-Output "----------------------------"
        Write-Output "creating app service"
        Write-Output "web app: $sp_plan"
        Write-Output "web app: $app_name"
        Write-Output "service vnet: $vnetName"
        Write-Output "service sub: $subnetName"
        Write-Output "runtime: $runtime"
        
        if ($createAppsService) {
            $ap = az webapp create --resource-group $grp --name $app_name --plan $sp_plan --vnet $vnetName `
                --subnet $subnetName --public-network-access Enabled --runtime $runtime
            $ap
        }
        $appservices += $app_name

        Add-Content -Path $File -Value "----------------------------"
        Add-Content -Path $File -Value "creating app service"
        Add-Content -Path $File -Value $ap
    }
}


$tfmgrPre = "tyrell-trafficmgr"
foreach ($type in $types) {
    $tfmgrName = $tfmgrPre, $type, $ver -join "-"

    Write-Output "****************************"
    Write-Output "Creating Traffic Manager"
    Write-Output "----------------------------"
    Write-Output "creating traffic mgr"
    Write-Output "name: $tfmgrName"

    if ($createTrafficMgr) {
        $cmdout = az network traffic-manager profile create `
                    --name $tfmgrName `
                    --resource-group $grp `
                    --unique-dns-name $tfmgrName `
                    --protocol HTTP `
                    --port 80 `
                    --path $trafficmgrpath `
                    --routing-method Performance
    }

    $trafficmgrs +=$tfmgrName
    Add-Content -Path $File -Value "----------------------------"
    Add-Content -Path $File -Value "creating traffic mgr"
    Write-Output  "az network traffic-manager profile create --name $tfmgrName --resource-group $grp --unique-dns-name $tfmgrName --protocol HTTP --port 80 --path $trafficmgrpath --routing-method Performance"
    Add-Content -Path $File -Value $cmdout
    $sp += $cmdout


    foreach ($sub in $subs) {
        $locCode = $sub[1]
        $endpointName = $appname, $type, $locCode, $ver -join "-"
        $endpointName = $appname, $type, $locCode, $ver -join "-"
        $resId = "$subscriptionFull$endpointName"

        Write-Output "----------------------------"
        Write-Output "creating traffic endpoint"
        Write-Output "traffic mgr: $tfmgrName"
        Write-Output "name: $endpointName"
        Write-Output "geo-mapping: $($sub[3])"
        Write-Output "resId: $resId"

        if ($createTrafficMgr) {
            $cmdout = az network traffic-manager endpoint create --name $endpointName `
                            --profile-name $tfmgrName `
                            --resource-group $grp `
                            --type "azureEndpoints" `
                            --always-serve "Disabled" `
                            --target-resource-id $resId `
                            --target "$endpointName.azurewebsites.net" 
            
                            # --geo-mapping $($sub[3]) `
        }
        Add-Content -Path $File -Value "----------------------------"
        Add-Content -Path $File -Value "creating traffic endpoint"
        Write-Output  "az network traffic-manager endpoint create --name $endpointName --profile-name $tfmgrName --resource-group $grp --type "azureEndpoints" --always-serve "Disabled" --target-resource-id $resId --target ""$endpointName.azurewebsites.net"""
        Add-Content -Path $File -Value $cmdout
        # Add-Content -Path $File -Value $sp
        $cmdout
        $sp + $cmdout    

    }
}


if ($createAppGW) {
    $appGWName = "tyrell", "appgw", $type, $ver -join "-"

    $location = "eastus"
    $vnetName = "tyrell", "appgw", "vnet", $locCode, $ver -join "-"
    $vnetPrefix = "10.100.0.0/16"
    $subnetName = "tyrell", "appgw", "subnet", $locCode, $ver -join "-"
    $subnetPrefix = "10.100.0.0/24"
    $publicIpName = "tyrell", "appgw", "pip", $locCode, $ver -join "-"

    ## created health probe to traffic mgr dns
    ## created service endpoint on vnet
    ## change backend settings to override hostname and choose from backend pool

    # CREATE VNET
    Write-Output "****************************"
    Write-Output "Creating App Gateway"
    Write-Output "----------------------------"
    Write-Output "creating vnet"
    $sp = az network vnet create -g $grp --location $location -n $vnetName --address-prefix $vnetPrefix `
    --subnet-name $subnetName --subnet-prefixes $subnetPrefix
    $sp

    # CREATE PUBLIC IP
    Write-Output "----------------------------"
    Write-Output "creating public ip"    
    $sp = az network public-ip create --name $publicIpName --resource-group $grp --location $location --allocation-method Static --sku Standard
    $sp = az network public-ip show --name $publicIpName --resource-group $grp --query '{address: ipAddress}' --output json | ConvertFrom-Json
    $pip = $sp.address
    
    # CREATE APP GW
    Write-Output "----------------------------"
    Write-Output "creating app gw"        
    $sp = az network application-gateway create -g $grp -n $appGWName --vnet-name $vnetName --subnet $subnetName `
                    --http-settings-cookie-based-affinity Enabled --priority 100  --public-ip-address $pip --sku Standard_v2
    $sp
    $appGW += $appGWName
    
    # CREATE FRONT END IP
    # NOT NEEDED - not sure if needed - as public ip does this
    # $sp = "az network application-gateway frontend-ip create -g $grp --gateway-name $appGWName --name $feIP  --public-ip-address $pip --vnet-name $vnetName --subnet $subnetName | ConvertFrom-Json"
    # $feIP = $sp
    
    # CREATE / UPDATE LISTENER
    # NOT NEEDED - listener already created with appgw, may need update if need specific name, listener type is basic (not multi-site - not sure if an issue or no
    # $sp = az network application-gateway http-listener create -g $grp --gateway-name $appGWName --name $listenerName --frontend-ip $pip --frontend-port 80 --rule-name ""
    # $sp


    ############# ISSUE - cannot (or how to) define App service as backend pool.  maybe need to pass app service FQDN or IP Address
    ############# ISSUE - health probe create error: Host specified for Probe '/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-1111/providers/Microsoft.Network/applicationGateways/tyrell-appgw-reg-1111/probes/tyrell-appgw-health-probe-001' is not valid. Host can only be null when pickHostNameFromBackendHttpSettings is set to true. Code: ApplicationGatewayProbeHostIsNull
    ############# ISSUE - only /blogs/* got added as url path map, not images.  may need to update with new rule

    # CREATE / UPDATE BACKEND POOL
    # backend already created with appgw, can be updated with create statement but - may need to update / set to change name
    # az network application-gateway address-pool create -g az305-project-02 --gateway-name tyrell-appgw-reg-003 --name appGatewayBackendPool --servers tyrell-webapp-reg-eastus-003 tyrell-webapp-imgs-eastus-003
    Write-Output "----------------------------"
    Write-Output "creating bak end pool"    
    $backendPools = @("appGatewayBackendPool", "$($trafficmgrs[0]).azurewebsites.net"), `
                    @("appGatewayBackendPool2", "$($trafficmgrs[1]).azurewebsites.net")
    # Write-Output "creating bak end pool"    
    # $backendPools = @("appGatewayBackendPool", "$appservices[0].azurewebsites.net $appservices[1].azurewebsites.net"), `
    #                 @("appGatewayBackendPool2", "$appservices[2].azurewebsites.net $appservices[3].azurewebsites.net")
    
    # $backendPoolName1 = "appGatewayBackendPool"
    # $backendServers1 = "$appservices[0].azurewebsites.net $appservices[1].azurewebsites.net"
    
    # $backendPoolName2 = "appGatewayBackendPool2"
    # $backendServers2 = "$appservices[2].azurewebsites.net $appservices[3].azurewebsites.net"
    
    foreach ($bepool in $backendPools) {
        $cmdout = az network application-gateway address-pool create -g $grp --gateway-name $appGWName `
                            --name $bepool[0] --servers $bepool[1]
        $sp += $cmdout
    }
    # $sp = az network application-gateway address-pool create -g $grp --gateway-name $appGWName --name $backendPoolName1 --servers $backendServers1
    # $sp = az network application-gateway address-pool create -g $grp --gateway-name $appGWName --name $backendPoolName2 --servers $backendServers2
    $sp

    # CREATE / UPDATE PATH MAP
    Write-Output "----------------------------"
    Write-Output "creating path map"   
    $defaultBePool = 2 
    $appPathMapName = "tyrell-appgw-pathmap"
    $defaultHttpSettings1 = $backendHttpSettings1
    $pathmaps = @("/images/*", "appGatewayBackendPool", "appGatewayBackendHttpSettings"), @("/blog/*", "appGatewayBackendPool2", "appGatewayBackendHttpSettings")
    # $path1 = "/images/*"
    # $backendPoolName1 = "appGatewayBackendPool"
    # $backendHttpSettings1 = "appGatewayBackendHttpSettings"
    # $path2 = "/blog/*"
    # $backendPoolName2 = "appGatewayBackendPool2"
    # $backendHttpSettings2 = "appGatewayBackendHttpSettings"

    # $sp = az network application-gateway url-path-map create --resource-group $grp --gateway-name $appGWName --name $appPathMapName `
    #         --paths $path1 --address-pool $backendPoolName1 --http-settings $backendHttpSettings1 --default-address-pool $backendPoolName1 --default-http-settings $backendHttpSettings1 `
    #         # --paths $path2 --address-pool $backendPoolName2  --http-settings $backendHttpSettings2 --default-address-pool $backendPoolName2 --default-http-settings $backendHttpSettings2


    foreach ($pathmap in $pathmaps) {
        $cmdout = az network application-gateway url-path-map create --resource-group $grp --gateway-name $appGWName `
                        --name $appPathMapName --paths $pathmap[0] `
                        --address-pool $pathmap[1] --http-settings  $pathmap[2] `
                        --default-address-pool $pathmap[1] --default-http-settings  $pathmap[2]
        $sp += $cmdout
        $cmdout
    }
    
    
    # az network application-gateway url-path-map rule create  --resource-group $grp --gateway-name $appGWName --name $appPathMapName `
    #                                             --name
    #                                             --path-map-name
    #                                             --paths
    #                                             --resource-group
    #                                             [--address-pool]
    #                                             [--http-settings]
    #                                             [--no-wait {0, 1, f, false, n, no, t, true, y, yes}]
    #                                             [--redirect-config]
    #                                             [--rewrite-rule-set]
    #                                             [--waf-policy]
    
    Write-Output "----------------------------"
    Write-Output "creating rule"    
    $gwRule = "rule1"
    $appGWListener = "appGatewayHttpListener"
    $cmdout = az network application-gateway rule update --resource-group $grp --gateway-name $appGWName --name $gwRule `
                --priority 99 --http-listener $appGWListener --rule-type PathBasedRouting `
                --address-pool $backendPools[$defaultBePool] --http-settings $defaultHttpSettings1 --url-path-map $appPathMapName
    # $sp = 'az network application-gateway rule create --gateway-name $appGWName --resource-group $grp --name $ruleName --http-listener $listenerName --rule-type PathBasedRoutingRule --backend-address-pool "backendPool"'
    $cmdout
    $sp += $cmdout


    # UPDATE BACKEND SETTINGS
    az network application-gateway http-settings update --gateway-name $appGWName `
                                                    --name "appGatewayBackendHttpSettings" `
                                                    --resource-group $grp `
                                                    --host-name-from-backend-pool "true" `
                                                    --path "/" `
                                                    --port 80
    
    # az network application-gateway http-settings update --gateway-name $appGWName `
    #                                                 --name "appGatewayBackendHttpSettings" `
    #                                                 --pickHostNameFromBackendHttpSettings "true" `
    #                                                 --resource-group "az305-project-1111" `
    #                                                 --host-name-from-backend-pool "true" `
    #                                                 --path "/" `
    #                                                 --port 80

    # add health probe - not added for app-gateway creation
    # https://learn.microsoft.com/en-us/cli/azure/network/application-gateway/probe?view=azure-cli-latest#az-network-application-gateway-probe-create
    $healthProbeName = "tyrell-appgw-health-probe-001"
    az network application-gateway probe create --resource-group $grp --gateway-name $appGWName --name $healthProbeName `
                                                --from-settings "true" `
                                                --port 80 `
                                                --path "/hostingstart.html"
    Write-Output "az network application-gateway probe create --resource-group $grp --gateway-name $appGWName --name $healthProbeName --from-settings ""true"" --port 80 --path ""/hostingstart.html"""
}
Exit

# 52.152.220.33 (52.255.202.7)

# appgwName
# appgwVnetName
# appgwVnetPrefix
# appgwSubnetName
# appgwSubnetPrefix
# publicIPName
# httpListenerName
# backendPoolName
# gwRuleName
# gwRulePort


# **** success
# az network vnet create -g az305-project-02 --location eastus -n tyrell-appgw-vnet-asia-003 --address-prefix 10.100.0.0/16 --subnet-name tyrell-appgw-subnet-asia-003 --subnet-prefixes 10.100.0.0/24
# az network public-ip create --name tyrell-appgw-pip-asia-003 --resource-group az305-project-02 --location eastus --allocation-method Static --sku Standard
# az network public-ip show --name  --resource-group az305-project-02 --query '{address: ipAddress}' --output json | ConvertFrom-Json
# az network application-gateway create -g az305-project-02 -n tyrell-appgw-reg-003 --vnet-name tyrell-appgw-vnet-asia-003 --subnet tyrell-appgw-subnet-asia-003 --http-settings-cookie-based-affinity Enabled --priority 100  --public-ip-address 52.255.202.7  --sku Standard_v2

# already created from app-gateway creation - issues: didn't get specific name
# **** failed on running post app-gateway creation - got an error that cannot change the name of existing FrontendIpConfiguration.
# az network application-gateway frontend-ip create -g az305-project-02 --gateway-name tyrell-appgw-reg-003 --name tyrell-frontendip-reg-003 --public-ip-address 52.255.202.7  --vnet-name tyrell-appgw-vnet-asia-003 --subnet tyrell-appgw-subnet-asia-003 | ConvertFrom-Json

# already created from app-gateway creation - issues: didn't get specific name, listener type is basic (not multi-site - not sure if an issue or not)
# **** failed on running post app-gateway creation - got an error that cannot change either - which is obvious as they weren't created
# az network application-gateway http-listener create -g az305-project-02 --gateway-name tyrell-appgw-reg-003 --name tyrell-appgw-http-listener --frontend-ip tyrell-appgw-pip-asia-003 --frontend-port 80 
# az network application-gateway http-listener create -g az305-project-02 --gateway-name tyrell-appgw-reg-003 --name appGatewayHttpListener --frontend-ip appGatewayFrontendIP --frontend-port 80 

# already created from app-gateway creation - issues: doesn't have any servers or other specified
# success **** worked on running post app-gateway creation - outcome: updated the pool settings to include the servers
# az network application-gateway address-pool create -g az305-project-02 --gateway-name tyrell-appgw-reg-003 --name "backendPool" --servers $webApp1Name $webApp2Name
# az network application-gateway address-pool create -g az305-project-02 --gateway-name tyrell-appgw-reg-003 --name appGatewayBackendPool --servers tyrell-webapp-reg-eastus-003 tyrell-webapp-imgs-eastus-003

# add health probe - not added for app-gateway creation
# https://learn.microsoft.com/en-us/cli/azure/network/application-gateway/probe?view=azure-cli-latest#az-network-application-gateway-probe-create
# az network application-gateway probe create --resource-group az305-project-02 --gateway-name tyrell-trafficmgr-reg-003 --name tyrell-appgw-health-probe-001 


# already created from app-gateway creation - issues: no path routing, 
# az network application-gateway rule create --resource-group az305-project-02 --gateway-name tyrell-trafficmgr-reg-003 --name $ruleName --http-listener $listenerName --rule-type PathBasedRoutingRule --backend-address-pool "backendPool"
# az network application-gateway rule list --gateway-name appgw-test-001 --resource-group az305-project-02 
# az network application-gateway url-path-map list --gateway-name appgw-test-001 --resource-group az305-project-02 

# success
# az network application-gateway url-path-map create --resource-group az305-project-02 --gateway-name tyrell-trafficmgr-reg-003 --name tyrell-appgw-pathmap --paths  /images/* --address-pool appGatewayBackendPool  --http-settings appGatewayBackendHttpSettings --default-address-pool appGatewayBackendPool --default-http-settings appGatewayBackendHttpSettings --paths  /blogs/* --address-pool appGatewayBackendPool2  --http-settings appGatewayBackendHttpSettings --default-address-pool appGatewayBackendPool2 --default-http-settings appGatewayBackendHttpSettings
# failed - another rule using listener - az network application-gateway rule create --resource-group az305-project-02 --gateway-name tyrell-trafficmgr-reg-003 --name tyrell-app-path-rule --priority 99 --http-listener appGatewayHttpListener --http-settings appGatewayBackendHttpSettings --rule-type PathBasedRouting --address-pool appGatewayBackendPool2 --url-path-map tyrell-appgw-pathmap
# az network application-gateway rule update --resource-group az305-project-02 --gateway-name tyrell-trafficmgr-reg-003 --name rule1 --priority 99 --http-listener appGatewayHttpListener --http-settings appGatewayBackendHttpSettings --rule-type PathBasedRouting --address-pool appGatewayBackendPool2 --url-path-map tyrell-appgw-pathmap



# PS G:\coding\envs\ps-az-setup> az network application-gateway url-path-map create --resource-group az305-project-02 --gateway-name tyrell-trafficmgr-reg-003 --name "tyrell-appgw-pathmap" --paths  /images/* --address-pool appGatewayBackendPool  --http-settings appGatewayBackendHttpSettings --default-address-pool appGatewayBackendPool --default-http-settings appGatewayBackendHttpSettings --paths  /blogs/* --address-pool appGatewayBackendPool2  --http-settings appGatewayBackendHttpSettings --default-address-pool appGatewayBackendPool2 --default-http-settings appGatewayBackendHttpSettings
# {
#   "defaultBackendAddressPool": {
#     "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/backendAddressPools/appGatewayBackendPool2",
#     "resourceGroup": "az305-project-02"
#   },
#   "defaultBackendHttpSettings": {
#     "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/backendHttpSettingsCollection/appGatewayBackendHttpSettings",
#     "resourceGroup": "az305-project-02"
#   },
#   "etag": "W/\"1927b9b0-9185-445c-8333-1a0410f6f399\"",
#   "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/urlPathMaps/tyrell-appgw-pathmap",    
#   "name": "tyrell-appgw-pathmap",
#   "pathRules": [
#     {
#       "backendAddressPool": {
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/backendAddressPools/appGatewayBackendPool2",
#         "resourceGroup": "az305-project-02"
#       },
#       "backendHttpSettings": {
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/backendHttpSettingsCollection/appGatewayBackendHttpSettings",
#         "resourceGroup": "az305-project-02"
#       },
#       "etag": "W/\"1927b9b0-9185-445c-8333-1a0410f6f399\"",
#       "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/urlPathMaps/tyrell-appgw-pathmap/pathRules/default",
#       "name": "default",
#       "paths": [
#         "/blogs/*"
#       ],
#       "provisioningState": "Succeeded",
#       "resourceGroup": "az305-project-02",
#       "type": "Microsoft.Network/applicationGateways/urlPathMaps/pathRules"
#     }
#   ],
#   "provisioningState": "Succeeded",
#   "resourceGroup": "az305-project-02",
#   "type": "Microsoft.Network/applicationGateways/urlPathMaps"
# }

# az network application-gateway url-path-map list --gateway-name appgw-test-001 --resource-group az305-project-02 
# [
#   {
#     "defaultBackendAddressPool": {
#       "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/backendAddressPools/backend-pool",
#       "resourceGroup": "az305-project-02"
#     },
#     "defaultBackendHttpSettings": {
#       "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/backendHttpSettingsCollection/appgw-test-backend-setting",
#       "resourceGroup": "az305-project-02"
#     },
#     "etag": "W/\"3aba2306-1711-47a8-b23b-44120d5869ec\"",
#     "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/urlPathMaps/appgw-test-rule",
#     "name": "appgw-test-rule",
#     "pathRules": [
#       {
#         "backendAddressPool": {
#           "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/backendAddressPools/backend-pool",       
#           "resourceGroup": "az305-project-02"
#         },
#         "backendHttpSettings": {
#           "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/backendHttpSettingsCollection/appgw-test-backend-setting",
#           "resourceGroup": "az305-project-02"
#         },
#         "etag": "W/\"3aba2306-1711-47a8-b23b-44120d5869ec\"",
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/urlPathMaps/appgw-test-rule/pathRules/appgw-target-images",
#         "name": "appgw-target-images",
#         "paths": [
#           "/images/*"
#         ],
#         "provisioningState": "Succeeded",
#         "resourceGroup": "az305-project-02",
#         "type": "Microsoft.Network/applicationGateways/urlPathMaps/pathRules"
#       },
#       {
#         "backendAddressPool": {
#           "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/backendAddressPools/backend-pool-reg",   
#           "resourceGroup": "az305-project-02"
#         },
#         "backendHttpSettings": {
#           "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/backendHttpSettingsCollection/appgw-test-backend-setting",
#           "resourceGroup": "az305-project-02"
#         },
#         "etag": "W/\"3aba2306-1711-47a8-b23b-44120d5869ec\"",
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/urlPathMaps/appgw-test-rule/pathRules/appgw-test-reg-target",
#         "name": "appgw-test-reg-target",
#         "paths": [
#           "/blog/*"
#         ],
#         "provisioningState": "Succeeded",
#         "resourceGroup": "az305-project-02",
#         "type": "Microsoft.Network/applicationGateways/urlPathMaps/pathRules"
#       }
#     ],
#     "provisioningState": "Succeeded",
#     "resourceGroup": "az305-project-02",
#     "type": "Microsoft.Network/applicationGateways/urlPathMaps"
#   }
# ]

# PS G:\coding\envs\ps-az-setup> az network application-gateway rule list --gateway-name appgw-test-001 --resource-group az305-project-02                                                                      
# [
#   {
#     "etag": "W/\"3aba2306-1711-47a8-b23b-44120d5869ec\"",
#     "httpListener": {
#       "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/httpListeners/appgw-test-listener-http",     
#       "resourceGroup": "az305-project-02"
#     },
#     "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/requestRoutingRules/appgw-test-rule",
#     "name": "appgw-test-rule",
#     "priority": 100,
#     "provisioningState": "Succeeded",
#     "resourceGroup": "az305-project-02",
#     "ruleType": "PathBasedRouting",
#     "type": "Microsoft.Network/applicationGateways/requestRoutingRules",
#     "urlPathMap": {
#       "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/appgw-test-001/urlPathMaps/appgw-test-rule",
#       "resourceGroup": "az305-project-02"
#     }
#   }
# ]

# $pln = "tyrell-images-" + $ver 
# $appname = "web-app-imgs-asia-" + $ver

# $pln2 = "ronnie-sp-" + $ver + "2" 
# $appname2 = "demoes-videos-ronnie-" + $ver + "1"

# $obj = "Service Plan"
# Write-Output "[$obj] Checking $obj"
# .\az-commands\az-service-plan.ps1 $grp $loc $pln2 $sub
# Write-Output "[$obj] Finished"

# $obj = "Web App"
# Write-Output "[$obj] Checking $obj"
# .\az-commands\az-web-app.ps1 $grp $pln $appname2 $sub
# Write-Output "[$obj] Finished"

# vNET
# $obj = "VNET"
# Write-Output "[$obj] Checking $obj"
# .\az-commands\az-network-vnet.ps1 $grp $vnetName $vnetPrefix $subnetName $subnetIP
# Write-Output "[$obj] Finished"



# [--public-network-access {Disabled, Enabled}]
# [--runtime]
# [--subnet]
# [--tags]
# [--vnet]

# $sub = "Simplilearn HOL 42"
# $loc = "eastus"
# $grp = "ronnie-rg-" + $ver + "1"

# $appGatewayName = "app-gateway-" + $ver + "1"
# $frontendIPName = "pip-app-gw-" + $ver + "1"
# $httpListenerName = "http-listener-" + $ver + "1"
# $ruleName = "http-rule-" + $ver + "1"
# $publicIpName = "ronnie-ip-std-" + $ver + "1"


# PS G:\coding\envs\ps-az-setup>  az network vnet create -g az305-project-02 --location eastus -n tyrell-appgw-vnet-asia-003 --address-prefix 10.100.0.0/16 --subnet-name tyrell-appgw-subnet-asia-003 --subnet-prefixes 10.100.0.0/24
# {
#   "newVNet": {
#     "addressSpace": {
#       "addressPrefixes": [
#         "10.100.0.0/16"
#       ]
#     },
#     "enableDdosProtection": false,
#     "etag": "W/\"c33bfd64-6cbf-4b3d-b973-f1bff635b0fb\"",
#     "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/virtualNetworks/tyrell-appgw-vnet-asia-003",
#     "location": "eastus",
#     "name": "tyrell-appgw-vnet-asia-003",
#     "provisioningState": "Succeeded",
#     "resourceGroup": "az305-project-02",
#     "resourceGuid": "35a71d0a-3d9c-4194-bcac-13f709e4e5f1",
#     "subnets": [
#       {
#         "addressPrefix": "10.100.0.0/24",
#         "delegations": [],
#         "etag": "W/\"c33bfd64-6cbf-4b3d-b973-f1bff635b0fb\"",
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/virtualNetworks/tyrell-appgw-vnet-asia-003/subnets/tyrell-appgw-subnet-asia-a-003/subnets/tyrell-appgw-subnet-asia-003",
#         "name": "tyrell-appgw-subnet-asia-003",
#         "privateEndpointNetworkPolicies": "Disabled",
#         "privateLinkServiceNetworkPolicies": "Enabled",
#         "provisioningState": "Succeeded",
#         "resourceGroup": "az305-project-02",
#         "type": "Microsoft.Network/virtualNetworks/subnets"
#       }
#     ],
#     "type": "Microsoft.Network/virtualNetworks",
#     "virtualNetworkPeerings": []
#   }
# }

# PS G:\coding\envs\ps-az-setup> az network public-ip create --name tyrell-appgw-pip-asia-003 --resource-group az305-project-02 --location eastus --allocation-method Static --sku Standard
# [Coming breaking change] In the coming release, the default behavior will be changed as follows when sku is Standard and zone is not provided: For zonal regions, you will get a zone-redundant IP indicated by zones:["1","2","3"]; For non-zonal regions, you will get a non zone-redundant IP indicated by zones:null.
# {
#   "publicIp": {
#     "ddosSettings": {
#       "protectionMode": "VirtualNetworkInherited"
#     },
#     "etag": "W/\"ad009fec-f9df-4847-86f6-f9f5a304f94a\"",
#     "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/publicIPAddresses/tyrell-appgw-pip-asia-003",
#     "idleTimeoutInMinutes": 4,
#     "ipAddress": "52.255.202.7",
#     "ipTags": [],
#     "location": "eastus",
#     "name": "tyrell-appgw-pip-asia-003",
#     "provisioningState": "Succeeded",
#     "publicIPAddressVersion": "IPv4",
#     "publicIPAllocationMethod": "Static",
#     "resourceGroup": "az305-project-02",
#     "resourceGuid": "924bb44e-5fbb-43d4-8568-524ff0c0f72a",
#     "sku": {
#       "name": "Standard",
#       "tier": "Regional"
#     },
#     "type": "Microsoft.Network/publicIPAddresses"
#   }
# }
# PS G:\coding\envs\ps-az-setup> 

# PS G:\coding\envs\ps-az-setup> az network application-gateway create -g az305-project-02 -n tyrell-trafficmgr-reg-003 --vnet-name tyrell-appgw-vnet-asia-003 --subnet tyrell-appgw-subnet-asia-003 --http-settings-cookie-based-affinity Enabled --priority 100  --public-ip-address 52.255.202.7  --sku Standard_v2
# {
#   "applicationGateway": {
#     "backendAddressPools": [
#       {
#         "etag": "W/\"8f9ad3c7-ee45-4bfa-8a8d-5cccd05ecba1\"",
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/backendAddressPools/appGatewayBackendPool",
#         "name": "appGatewayBackendPool",
#         "properties": {
#           "backendAddresses": [],
#           "provisioningState": "Succeeded",
#           "requestRoutingRules": [
#             {
#               "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/requestRoutingRules/rule1",
#               "resourceGroup": "az305-project-02"
#             }
#           ]
#         },
#         "resourceGroup": "az305-project-02",
#         "type": "Microsoft.Network/applicationGateways/backendAddressPools"
#       }
#     ],
#     "backendHttpSettingsCollection": [
#       {
#         "etag": "W/\"8f9ad3c7-ee45-4bfa-8a8d-5cccd05ecba1\"",
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/backendHttpSettingsCollection/appGatewayBackendHttpSettings",
#         "name": "appGatewayBackendHttpSettings",
#         "properties": {
#           "connectionDraining": {
#             "drainTimeoutInSec": 1,
#             "enabled": false
#           },
#           "cookieBasedAffinity": "Enabled",
#           "pickHostNameFromBackendAddress": false,
#           "port": 80,
#           "protocol": "Http",
#           "provisioningState": "Succeeded",
#           "requestRoutingRules": [
#             {
#               "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/requestRoutingRules/rule1",
#               "resourceGroup": "az305-project-02"
#             }
#           ],
#           "requestTimeout": 30
#         },
#         "resourceGroup": "az305-project-02",
#         "type": "Microsoft.Network/applicationGateways/backendHttpSettingsCollection"
#       }
#     ],
#     "backendSettingsCollection": [],
#     "frontendIPConfigurations": [
#       {
#         "etag": "W/\"8f9ad3c7-ee45-4bfa-8a8d-5cccd05ecba1\"",
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/frontendIPConfigurations/appGatewayFrontendIP",
#         "name": "appGatewayFrontendIP",
#         "properties": {
#           "httpListeners": [
#             {
#               "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/httpListeners/appGatewayHttpListener",
#               "resourceGroup": "az305-project-02"
#             }
#           ],
#           "privateIPAllocationMethod": "Dynamic",
#           "provisioningState": "Succeeded",
#           "publicIPAddress": {
#             "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/publicIPAddresses/52.255.202.7", 
#             "resourceGroup": "az305-project-02"
#           }
#         },
#         "resourceGroup": "az305-project-02",
#         "type": "Microsoft.Network/applicationGateways/frontendIPConfigurations"
#       }
#     ],
#     "frontendPorts": [
#       {
#         "etag": "W/\"8f9ad3c7-ee45-4bfa-8a8d-5cccd05ecba1\"",
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/frontendPorts/appGatewayFrontendPort",
#         "name": "appGatewayFrontendPort",
#         "properties": {
#           "httpListeners": [
#             {
#               "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/httpListeners/appGatewayHttpListener",
#               "resourceGroup": "az305-project-02"
#             }
#           ],
#           "port": 80,
#           "provisioningState": "Succeeded"
#         },
#         "resourceGroup": "az305-project-02",
#         "type": "Microsoft.Network/applicationGateways/frontendPorts"
#       }
#     ],
#     "gatewayIPConfigurations": [
#       {
#         "etag": "W/\"8f9ad3c7-ee45-4bfa-8a8d-5cccd05ecba1\"",
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/gatewayIPConfigurations/appGatewayFrontendIP",
#         "name": "appGatewayFrontendIP",
#         "properties": {
#           "provisioningState": "Succeeded",
#           "subnet": {
#             "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/virtualNetworks/tyrell-appgw-vnet-asia-003/subnets/tyrell-appgw-subnet-asia-003",
#             "resourceGroup": "az305-project-02"
#           }
#         },
#         "resourceGroup": "az305-project-02",
#         "type": "Microsoft.Network/applicationGateways/gatewayIPConfigurations"
#       }
#     ],
#     "httpListeners": [
#       {
#         "etag": "W/\"8f9ad3c7-ee45-4bfa-8a8d-5cccd05ecba1\"",
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/httpListeners/appGatewayHttpListener",
#         "name": "appGatewayHttpListener",
#         "properties": {
#           "frontendIPConfiguration": {
#             "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/frontendIPConfigurations/appGatewayFrontendIP",
#             "resourceGroup": "az305-project-02"
#           },
#           "frontendPort": {
#             "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/frontendPorts/appGatewayFrontendPort",
#             "resourceGroup": "az305-project-02"
#           },
#           "hostNames": [],
#           "protocol": "Http",
#           "provisioningState": "Succeeded",
#           "requestRoutingRules": [
#             {
#               "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/requestRoutingRules/rule1",
#               "resourceGroup": "az305-project-02"
#             }
#           ],
#           "requireServerNameIndication": false
#         },
#         "resourceGroup": "az305-project-02",
#         "type": "Microsoft.Network/applicationGateways/httpListeners"
#       }
#     ],
#     "listeners": [],
#     "loadDistributionPolicies": [],
#     "operationalState": "Running",
#     "privateEndpointConnections": [],
#     "privateLinkConfigurations": [],
#     "probes": [],
#     "provisioningState": "Succeeded",
#     "redirectConfigurations": [],
#     "requestRoutingRules": [
#       {
#         "etag": "W/\"8f9ad3c7-ee45-4bfa-8a8d-5cccd05ecba1\"",
#         "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/requestRoutingRules/rule1",
#         "name": "rule1",
#         "properties": {
#           "backendAddressPool": {
#             "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/backendAddressPools/appGatewayBackendPool",
#             "resourceGroup": "az305-project-02"
#           },
#           "backendHttpSettings": {
#             "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/backendHttpSettingsCollection/appGatewayBackendHttpSettings",
#             "resourceGroup": "az305-project-02"
#           },
#           "httpListener": {
#             "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/httpListeners/appGatewayHttpListener",
#             "resourceGroup": "az305-project-02"
#           },
#           "priority": 100,
#           "provisioningState": "Succeeded",
#           "ruleType": "Basic"
#         },
#         "resourceGroup": "az305-project-02",
#         "type": "Microsoft.Network/applicationGateways/requestRoutingRules"
#       }
#     ],
#     "resourceGuid": "303a708d-fedf-4fab-b8b6-d8ef50882dba",
#     "rewriteRuleSets": [],
#     "routingRules": [],
#     "sku": {
#       "capacity": 2,
#       "family": "Generation_1",
#       "name": "Standard_v2",
#       "tier": "Standard_v2"
#     },
#     "sslCertificates": [],
#     "sslProfiles": [],
#     "trustedClientCertificates": [],
#     "trustedRootCertificates": [],
#     "urlPathMaps": []
#   }
# }

# PS G:\coding\envs\ps-az-setup> az network application-gateway address-pool create -g az305-project-02 --gateway-name tyrell-trafficmgr-reg-003 --name appGatewayBackendPool --servers tyrell-webapp-reg-eastus-003 tyrell-webapp-imgs-eastus-003
# {
#   "backendAddresses": [
#     {
#       "fqdn": "tyrell-webapp-reg-eastus-003"
#     },
#     {
#       "fqdn": "tyrell-webapp-imgs-eastus-003"
#     }
#   ],
#   "etag": "W/\"d0d35663-bc77-4d80-a369-f1d1f2d7b252\"",
#   "id": "/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-02/providers/Microsoft.Network/applicationGateways/tyrell-trafficmgr-reg-003/backendAddressPools/appGatewayBackendPool",
#   "name": "appGatewayBackendPool",
#   "provisioningState": "Succeeded",
#   "resourceGroup": "az305-project-02",
#   "type": "Microsoft.Network/applicationGateways/backendAddressPools"
# }