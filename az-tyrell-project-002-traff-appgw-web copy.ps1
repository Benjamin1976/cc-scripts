

$SUBSCRIPTION = "a5d9f35c-81e1-4f98-899b-e25bb26bfa3a"
$VER = "076"

$GRP = "az305-project-$VER"
$CIDR_PREFIX = "10"
$SUBSCRIPTIONRES = "/subscriptions/$SUBSCRIPTION/resourceGroups/$GRP/providers/"
$SUBSCRIPTIONFULL = "/subscriptions/$SUBSCRIPTION/resourceGroups/$GRP/providers/Microsoft.Web/sites/"
$SUBS= @("australiasoutheast", "aus", "20", "AU-VIC"), @("eastus", "eastus",  "10", "US-NY")
# $SUBS= @("eastus", "eastus",  "10", "US-NY"), @("australiasoutheast", "aus", "20", "AU-VIC"), @("eastasia", "asia", "30", "SG")
$GRP_LOC = $SUBS[0][0]
$TYPES= @("imgs", "reg")
$SP_NAME  = "tyrell-plan"
$APP_NAME = "tyrell"
# $APP_NAME = "tyrell-webapp"
$FILE = "G:\coding\envs\ps-az-setup\logs\az-creation-log-$GRP-$(get-date -f yyyy-MM-dd).txt"
$TRAFFICMGR_PATH = "/"
$POOL_TYPE = "trafficmgr" # trafficmgr, appservice

$ADMIN_USER = "benjamin"
$ADMIN_PASSWORD = "benjamin_123"
$deployUser = "$GRP-benjammin-deploy-76"
$deployPass = "benjamin_123"
# $RUNTIME = "Ubuntu2204"
# $RUNTIME =  "ASPNET:V4.8"
$RUNTIME =  "Win2022Datacenter"
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage

function WriteOutFile {
    param($file, $output, $screen)
    Add-Content -Path $FILE -Value $output
    if (($null -eq $screen) -or ($screen)) {
        Write-Host $output
    }
}

function CheckLogFile {
    param($file, $output)
    If ([string]::IsNullOrEmpty($output)) { $output = 'Log File' }    

    if (!(Test-Path $file)) {
        New-Item -path $file -type "file" -value $output
    }
    Clear-Content -path $file
}

function GitConfig {
                    # $envPath = "G:\coding\envs\ps-az-setup\sites\$type-$locCode"
                # $gitPath = "az-$type-$locCode-$VER"
                # # $gitPath = "az-imgs-asia"
                # $gitURL = "https://benjammin-deploy-76@$web_app_name.scm.azurewebsites.net/$web_app_name.git"
                # # $gitURL = "https://az305-project-101-benjammin-deploy-76@tyrell-webapp-imgs-asia-101.scm.azurewebsites.net/tyrell-webapp-imgs-asia-101.git"

                # WriteOutFile -file $file -output "----------------------------"
                # WriteOutFile -file $file -output "deploying code from git"
                # WriteOutFile -file $file -output "from: $envPath"
                # WriteOutFile -file $file -output "alias: $gitPath"
                # WriteOutFile -file $file -output "to: $gitURL"
                

                # # Push-Location -EA Stop G:\coding\envs\ps-az-setup\sites\imgs-asia 
                # # az webapp deployment source config-local-git --name tyrell-webapp-imgs-asia-200 --resource-group az305-project-200  | ConvertFrom-Json
                # # git remote add az-imgs-asia-200 https://az305-project-200-benjammin-deploy-76@tyrell-webapp-imgs-asia-200.scm.azurewebsites.net/tyrell-webapp-imgs-asia-200.git
                # # git pull https://az305-project-200-benjammin-deploy-76:benjamin_123@tyrell-webapp-imgs-asia-200.scm.azurewebsites.net/tyrell-webapp-imgs-asia-200.git master
                # # git add -A            
                # # git commit -m 'first deploy'            
                # # git push az-imgs-asia-200 master
                # # Pop-Location

                # Push-Location -EA Stop $envPath      # You'd use C:\RunTestExeHere instead
                # WriteOutFile -file $FILE -output $cmdOut
                # $cmdOut = az webapp deployment source config-local-git --name  -output $cmdOut --resource-group $GRP | ConvertFrom-Json
                # $gitURL = $cmd.url
                # # $cmd= az webapp deployment source config-local-git --name tyrell-webapp-imgs-asia-101 --resource-group az305-project-101
                # WriteOutFile -file $FILE -output $cmdOut
                
                # $cmdOut = git remote add $gitPath $gitURL
                # # $cmdOut = git remote add az-imgs-asia https://az305-project-101-benjammin-deploy-76@tyrell-webapp-imgs-asia-101.scm.azurewebsites.net/tyrell-webapp-imgs-asia-101.git
                # # $cmdOut = git remote add az-imgs-asia https://tyrell-webapp-imgs-asia-101.scm.azurewebsites.net
                # WriteOutFile -file $FILE -output $cmdOut
                
                # $cmdOut = git add -A
                # WriteOutFile -file $FILE -output $cmdOut
                
                # $cmdOut = git commit -m 'first deploy'
                # WriteOutFile -file $FILE -output $cmdOut
                
                # $cmdOut = git push $gitPath master
                # WriteOutFile -file $FILE -output $cmdOut
                # Pop-Location

}

