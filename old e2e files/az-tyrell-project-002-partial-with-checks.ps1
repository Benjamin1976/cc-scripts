

$SUBSCRIPTION = "c0de6865-a88e-448b-b905-781909aee251"
$VER = "016"

$GRP = "az305-project-$VER"
$CIDR_PREFIX = "10.0"
$SUBSCRIPTIONFULL = "/subscriptions/$SUBSCRIPTION/resourceGroups/$GRP/providers/Microsoft.Web/sites/"
$SUBS= @("eastus", "eastus",  "10", "US-NY"), @("australiasoutheast", "aus", "20", "AU-VIC"), @("eastasia", "asia", "30", "SG")
$GRP_LOC = $SUBS[0][0]
$TYPES= @("imgs", "reg")
$SP_NAME  = "tyrell-plan"
$APP_NAME = "tyrell-webapp"
$RUNTIME =  "ASPNET:V4.8"
$FILE = "G:\coding\envs\ps-az-setup\logs\az-creation-log-$GRP-$(get-date -f yyyy-MM-dd).txt"
$TRAFFICMGR_PATH = "/"
$POOL_TYPE = "trafficmgr" # trafficmgr, appservice


function WriteOutFile {
    param($file, $output, $screen)
    Add-Content -Path $FILE -Value $output
    if (($null -eq $screen) -or ($screen)) {
        Write-Host $output
    }
}

function ExecLogCmd {
    param($cmd, $json)
    WriteOutFile -file $file -output $cmd
    if ($json) {
        $cmdOut = Invoke-Expression $cmd | ConvertFrom-Json
    } else {
        $cmdOut = Invoke-Expression $cmd 
    }
    WriteOutFile -file $file -output $cmdOut
    return $cmdOut
}