# az webapp list-rusntimes
CheckLogFile -file $FILE -$output "Creating for AZ305-Project-02"
$cmdOut = ""
$CREATE_TYPE = "vmss"  # "appservices" | "vmss" | "trafficmgr"
$CREATE_RG = $false
$CREATE_VMSS = $true
$CREATE_APP_SERVICE = $true
$CREATE_TRAFFICMGR = $true
$CREATE_APPGW = $true

$APP_SERVICES = @()
$TRAFFICMGRS = @()
$VMSSS = @()
$APPGWNames = @()
$APPGWIps = @()
$PUBLIC_IPS = @()
$RUNCMDS = $false


# tyrell-vnet-aus-001
# 10.10.0.0/16
# tyrell-vmss-subnet-aus-001
# 10.10.0.0/24
# tyrell-appgw-subnet-aus-001
# 10.10.230.0/24
# tyrell-imgs-aus-001
# tyrell-reg-aus-001



# $vmssName = $APP_NAME, $type, $locCode, $VER -join "-"
# $vmssPIP = $APP_NAME, "pip", $type, $locCode, $VER -join "-"




if ($CREATE_RG) {
    WriteOutFile -file $file -output "********************************************************"
    WriteOutFile -file $file -output "Creating Resource Group & Setting deployment user"
    WriteOutFile -file $file -output "--------------------------------------------------------"

    $cmdOut = az group create --location $GRP_LOC --name $GRP | ConvertFrom-Json
    WriteOutFile -file $FILE -output $cmdOut

    $cmdOut = az webapp deployment user set --user-name $deployUser --password $deployPass | ConvertFrom-Json
    WriteOutFile -file $FILE -output $cmdOut

    $storageName = $GRP.replace('-','')
    $cmdOut = az storage account create -n $storageName -g $GRP -l $GRP_LOC `
    --sku Standard_LRS --allow-blob-public-access true --public-network-access Enabled
    
    $containerName = "scripts-$RUNTIME".ToLower()
    # $cmdOut = az storage container create -n mystoragecontainer --public-access container
    # az305project066storage

    # foreach ($sub in $subs) {
    #     foreach ($type in $types) {
    #             $cmdOut = az storage file upload --account-name $storageNamet --account-key NT9ewNtqU1CB+Z7Lzm5f3UOvWbywC8b0Bk8TWnp06zwzDCoe3vGV2u/wQmupT04//pqpIyOwsn/Q9rtSDBdVdg== --share-name myfileshare --path "myDirectory/index.php" --source "/home/scrapbook/tutorial/php-docs-hello-world/index.php"
    #     }   
    # }
}

# CREATE MACHINE SCALE SETS
if ($CREATE_TYPE -eq "vmss") {
    foreach ($sub in  $subs) {
        $location = $sub[0]
        $locCode = $sub[1]
        $vnetName = $APP_NAME, "vnet", $locCode, $VER -join "-"
        $vnetPrefix = $CIDR_PREFIX, ".", $sub[2], ".0", ".0", "/16" -join ""
        
        $subnetName = $APP_NAME, "subnet", $locCode, $VER -join "-"
        $subnetPrefix = $CIDR_PREFIX, ".", $sub[2], ".10", ".0", "/24" -join ""

        # $appGWName = $APP_NAME, "appgw", $locCode, $VER -join "-"
        # $appGWSubnetName = "tyrell", "appgw", "subnet",  $locCode, $VER -join "-"
        # $appGWSubnetPrefix = $CIDR_PREFIX, ".", $sub[2], ".230", ".0", "/24" -join ""     

        WriteOutFile -file $file -output "****************************"
        WriteOutFile -file $file -output "Creating Machine Scale Sets"
        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating vnet & subnet"
        WriteOutFile -file $file -output "vnet: $vnetName, $vnetPrefix"
        WriteOutFile -file $file -output "subnet: $subnetName, $subnetPrefix"
        WriteOutFile -file $file -output "appGW: $appGWSubnetName, $appGWSubnetPrefix"
        WriteOutFile -file $file -output "location: $location"

        
        if ($CREATE_VMSS) {
            $cmdOut = "az network vnet create -g $GRP --location $location -n $vnetName --address-prefix $vnetPrefix --subnet-name $subnetName --subnet-prefixes $subnetPrefix | ConvertFrom-Json"
            WriteOutFile -file $FILE -output $cmdOut

            if ($RUNCMDS) {
                $cmdOut = az network vnet create -g $GRP --location $location -n $vnetName --address-prefix $vnetPrefix --subnet-name $subnetName --subnet-prefixes $subnetPrefix | ConvertFrom-Json
                WriteOutFile -file $FILE -output $cmdOut
            }
            # $cmdOut.newVNet.name
            # $cmdOut.newVNet.id
        } else {
            WriteOutFile -file $file -output "not instructed to create"
        }

        $ipPairs = @()
        $vmPairs = @()
        foreach ($type in  $types) {
        
            # Add-Content -Path $FILE -Value $sp

            $vmssName = $APP_NAME, $type, $locCode, $VER -join "-"
            $vmssPIP = $APP_NAME, "pip", $type, $locCode, $VER -join "-"

            WriteOutFile -file $file -output "----------------------------"
            WriteOutFile -file $file -output "creating machine scale set"
            WriteOutFile -file $file -output "machine set: $vmssName"
            WriteOutFile -file $file -output "service vnet: $vnetName"
            WriteOutFile -file $file -output "service sub: $subnetName"
            WriteOutFile -file $file -output "runtime: $RUNTIME"
            WriteOutFile -file $file -output "private IP: $vmssPIP"

            $customData = "customData.txt"
            if ($CREATE_VMSS) {
                # if ($type -eq "imgs") {
                    $cmdOut = "az vmss create `
                            --resource-group $GRP `
                            --name $vmssName `
                            --location $location `
                            --vnet-name $vnetName `
                            --subnet $subnetName `
                            --image $RUNTIME `
                            --lb-sku Standard `
                            --public-ip-address $vmssPIP `
                            --upgrade-policy-mode automatic `
                            --authentication-type password `
                            --admin-username $ADMIN_USER `
                            --admin-password $ADMIN_PASSWORD"
                            
                            
                            # --authentication-type all `
                            # --generate-ssh-keys `
                            # --custom-data $customData"
                    WriteOutFile -file $FILE -output $cmdOut
                    
                    if ($RUNCMDS) {
                        $cmdOut = az vmss create `
                                --resource-group $GRP `
                                --name $vmssName `
                                --location $location `
                                --vnet-name $vnetName `
                                --subnet $subnetName `
                                --image $RUNTIME `
                                --lb-sku Standard `
                                --public-ip-address $vmssPIP `
                                --upgrade-policy-mode automatic `
                                --authentication-type password `
                                --admin-username $ADMIN_USER `
                                --admin-password $ADMIN_PASSWORD
                                
                                # --app-gateway $appGWName `
                                # --app-gateway-capacity 2 `
                                # --app-gateway-subnet-address-prefix $appGWSubnetPrefix `
                                # --app-gateway-sku Standard_Large `
                                # $cmdOut = az vmss create --resource-group az305-project-046 --name tyrell-webapp-imgs-eastus-046 --vnet-name tyrell-eastus-vnet-046 --subnet tyrell-eastus-subnet-046 --image Ubuntu2204 --lb-sku Standard --upgrade-policy-mode automatic --authentication-type all --admin-username benjamin --admin-password benjamin_123 --generate-ssh-keys --app-gateway tyrell-appgw-eastus-046 --app-gateway-capacity 2 --app-gateway-subnet-address-prefix 10.10.230.0/24 --app-gateway-sku Standard_Large 
                                
                                # --app-gateway-subnet-address-prefix $appGWSubnetPrefix `
                                # --public-ip-address $vmssPIP `
                        WriteOutFile -file $FILE -output $cmdOut
                    }
                    
                    # $scriptFile = "{$locCode}-{$type}.sh"
                    $scriptFile = "$locCode-$type.cmd"
                    $scriptFolder = $RUNTIME.ToLower()
                    $scriptURL = "https://az305project076.blob.core.windows.net/scripts-$scriptFolder/$scriptFile"

                    $jsonHash = @{
                        "fileUris" = "[$scriptURL]"
                        "commandToExecute" = "$scriptFile"
                      }
                    
                    $jsonURL = $jsonHash | ConvertTo-JSON
                    $cmdOut = "az vm extension set `
                        --resource-group $GRP `
                        --vm-name $vmssName `
                        --name customScript `
                        --publisher Microsoft.Azure.Extensions `
                        --protected-settings $jsonURL"
                    WriteOutFile -file $FILE -output $cmdOut
                    
                    if ($RUNCMDS) {
                        $cmdOut = az vm extension set `
                            --resource-group $GRP `
                            --vm-name $vmssName `
                            --name customScript `
                            --publisher Microsoft.Azure.Extensions `
                            --protected-settings $jsonURL 
                        WriteOutFile -file $FILE -output $cmdOut
                    }

            } else {
                WriteOutFile -file $file -output "not instructed to create"
            }
            $vmPairs += $vmssName
            $ipPairs += $vmssPIP
        }
        $PUBLIC_IPS += $ipPairs
        $VMSSS += $vmPairs
    }
}

# az network vnet subnet create --name tyrell-appgw-subnet-aus-076 --resource-group az305-project-076 --vnet-name tyrell-vnet-aus-076 --address-prefixes 10.20.230.0/24


if ($CREATE_APPGW) {
    $i = 0
    foreach ($sub in $subs) {
        # override
        # $VER = "210"


        # $vnetName = "tyrell", "appgw", "vnet", $VER -join "-"
        # $vnetName = "tyrell", $locCode, "vnet", $VER -join "-"
        # $vnetPrefix = $CIDR_PREFIX, ".", $sub[2], ".0", ".0", "/16" -join ""
        # # $vnetPrefix = $CIDR_PREFIX, ".", $sub[2], ".0", ".0", "/16" -join ""
        
        # $subnetName = "tyrell", $locCode, "subnet", $VER -join "-"
        # $subnetPrefix = $CIDR_PREFIX, ".", $sub[2], ".1", ".0", "/24" -join ""
        # # $subnetName = "tyrell", "appgw", "subnet", $VER -join "-"
        # $subnetPrefix = $CIDR_PREFIX, ".", $sub[2], ".230", ".0", "/24" -join ""

        # $publicIpName
        ## created health probe to traffic mgr dns
        ## created service endpoint on vnet
        ## change backend settings to override hostname and choose from backend pool

        $location = $sub[0]
        $locCode = $sub[1]
        $vnetName = $APP_NAME, "vnet", $locCode, $VER -join "-"
        $vnetPrefix = $CIDR_PREFIX, ".", $sub[2], ".0", ".0", "/16" -join ""
 
        $appGWName = $APP_NAME, "appgw", $locCode, $VER -join "-"
        $appGWSubnetName = $APP_NAME, "appgw", "subnet",  $locCode, $VER -join "-"
        $appGWSubnetPrefix = $CIDR_PREFIX, ".", $sub[2], ".230", ".0", "/24" -join ""
        $publicIpName = $APP_NAME, "pip", "appgw", $locCode, $VER -join "-"
        
        WriteOutFile -file $file -output "****************************"
        WriteOutFile -file $file -output "Creating App Gateway"
        WriteOutFile -file $file -output "appgw: $appGWName"
        
        # # CREATE VNET & SUBNET FOR APP GW
        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating appgw subnet"
        # WriteOutFile -file $file -output "creating vnet & subnet"
        # WriteOutFile -file $file -output "vnet: $vnetName, cidr: $vnetPrefix"
        WriteOutFile -file $file -output "subnet: $appGWSubnetName, cidr: $appGWSubnetPrefix"  
        $cmdOut = "az network vnet subnet create --name $appGWSubnetName `
            --resource-group $GRP `
            --vnet-name $vnetName `
            --address-prefixes $appGWSubnetPrefix"
        WriteOutFile -file $FILE -output $cmdOut

        if ($RUNCMDS) {
            $cmdOut = az network vnet subnet create --name $appGWSubnetName `
                --resource-group $GRP `
                --vnet-name $vnetName `
                --address-prefixes $appGWSubnetPrefix
            WriteOutFile -file $FILE -output $cmdOut
        }


        
        
        # CREATE PUBLIC IP
        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating public ip"
        WriteOutFile -file $file -output "public ip name: $publicIpName"
        $cmdOut = "az network public-ip create --name $publicIpName --resource-group $GRP `
                    --location $location `
                    --allocation-method Static --sku Standard"
        WriteOutFile -file $FILE -output $cmdOut
        
        $cmdOut= "az network public-ip show --name $publicIpName --resource-group $GRP `
                --query '{address: ipAddress}' --output json | ConvertFrom-Json"
        WriteOutFile -file $FILE -output $cmdOut
        
        if ($RUNCMDS) {
            $cmdOut = az network public-ip create --name $publicIpName --resource-group $GRP `
                        --location $location `
                        --allocation-method Static --sku Standard | ConvertFrom-Json
            WriteOutFile -file $FILE -output $cmdOut
            $pipName = $cmdOut.publicIp.name

            $cmdOut= az network public-ip show --name $publicIpName --resource-group $GRP `
                        --query '{address: ipAddress}' --output json | ConvertFrom-Json
            $pipAddress = $cmdOut.address
        }
        
        
        $APPGWIps += $pip
        $APPGWNames += $appGWName
        WriteOutFile -file $file -output "public ip name: $pip"
        
        # CREATE APP GW
        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating app gw"
        $cmdOut = "az network application-gateway create -g $GRP -n $appGWName `
                            --location $location `
                            --vnet-name $vnetName `
                            --subnet $appGWSubnetName `
                            --http-settings-cookie-based-affinity Enabled --priority 100  --public-ip-address $publicIpName --sku Standard_v2"
        WriteOutFile -file $FILE -output $cmdOut
        
        if ($RUNCMDS) {
            $cmdOut = az network application-gateway create -g $GRP -n $appGWName `
                                --vnet-name $vnetName `
                                --subnet $appGWSubnetName `
                                --http-settings-cookie-based-affinity Enabled --priority 100  --public-ip-address $publicIpName --sku Standard_v2
            WriteOutFile -file $FILE -output $cmdOut
        }
        
        # CREATE / UPDATE LISTENER
        # NOT NEEDED - listener already created with appgw, may need update if need specific name, listener type is basic (not multi-site - not sure if an issue or no
        # $sp = az network application-gateway http-listener create -g $GRP --gateway-name $appGWName --name $listenerName --frontend-ip $pip --frontend-port 80 --rule-name ""
        # $sp

        ############# ISSUE - cannot (or how to) define App service as backend pool.  maybe need to pass app service FQDN or IP Address
        ############# ISSUE - health probe create error: Host specified for Probe '/subscriptions/60980e3a-5f38-4652-8ff3-f7a7741e315e/resourceGroups/az305-project-1111/providers/Microsoft.Network/applicationGateways/tyrell-appgw-reg-1111/probes/tyrell-appgw-health-probe-001' is not valid. Host can only be null when pickHostNameFromBackendHttpSettings is set to true. Code: ApplicationGatewayProbeHostIsNull
        ############# ISSUE - only /blogs/* got added as url path map, not images.  may need to update with new rule

        # CREATE / UPDATE BACKEND POOL
        # backend already created with appgw, can be updated with create statement but - may need to update / set to change name
        # az network application-gateway address-pool create -g az305-project-02 --gateway-name tyrell-appgw-reg-003 --name appGatewayBackendPool --servers tyrell-webapp-reg-eastus-003 tyrell-webapp-imgs-eastus-003
        # Write-Output "creating bak end pool"    
        
        if ($CREATE_TYPE -eq "appservice") {
            $urlSuffix = ".azurewebsites.net"
        } elseif ($CREATE_TYPE -eq "trafficmgr") {
            $urlSuffix = ".trafficmanager.net"
        } elseif ($CREATE_TYPE -eq "vmss") {
            $urlSuffix = ""
        }

        $backendPools = @("appGatewayBackendPool", $PUBLIC_IPS[$i]), `
        @("appGatewayBackendPool2", $PUBLIC_IPS[$i+1])
        # $backendPools = @("appGatewayBackendPool", "$($TRAFFICMGRS[0])$urlSuffix"), `
        # @("appGatewayBackendPool2", "$($TRAFFICMGRS[1])$urlSuffix")
        
        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating back end pools"
        foreach ($bepool in $backendPools) {
            WriteOutFile -file $file -output "name: $($bepool[0])"
            WriteOutFile -file $file -output "servers: $($bepool[1])"
            $cmdOut = "az network application-gateway address-pool create -g $GRP `
                    --gateway-name $appGWName `
                    --name $($bepool[0]) `
                    --servers $($bepool[1])"
            WriteOutFile -file $FILE -output $cmdOut

            if ($RUNCMDS) {
                $cmdOut = az network application-gateway address-pool create -g $GRP `
                        --gateway-name $appGWName `
                        --name $($bepool[0]) `
                        --servers $($bepool[1])
                WriteOutFile -file $FILE -output $cmdOut
            }
        }

        # CREATE / UPDATE PATH MAP
        $defaultBePool = 1 
        $appPathMapName = "tyrell-appgw-pathmap-$locCode"
        $pathmaps = @("/images/*", "appGatewayBackendPool", "appGatewayBackendHttpSettings"), `
                @("/blog/*", "appGatewayBackendPool2", "appGatewayBackendHttpSettings")
        $defaultHttpSettings1 = $pathmaps[$defaultBePool][1]

        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating path map"
        
        foreach ($pathmap in $pathmaps) {
            WriteOutFile -file $file -output "creating path map"
            WriteOutFile -file $file -output "paths: $($pathmap[0])"
            WriteOutFile -file $file -output "pool: $($pathmap[1])"
            WriteOutFile -file $file -output "settings: $($pathmap[2])"

            $cmdOut = "az network application-gateway url-path-map create `
                    --resource-group $GRP `
                    --gateway-name $appGWName `
                    --name $appPathMapName `
                    --paths $($pathmap[0]) `
                    --address-pool $($pathmap[1]) `
                    --http-settings  $($pathmap[2]) `
                    --default-address-pool $($pathmap[1]) `
                    --default-http-settings $($pathmap[2])"
            WriteOutFile -file $FILE -output $cmdOut
            
            if ($RUNCMDS) {
                $cmdOut = az network application-gateway url-path-map create `
                        --resource-group $GRP `
                        --gateway-name $appGWName `
                        --name $appPathMapName `
                        --paths $($pathmap[0]) `
                        --address-pool $($pathmap[1]) `
                        --http-settings  $($pathmap[2]) `
                        --default-address-pool $($pathmap[1]) `
                        --default-http-settings $($pathmap[2])
                WriteOutFile -file $FILE -output $cmdOut
            }
        }

        # CREATE RULE FOR ROUTING
        $defaultBePoolName = $backendPools[$defaultBePool][0]
        $defaultSettingsName = $pathmaps[$defaultBePool][1]
        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating rule"
        WriteOutFile -file $file -output "name: $gwRule"
        WriteOutFile -file $file -output "listener: $appGWListener"
        WriteOutFile -file $file -output "pool: $defaultBePoolName"
        WriteOutFile -file $file -output "settings: $defaultSettingsName"
        WriteOutFile -file $file -output "path-map: $appPathMapName"
        $gwRule = "rule1"
        $appGWListener = "appGatewayHttpListener"
        $cmdOut = "az network application-gateway rule update `
            --resource-group $GRP `
            --gateway-name $appGWName `
            --name $gwRule --priority 99 `
            --http-listener $appGWListener --rule-type PathBasedRouting `
            --address-pool $defaultBePoolName `
            --http-settings $defaultSettingsName `
            --url-path-map $appPathMapName"
        WriteOutFile -file $FILE -output $cmdOut
        
        if ($RUNCMDS) {
            $cmdOut = az network application-gateway rule update `
                --resource-group $GRP `
                --gateway-name $appGWName `
                --name $gwRule --priority 99 `
                --http-listener $appGWListener --rule-type PathBasedRouting `
                --address-pool $defaultBePoolName `
                --http-settings $defaultSettingsName `
                --url-path-map $appPathMapName
            WriteOutFile -file $FILE -output $cmdOut
        }
        
        # $sp = 'az network application-gateway rule create --gateway-name $appGWName --resource-group $GRP --name $ruleName --http-listener $listenerName --rule-type PathBasedRoutingRule --backend-address-pool "backendPool"'
        
        
        # UPDATE BACKEND SETTINGS
        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating http settings"         
        $cmdOut = "az network application-gateway http-settings update --gateway-name $appGWName `
                --name appGatewayBackendHttpSettings `
                --resource-group $GRP `
                --host-name-from-backend-pool true `
                --path '/' --port 80"
        WriteOutFile -file $FILE -output $cmdOut
        
        if ($RUNCMDS) {
            $cmdOut = az network application-gateway http-settings update --gateway-name $appGWName `
                    --name appGatewayBackendHttpSettings `
                    --resource-group $GRP `
                    --host-name-from-backend-pool true `
                    --path '/' --port 80
            WriteOutFile -file $FILE -output $cmdOut
        }

        # UPDATE HEALTH PROBE
        # add health probe - not added for app-gateway creation
        # https://learn.microsoft.com/en-us/cli/azure/network/application-gateway/probe?view=azure-cli-latest#az-network-application-gateway-probe-create
        # WriteOutFile -file $file -output "----------------------------"
        # WriteOutFile -file $file -output "creating http probe"
        # $healthProbeName = "tyrell-appgw-health-probe-001"         
        # $cmdOut = az network application-gateway probe create --resource-group $GRP --gateway-name $appGWName `
        #             --name $healthProbeName `
        #             --port 80 --path '/'
        #             # --pickHostNameFromBackendHttpSettings true `
        #             # --from-settings true `
        # WriteOutFile -file $FILE -output $cmdOut
    
        # $cmdOut = az network application-gateway probe create --resource-group $GRP --gateway-name $appGWName `
        #                 --name $healthProbeName --from-settings true --port 80 --path '/hostingstart.html'
        # az network application-gateway probe show -g MyResourceGroup --gateway-name MyAppGateway -n MyProbe
        
        # az network application-gateway probe show -g az305-project-200 --gateway-name tyrell-appgw-200 -n health-probe-http
        # $cmdOut = az network application-gateway probe create --resource-group az305-project-200 `
        #         --gateway-name tyrell-appgw-200 --name tyrell-appgw-probe-http `
        #         --port 80 --path '/' `
        #         --host-name-from-settings true 
                # --from-settings true 
        # WriteOutFile -file $FILE -output $cmdOut
    }
    $i++ #increment counter for public IPS
    $i++ #increment twice due to using 2 array items
}

Exit
# CREATE TRAFFIC MGR
$tfmgrPre = "tyrell-trafficmgr"
if ($CREATE_TRAFFICMGR) {
    $tfmgrName = $tfmgrPre, $type, $VER -join "-"

    WriteOutFile -file $file -output "****************************"
    WriteOutFile -file $file -output "Creating Traffic Manager"
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "name: $tfmgrName"

    if ($CREATE_TRAFFICMGR) {
        $cmdOut = az network traffic-manager profile create --name $tfmgrName `
                --resource-group $GRP `
                --unique-dns-name $tfmgrName `
                --routing-method Performance `
                --ttl 30 `
                --protocol HTTP `
                --port 80 `
                --path $TRAFFICMGR_PATH `
                --interval 30 `
                --max-failures 3 `
                --timeout 10
        WriteOutFile -file $FILE -output $cmdOut
    } else {
        WriteOutFile -file $file -output "not instructed to create"
    }
    $TRAFFICMGRS +=$tfmgrName

    $i = 0
    foreach ($sub in $subs) {
        $locCode = $sub[1]
        $endpointName = $APP_NAME, "endpoint", $locCode, $VER -join "-"
        # $resId = "$SUBSCRIPTIONFULL$endpointName"
        $resId = "$($SUBSCRIPTIONRES)Microsoft.Network/applicationGateways/$($APPGWNames[$i])"
        $target = $APPGWIps[$i]
        # /subscriptions/c0de6865-a88e-448b-b905-781909aee251/resourceGroups/vmss-test-rg/providers/Microsoft.Network/applicationGateways/vmss-test-001

        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating traffic endpoint"
        WriteOutFile -file $file -output "traffic mgr: $tfmgrName"
        WriteOutFile -file $file -output "name: $endpointName"
        # WriteOutFile -file $file -output "geo-mapping: $($sub[3])"
        WriteOutFile -file $file -output "resId: $resId"

        if ($CREATE_TRAFFICMGR) {
            $cmdOut = az network traffic-manager endpoint create --name $endpointName --profile-name $tfmgrName --resource-group $GRP `
                        --type azureEndpoints --always-serve Disabled --target-resource-id $resId --target $target
            WriteOutFile -file $FILE -output $cmdOut
            
                            # --geo-mapping $($sub[3]) `
        } else {
            WriteOutFile -file $file -output "not instructed to create"
        }
        $i++

        $APPGWIps += $pip
        $APPGWNames += $appGWName
    }
}


Exit




# CREATE SERVICE PLAN & WEB APPS
# if ($CREATE_TYPE -eq "appservices") {
#     foreach ($sub in  $subs) {
#         foreach ($type in  $types) {

#             $location = $sub[0]
#             $locCode = $sub[1]
#             $vnetName = "tyrell", $type, "vnet", $locCode, $VER -join "-"
#             $vnetPrefix = $CIDR_PREFIX + ".0.0/16"
#             $subnetName = "tyrell", $type, "subnet", $locCode, $VER -join "-"
#             $subnetPrefix = $CIDR_PREFIX + "." + $sub[2] + ".0/24"
            
#             WriteOutFile -file $file -output "****************************"
#             WriteOutFile -file $file -output "Creating App Services"
#             WriteOutFile -file $file -output "----------------------------"
#             WriteOutFile -file $file -output "creating vnet & subnet"
#             WriteOutFile -file $file -output "vnet: $vnetName, $vnetPrefix"
#             WriteOutFile -file $file -output "subnet: $subnetName, $subnetPrefix"
#             WriteOutFile -file $file -output "location: $location"

            
#             if ($CREATE_APP_SERVICE) {
#                 $cmdOut = az network vnet create -g $GRP --location $location -n $vnetName --address-prefix $vnetPrefix --subnet-name $subnetName --subnet-prefixes $subnetPrefix | ConvertFrom-Json
#                 # $cmdOut.newVNet.name
#                 # $cmdOut.newVNet.id
#                 WriteOutFile -file $FILE -output $cmdOut
#             } else {
#                 WriteOutFile -file $file -output "not instructed to create"
#             }

#             $sp_plan = $SP_NAME, $type, $locCode, $VER  -join "-"
#             $web_app_name = $APP_NAME, $type, $locCode, $VER -join "-"

#             WriteOutFile -file $file -output "----------------------------"
#             WriteOutFile -file $file -output "creating service plan"
#             WriteOutFile -file $file -output "service plan: $sp_plan"
#             WriteOutFile -file $file -output "service loc: $($location)"
            
#             if ($CREATE_APP_SERVICE) {
#                 $cmd= az appservice plan create --name $sp_plan --resource-group $GRP --location $location --sku S1
#                 WriteOutFile -file $FILE -output $cmdOut
#             } else {
#                 WriteOutFile -file $file -output "not instructed to create"
#             }

#             WriteOutFile -file $file -output "----------------------------"
#             WriteOutFile -file $file -output "creating app service"
#             WriteOutFile -file $file -output "service plan: $sp_plan"
#             WriteOutFile -file $file -output "web app: $web_app_name"
#             WriteOutFile -file $file -output "service vnet: $vnetName"
#             WriteOutFile -file $file -output "service sub: $subnetName"
#             WriteOutFile -file $file -output "runtime: $RUNTIME"
            
#             if ($CREATE_APP_SERVICE) {
#                 $cmdOut = az webapp create --resource-group $GRP --name $web_app_name --plan $sp_plan --vnet $vnetName `
#                                         --subnet $subnetName --public-network-access Enabled --runtime $RUNTIME --deployment-local-git
#                 WriteOutFile -file $FILE -output $cmdOut

#                 $envPath = "G:\coding\envs\ps-az-setup\sites\$type-$locCode"
#                 $gitPath = "az-$type-$locCode-$VER"
#                 # $gitPath = "az-imgs-asia"
#                 $gitURL = "https://benjammin-deploy-76@$web_app_name.scm.azurewebsites.net/$web_app_name.git"
#                 # $gitURL = "https://az305-project-101-benjammin-deploy-76@tyrell-webapp-imgs-asia-101.scm.azurewebsites.net/tyrell-webapp-imgs-asia-101.git"

#                 WriteOutFile -file $file -output "----------------------------"
#                 WriteOutFile -file $file -output "deploying code from git"
#                 WriteOutFile -file $file -output "from: $envPath"
#                 WriteOutFile -file $file -output "alias: $gitPath"
#                 WriteOutFile -file $file -output "to: $gitURL"
                

#                 # Push-Location -EA Stop G:\coding\envs\ps-az-setup\sites\imgs-asia 
#                 # az webapp deployment source config-local-git --name tyrell-webapp-imgs-asia-200 --resource-group az305-project-200  | ConvertFrom-Json
#                 # git remote add az-imgs-asia-200 https://az305-project-200-benjammin-deploy-76@tyrell-webapp-imgs-asia-200.scm.azurewebsites.net/tyrell-webapp-imgs-asia-200.git
#                 # git pull https://az305-project-200-benjammin-deploy-76:benjamin_123@tyrell-webapp-imgs-asia-200.scm.azurewebsites.net/tyrell-webapp-imgs-asia-200.git master
#                 # git add -A            
#                 # git commit -m 'first deploy'            
#                 # git push az-imgs-asia-200 master
#                 # Pop-Location

#                 Push-Location -EA Stop $envPath      # You'd use C:\RunTestExeHere instead
#                 WriteOutFile -file $FILE -output $cmdOut
#                 $cmdOut = az webapp deployment source config-local-git --name $cmdOut --resource-group $GRP | ConvertFrom-Json
#                 $gitURL = $cmd.url
#                 # $cmd= az webapp deployment source config-local-git --name tyrell-webapp-imgs-asia-101 --resource-group az305-project-101
#                 WriteOutFile -file $FILE -output $cmdOut
                
#                 $cmdOut = git remote add $gitPath $gitURL
#                 # $cmdOut = git remote add az-imgs-asia https://az305-project-101-benjammin-deploy-76@tyrell-webapp-imgs-asia-101.scm.azurewebsites.net/tyrell-webapp-imgs-asia-101.git
#                 # $cmdOut = git remote add az-imgs-asia https://tyrell-webapp-imgs-asia-101.scm.azurewebsites.net
#                 WriteOutFile -file $FILE -output $cmdOut
                
#                 $cmdOut = git add -A
#                 WriteOutFile -file $FILE -output $cmdOut
                
#                 $cmdOut = git commit -m 'first deploy'
#                 WriteOutFile -file $FILE -output $cmdOut
                
#                 $cmdOut = git push $gitPath master
#                 WriteOutFile -file $FILE -output $cmdOut
#                 Pop-Location
#             } else {
#                 WriteOutFile -file $file -output "not instructed to create"
#             }
#             $APP_SERVICES += $cmdOut
#         }
#     }
# }