function CheckExists {
    param($json, $check, $cmd)
    if ($json) {
        $cmdOut = Invoke-Expression $cmd | ConvertFrom-Json
    } else {
        $cmdOut = Invoke-Expression $cmd 
    }
    $cmdOut
    if ($cmdOut -eq $check) {
        Write-Host "Found"
    } else {
        Write-Host "Not Found"
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

# az webapp list-rusntimes
$cmdOut = ""
$CREATE_RG = $false
$CREATE_APP_SERVICE = $true
$CREATE_TRAFFICMGR = $true
$CREATE_APPGW = $true

$APP_SERVICES = @()
$TRAFFICMGRS = @()
$APPGWS = @()


if ($CREATE_RG) {
    WriteOutFile -file $file -output "********************************************************"
    WriteOutFile -file $file -output "Creating Resource Group & Setting deployment user"
    WriteOutFile -file $file -output "--------------------------------------------------------"

    $cmdOut = az group exists --name $GRP | ConvertFrom-Json
    if ($cmdOut -eq $true) {
        WriteOutFile -file $file -output "group exists: $GRP"
    } else {
        WriteOutFile -file $file -output "group doesn't exists"
        $cmdOut = az group create --location eastus --name $GRP | ConvertFrom-Json
        # $cmdOut.id
    }
    WriteOutFile -screen $false -file $FILE -output $cmdOut
    

    $deployUser = "$GRP-benjammin-deploy-76"
    $deployPass = "benjamin_123"

    $obj = "deployment user"
    $cmdOut = az webapp deployment user show | ConvertFrom-Json
    $prop = "publishingUserName"
    if ($null -ne $cmdOut.$prop) {
        WriteOutFile -file $file -output "$obj exists: $($cmdOut.$prop)"
    } else {
        WriteOutFile -file $file -output "$obj doesn't exist, creating"
        $cmdOut = az webapp deployment user set --user-name $deployUser --password $deployPass | ConvertFrom-Json
        # $cmdOut.$prop
    }
    WriteOutFile -screen $false -file $FILE -output $cmdOut
}

# CREATE SERVICE PLAN & APP GATEWAY
foreach ($sub in  $subs) {
    foreach ($type in  $types) {

        $location = $sub[0]
        $locCode = $sub[1]
        $vnetName = "tyrell", $type, "vnet", $locCode, $VER -join "-"
        $vnetPrefix = $CIDR_PREFIX + ".0.0/16"
        $subnetName = "tyrell", $type, "subnet", $locCode, $VER -join "-"
        $subnetPrefix = $CIDR_PREFIX + "." + $sub[2] + ".0/24"
        
        WriteOutFile -file $file -output "****************************"
        WriteOutFile -file $file -output "Creating App Services"
        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating vnet & subnet"
        WriteOutFile -file $file -output "vnet: $vnetName, $vnetPrefix"
        WriteOutFile -file $file -output "subnet: $subnetName, $subnetPrefix"
        WriteOutFile -file $file -output "location: $location"

        
        if ($CREATE_APP_SERVICE) {
            $obj = "vnet & subnet"
            $cmdOut = az network vnet show -g $GRP -n "$vnetName-111"  #| ConvertFrom-Json
            $cmdOut
            if (("" -ne $cmdOut) ) { #-or ($null -ne $cmdOut."publishingUserName")
                WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
            } else {
                WriteOutFile -file $file -output "$obj doesn't exist, creating"            
                $cmdOut = az network vnet create -g $GRP --location $location -n $vnetName --address-prefix $vnetPrefix --subnet-name $subnetName --subnet-prefixes $subnetPrefix | ConvertFrom-Json
                # $cmdOut.newVNet.name
                # $cmdOut.newVNet.id
            }
            WriteOutFile -file $FILE -output $cmdOut
        } else {
            WriteOutFile -file $file -output "not instructed to create"
        }
        Exit
    
        # Add-Content -Path $FILE -Value $sp

        $sp_plan = $SP_NAME, $type, $locCode, $VER  -join "-"
        $web_app_name = $APP_NAME, $type, $locCode, $VER -join "-"

        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating service plan"
        WriteOutFile -file $file -output "service plan: $sp_plan"
        WriteOutFile -file $file -output "service loc: $($location)"
        
        if ($CREATE_APP_SERVICE) {
            $obj = "service plan"
            $cmdOut =  az appservice plan show --name $sp_plan --resource-group $GRP | ConvertFrom-Json
            if ($null -ne $cmdOut."publishingUserName") {
                WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
            } else {
                WriteOutFile -file $file -output "$obj doesn't exist, creating"
                $cmd= az appservice plan create --name $sp_plan --resource-group $GRP --location $location --sku S1
            }
            WriteOutFile -file $FILE -output $cmdOut
        } else {
            WriteOutFile -file $file -output "not instructed to create"
        }

        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating app service"
        WriteOutFile -file $file -output "service plan: $sp_plan"
        WriteOutFile -file $file -output "web app: $web_app_name"
        WriteOutFile -file $file -output "service vnet: $vnetName"
        WriteOutFile -file $file -output "service sub: $subnetName"
        WriteOutFile -file $file -output "runtime: $RUNTIME"
        
        if ($CREATE_APP_SERVICE) {
            $obj = "app service"
            $cmdOut =  az webapp show --resource-group $GRP --name $web_app_name  | ConvertFrom-Json
            if ($null -ne $cmdOut."publishingUserName") {
                WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
            } else {
                WriteOutFile -file $file -output "$obj doesn't exist, creating"
                $cmdOut = az webapp create --resource-group $GRP --name $web_app_name --plan $sp_plan --vnet $vnetName `
                                        --subnet $subnetName --public-network-access Enabled --runtime $RUNTIME --deployment-local-git
            }
            WriteOutFile -file $FILE -output $cmdOut

            $envPath = "G:\coding\envs\ps-az-setup\sites\$type-$locCode"
            $gitPath = "az-$type-$locCode-$VER"
            # $gitPath = "az-imgs-asia"
            $gitURL = "https://benjammin-deploy-76@$web_app_name.scm.azurewebsites.net/$web_app_name.git"
            # $gitURL = "https://az305-project-101-benjammin-deploy-76@tyrell-webapp-imgs-asia-101.scm.azurewebsites.net/tyrell-webapp-imgs-asia-101.git"

            WriteOutFile -file $file -output "----------------------------"
            WriteOutFile -file $file -output "deploying code from git"
            WriteOutFile -file $file -output "from: $envPath"
            WriteOutFile -file $file -output "alias: $gitPath"
            WriteOutFile -file $file -output "to: $gitURL"
            

            # Push-Location -EA Stop G:\coding\envs\ps-az-setup\sites\imgs-asia 
            # az webapp deployment source config-local-git --name tyrell-webapp-imgs-asia-200 --resource-group az305-project-200  | ConvertFrom-Json
            # git remote add az-imgs-asia-200 https://az305-project-200-benjammin-deploy-76@tyrell-webapp-imgs-asia-200.scm.azurewebsites.net/tyrell-webapp-imgs-asia-200.git
            # git pull https://az305-project-200-benjammin-deploy-76:benjamin_123@tyrell-webapp-imgs-asia-200.scm.azurewebsites.net/tyrell-webapp-imgs-asia-200.git master
            # git add -A            
            # git commit -m 'first deploy'            
            # git push az-imgs-asia-200 master
            # Pop-Location

            Push-Location -EA Stop $envPath      # You'd use C:\RunTestExeHere instead
            WriteOutFile -file $FILE -output $cmdOut
            $cmdOut = az webapp deployment source config-local-git --name  -output $cmdOut --resource-group $GRP | ConvertFrom-Json
            $gitURL = $cmd.url
            # $cmd= az webapp deployment source config-local-git --name tyrell-webapp-imgs-asia-101 --resource-group az305-project-101
            WriteOutFile -file $FILE -output $cmdOut
            
            $cmdOut = git remote add $gitPath $gitURL
            # $cmdOut = git remote add az-imgs-asia https://az305-project-101-benjammin-deploy-76@tyrell-webapp-imgs-asia-101.scm.azurewebsites.net/tyrell-webapp-imgs-asia-101.git
            # $cmdOut = git remote add az-imgs-asia https://tyrell-webapp-imgs-asia-101.scm.azurewebsites.net
            WriteOutFile -file $FILE -output $cmdOut
            
            $cmdOut = git add -A
            WriteOutFile -file $FILE -output $cmdOut
            
            $cmdOut = git commit -m 'first deploy'
            WriteOutFile -file $FILE -output $cmdOut
            
            $cmdOut = git push $gitPath master
            WriteOutFile -file $FILE -output $cmdOut
            Pop-Location
        } else {
            WriteOutFile -file $file -output "not instructed to create"
        }
        $APP_SERVICES += $cmdOut
    }
}

# CREATE TRAFFIC MGR
$tfmgrPre = "tyrell-trafficmgr"
foreach ($type in $types) {
    $tfmgrName = $tfmgrPre, $type, $VER -join "-"

    WriteOutFile -file $file -output "****************************"
    WriteOutFile -file $file -output "Creating Traffic Manager"
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "name: $tfmgrName"

    if ($CREATE_TRAFFICMGR) {
        $obj = "traffic-manager"
        $cmdOut =  az network traffic-manager profile show --name $tfmgrName --resource-group $GRP  | ConvertFrom-Json
        if ($null -ne $cmdOut."publishingUserName") {
            WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
        } else {
            WriteOutFile -file $file -output "$obj doesn't exist, creating"
            $cmd = az network traffic-manager profile create --name $tfmgrName `
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
        }
        WriteOutFile -file $FILE -output $cmdOut
    } else {
        WriteOutFile -file $file -output "not instructed to create"
    }
    $TRAFFICMGRS +=$tfmgrName

    foreach ($sub in $subs) {
        $locCode = $sub[1]
        $endpointName = $APP_NAME, $type, $locCode, $VER -join "-"
        $endpointName = $APP_NAME, $type, $locCode, $VER -join "-"
        $resId = "$SUBSCRIPTIONFULL$endpointName"

        WriteOutFile -file $file -output "----------------------------"
        WriteOutFile -file $file -output "creating traffic endpoint"
        WriteOutFile -file $file -output "traffic mgr: $tfmgrName"
        WriteOutFile -file $file -output "name: $endpointName"
        WriteOutFile -file $file -output "geo-mapping: $($sub[3])"
        WriteOutFile -file $file -output "resId: $resId"

        if ($CREATE_TRAFFICMGR) {
            $obj = "traffic-manager endpoint"
            $cmdOut =  az network traffic-manager endpoint show --name $endpointName --resource-group $GRP | ConvertFrom-Json
            if ($null -ne $cmdOut."publishingUserName") {
                WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
            } else {
                WriteOutFile -file $file -output "$obj doesn't exist, creating"
                $cmdOut = az network traffic-manager endpoint create --name $endpointName --profile-name $tfmgrName --resource-group $GRP `
                        --type azureEndpoints --always-serve Disabled --target-resource-id $resId --target '$endpointName.azurewebsites.net'
            }
            WriteOutFile -file $FILE -output $cmdOut
            
                            # --geo-mapping $($sub[3]) `
        } else {
            WriteOutFile -file $file -output "not instructed to create"
        }

    }
}


if ($CREATE_APPGW) {

    # override
    # $VER = "210"

    $location = $subs[0][1]
    $appGWName = "tyrell", "appgw", $VER -join "-"
    $vnetName = "tyrell", "appgw", "vnet", $VER -join "-"
    $vnetPrefix = "$CIDR_PREFIX.0.0/16"
    $subnetName = "tyrell", "appgw", "subnet", $VER -join "-"
    $subnetPrefix = "$CIDR_PREFIX.230.0/24"
    $publicIpName = "tyrell", "appgw", "pip", $VER -join "-"

    ## created health probe to traffic mgr dns
    ## created service endpoint on vnet
    ## change backend settings to override hostname and choose from backend pool

    # CREATE VNET
    WriteOutFile -file $file -output "****************************"
    WriteOutFile -file $file -output "Creating App Gateway"
    WriteOutFile -file $file -output "appgw: $appGWName"
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating vnet & subnet"
    WriteOutFile -file $file -output "vnet: $vnetName, cidr: $vnetPrefix"
    WriteOutFile -file $file -output "subnet: $subnetName, cidr $subnetPrefix"
    
    $obj = "appgw vnet"
    $cmdOut =  az network vnet create show -g $GRP --location $location -n $vnetName | ConvertFrom-Json
    if ($null -ne $cmdOut."publishingUserName") {
        WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
    } else {
        WriteOutFile -file $file -output "$obj doesn't exist, creating"
        $cmdOut = az network vnet create -g $GRP --location $location -n $vnetName --address-prefix $vnetPrefix `
                                    --subnet-name $subnetName --subnet-prefixes $subnetPrefix
    }
    WriteOutFile -file $FILE -output $cmdOut
    
    # CREATE PUBLIC IP
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating public ip"
    WriteOutFile -file $file -output "public ip name: $publicIpName"
    
    $obj = "public ip"
    $cmdOut = az network public-ip show --name $publicIpName --resource-group $GRP | ConvertFrom-Json
    if ($null -ne $cmdOut."publishingUserName") {
        WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
    } else {
        WriteOutFile -file $file -output "$obj doesn't exist, creating"
        
        $cmdOut = az network public-ip create --name $publicIpName --resource-group $GRP --location $location `
        --allocation-method Static --sku Standard
        WriteOutFile -file $FILE -output $cmdOut
        
        $cmdOut= az network public-ip show --name $publicIpName --resource-group $GRP --query '{address: ipAddress}' --output json | ConvertFrom-Json
        $pip = $cmdOut.address
    }
    WriteOutFile -file $file -output "public ip name: $pip"

    
    # CREATE APP GW
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating app gw"
    $obj = "app gww"
    $cmdOut = az network application-gateway show -g $GRP -n $appGWName | ConvertFrom-Json
    if ($null -ne $cmdOut."publishingUserName") {
        WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
    } else {
        WriteOutFile -file $file -output "$obj doesn't exist, creating"    
        $cmdOut = az network application-gateway create -g $GRP -n $appGWName --vnet-name $vnetName --subnet $subnetName `
                                    --http-settings-cookie-based-affinity Enabled --priority 100  --public-ip-address $pip --sku Standard_v2
    }
    WriteOutFile -file $FILE -output $cmdOut
    $appGW += $appGWName

    
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
    
    if ($POOL_TYPE -eq "appservice") {
        $urlSuffix = ".azurewebsites.net"
    } elseif ($POOL_TYPE -eq "trafficmgr") {
        $urlSuffix = ".trafficmanager.net"
    }

    $backendPools = @("appGatewayBackendPool", "$($TRAFFICMGRS[0])$urlSuffix"), `
    @("appGatewayBackendPool2", "$($TRAFFICMGRS[1])$urlSuffix")
    
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating back end pools"
    foreach ($bepool in $backendPools) {
        WriteOutFile -file $file -output "name: $($bepool[0])"
        WriteOutFile -file $file -output "servers: $($bepool[1])"
        
        $obj = "back end pool"
        $cmdOut = az network application-gateway address-pool show -g $GRP -n $appGWName --name $bepool[0]  | ConvertFrom-Json
        if ($null -ne $cmdOut."publishingUserName") {
            WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
        } else {
            WriteOutFile -file $file -output "$obj doesn't exist, creating"          
            $cmdOut = az network application-gateway address-pool create -g $GRP --gateway-name $appGWName `
                    --name $bepool[0] --servers $bepool[1]
        }
        WriteOutFile -file $FILE -output $cmdOut
    }

    # CREATE / UPDATE PATH MAP
    $defaultBePool = 2 
    $appPathMapName = "tyrell-appgw-pathmap"
    $defaultHttpSettings1 = $backendHttpSettings1
    $pathmaps = @("/images/*", "appGatewayBackendPool", "appGatewayBackendHttpSettings"), `
                @("/blog/*", "appGatewayBackendPool2", "appGatewayBackendHttpSettings")

    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating path map"
    
    foreach ($pathmap in $pathmaps) {
        $obj = "url path map"
        $cmdOut = az network application-gateway url-path-map create --resource-group $GRP --gateway-name $appGWName --name $appPathMapName  | ConvertFrom-Json
        
        if ($null -ne $cmdOut."publishingUserName") {
            WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
        } else {
            WriteOutFile -file $file -output "$obj doesn't exist, creating"          
            $cmdOut = az network application-gateway url-path-map create --resource-group $GRP --gateway-name $appGWName `
                --name $appPathMapName --paths $pathmap[0] `
                --address-pool $pathmap[1] --http-settings  $pathmap[2] `
                --default-address-pool $pathmap[1] --default-http-settings  $pathmap[2]
            WriteOutFile -file $FILE -output $cmdOut
        }
    }

     # CREATE RULE FOR ROUTING
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating rule"
    $gwRule = "rule1"
    $appGWListener = "appGatewayHttpListener"
    
    $obj = "gateway rule"
    $cmdOut = az network application-gateway rule update --resource-group $GRP --gateway-name $appGWName --name $gwRule  | ConvertFrom-Json
    
    if ($null -ne $cmdOut."publishingUserName") {
        WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
    } else {
        WriteOutFile -file $file -output "$obj doesn't exist, creating"       
        $cmdOut = az network application-gateway rule update --resource-group $GRP --gateway-name $appGWName `
        --name $gwRule --priority 99 --http-listener $appGWListener --rule-type PathBasedRouting `
        --address-pool $backendPools[$defaultBePool] --http-settings $defaultHttpSettings1 `
        --url-path-map $appPathMapName
    }
    WriteOutFile -file $FILE -output $cmdOut
    # $sp = 'az network application-gateway rule create --gateway-name $appGWName --resource-group $GRP --name $ruleName --http-listener $listenerName --rule-type PathBasedRoutingRule --backend-address-pool "backendPool"'
    
    
    # UPDATE BACKEND SETTINGS
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating http settings"
    $obj = "gateway rule"
    $cmdOut = az network application-gateway http-settings update --gateway-name $appGWName --name appGatewayBackendHttpSettings --resource-group $GRP  | ConvertFrom-Json
    if ($null -ne $cmdOut."publishingUserName") {
        WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
    } else {
        WriteOutFile -file $file -output "$obj doesn't exist, creating"          
        $cmdOut = az network application-gateway http-settings update --gateway-name $appGWName --name appGatewayBackendHttpSettings `
                                --resource-group $GRP --host-name-from-backend-pool true --path '/' --port 80
    }
    WriteOutFile -file $FILE -output $cmdOut

    # UPDATE HEALTH PROBE
    # add health probe - not added for app-gateway creation
    # https://learn.microsoft.com/en-us/cli/azure/network/application-gateway/probe?view=azure-cli-latest#az-network-application-gateway-probe-create
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating http probe"
    $healthProbeName = "tyrell-appgw-health-probe-001"

    $obj = "gateway rule"
    $cmdOut = az network application-gateway probe create --resource-group $GRP --gateway-name $appGWName --name $healthProbeName  | ConvertFrom-Json
    if ($null -ne $cmdOut."publishingUserName") {
        WriteOutFile -file $file -output "$obj exists: $($cmdOut."publishingUserName")"
    } else {
        WriteOutFile -file $file -output "$obj doesn't exist, creating"         
        $cmdOut = az network application-gateway probe create --resource-group $GRP --gateway-name $appGWName `
                    --name $healthProbeName `
                    --port 80 --path '/'
                    # --pickHostNameFromBackendHttpSettings true `
                    # --from-settings true `
    }
    WriteOutFile -file $FILE -output $cmdOut
   
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

# $pln = "tyrell-images-" + $VER 
# $APP_NAME = "web-app-imgs-asia-" + $VER

# $pln2 = "ronnie-sp-" + $VER + "2" 
# $APP_NAME2 = "demoes-videos-ronnie-" + $VER + "1"

# $obj = "Service Plan"
# Write-Output "[$obj] Checking $obj"
# .\az-commands\az-service-plan.ps1 $GRP $loc $pln2 $sub
# Write-Output "[$obj] Finished"

# $obj = "Web App"
# Write-Output "[$obj] Checking $obj"
# .\az-commands\az-web-app.ps1 $GRP $pln $APP_NAME2 $sub
# Write-Output "[$obj] Finished"

# vNET
# $obj = "VNET"
# Write-Output "[$obj] Checking $obj"
# .\az-commands\az-network-vnet.ps1 $GRP $vnetName $vnetPrefix $subnetName $subnetIP
# Write-Output "[$obj] Finished"



# [--public-network-access {Disabled, Enabled}]
# [--runtime]
# [--subnet]
# [--tags]
# [--vnet]

# $sub = "Simplilearn HOL 42"
# $loc = "eastus"
# $GRP = "ronnie-rg-" + $VER + "1"

# $appGatewayName = "app-gateway-" + $VER + "1"
# $frontendIPName = "pip-app-gw-" + $VER + "1"
# $httpListenerName = "http-listener-" + $VER + "1"
# $ruleName = "http-rule-" + $VER + "1"
# $publicIpName = "ronnie-ip-std-" + $VER + "1"


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