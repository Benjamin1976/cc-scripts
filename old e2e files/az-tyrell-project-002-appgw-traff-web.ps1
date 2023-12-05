

$SUBSCRIPTION = "c0de6865-a88e-448b-b905-781909aee251"
$VER = "026"

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

$ADMIN_USER = "benjamin"
$ADMIN_PASSWORD = "benjamin_123"
$deployUser = "$GRP-benjammin-deploy-76"
$deployPass = "benjamin_123"

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

# az webapp list-rusntimes
CheckLogFile -file $FILE -$output "Creating for AZ305-Project-02"
$cmdOut = ""
$CREATE_TYPE = "appservices"  # "appservices" | "vmss"
$CREATE_RG = $true
$CREATE_VMSS = $true
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

    $cmdOut = az group create --location $GRP_LOC --name $GRP | ConvertFrom-Json
    WriteOutFile -file $FILE -output $cmdOut

    $cmdOut = az webapp deployment user set --user-name $deployUser --password $deployPass | ConvertFrom-Json
    WriteOutFile -file $FILE -output $cmdOut
}

# CREATE MACHINE SCALE SETS
if ($CREATE_TYPE -eq "vmss") {
    foreach ($sub in  $subs) {
        foreach ($type in  $types) {

            $location = $sub[0]
            $locCode = $sub[1]
            $vnetName = "tyrell", $type, "vnet", $locCode, $VER -join "-"
            $vnetPrefix = $CIDR_PREFIX + ".0.0/16"
            $subnetName = "tyrell", $type, "subnet", $locCode, $VER -join "-"
            $subnetPrefix = $CIDR_PREFIX + "." + $sub[2] + ".0/24"
            
            WriteOutFile -file $file -output "****************************"
            WriteOutFile -file $file -output "Creating Machine Scale Sets"
            WriteOutFile -file $file -output "----------------------------"
            WriteOutFile -file $file -output "creating vnet & subnet"
            WriteOutFile -file $file -output "vnet: $vnetName, $vnetPrefix"
            WriteOutFile -file $file -output "subnet: $subnetName, $subnetPrefix"
            WriteOutFile -file $file -output "location: $location"

            
            if ($CREATE_APP_SERVICE) {
                WriteOutFile -file $file -output "$obj doesn't exist, creating"            
                $cmdOut = az network vnet create -g $GRP --location $location -n $vnetName --address-prefix $vnetPrefix --subnet-name $subnetName --subnet-prefixes $subnetPrefix | ConvertFrom-Json
                # $cmdOut.newVNet.name
                # $cmdOut.newVNet.id
                WriteOutFile -file $FILE -output $cmdOut
            } else {
                WriteOutFile -file $file -output "not instructed to create"
            }
        
            # Add-Content -Path $FILE -Value $sp

            $web_app_name = $APP_NAME, $type, $locCode, $VER -join "-"

            WriteOutFile -file $file -output "----------------------------"
            WriteOutFile -file $file -output "creating machine scale set"
            WriteOutFile -file $file -output "web app: $web_app_name"
            WriteOutFile -file $file -output "service vnet: $vnetName"
            WriteOutFile -file $file -output "service sub: $subnetName"
            WriteOutFile -file $file -output "runtime: $RUNTIME"
            
            if ($CREATE_VMSS) {
                $cmdOut = az vmss create `
                        --resource-group $GRP `
                        --name $web_app_name `
                        --image $RUNTIME `
                        --upgrade-policy-mode automatic `
                        --admin-username azureuser `
                        --generate-ssh-keys

                # $cmdOut = az webapp create --resource-group $GRP --name $web_app_name --plan $sp_plan --vnet $vnetName `
                #                         --subnet $subnetName --public-network-access Enabled --runtime $RUNTIME --deployment-local-git
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
}

# CREATE SERVICE PLAN & WEB APPS
if ($CREATE_TYPE -eq "appservices") {
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
                $cmdOut = az network vnet create -g $GRP --location $location -n $vnetName --address-prefix $vnetPrefix --subnet-name $subnetName --subnet-prefixes $subnetPrefix | ConvertFrom-Json
                # $cmdOut.newVNet.name
                # $cmdOut.newVNet.id
                WriteOutFile -file $FILE -output $cmdOut
            } else {
                WriteOutFile -file $file -output "not instructed to create"
            }

            $sp_plan = $SP_NAME, $type, $locCode, $VER  -join "-"
            $web_app_name = $APP_NAME, $type, $locCode, $VER -join "-"

            WriteOutFile -file $file -output "----------------------------"
            WriteOutFile -file $file -output "creating service plan"
            WriteOutFile -file $file -output "service plan: $sp_plan"
            WriteOutFile -file $file -output "service loc: $($location)"
            
            if ($CREATE_APP_SERVICE) {
                $cmd= az appservice plan create --name $sp_plan --resource-group $GRP --location $location --sku S1
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
                $cmdOut = az webapp create --resource-group $GRP --name $web_app_name --plan $sp_plan --vnet $vnetName `
                                        --subnet $subnetName --public-network-access Enabled --runtime $RUNTIME --deployment-local-git
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
                $cmdOut = az webapp deployment source config-local-git --name $cmdOut --resource-group $GRP | ConvertFrom-Json
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
            $cmdOut = az network traffic-manager endpoint create --name $endpointName --profile-name $tfmgrName --resource-group $GRP `
                        --type azureEndpoints --always-serve Disabled --target-resource-id $resId --target '$endpointName.azurewebsites.net'
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

    
    WriteOutFile -file $file -output "****************************"
    WriteOutFile -file $file -output "Creating App Gateway"
    WriteOutFile -file $file -output "appgw: $appGWName"
    
    # CREATE VNET
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating vnet & subnet"
    WriteOutFile -file $file -output "vnet: $vnetName, cidr: $vnetPrefix"
    WriteOutFile -file $file -output "subnet: $subnetName, cidr $subnetPrefix"  
    $cmdOut = az network vnet create -g $GRP --location $location -n $vnetName --address-prefix $vnetPrefix `
                                --subnet-name $subnetName --subnet-prefixes $subnetPrefix
    WriteOutFile -file $FILE -output $cmdOut
    
    # CREATE PUBLIC IP
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating public ip"
    WriteOutFile -file $file -output "public ip name: $publicIpName"
    $cmdOut = az network public-ip create --name $publicIpName --resource-group $GRP --location $location `
    --allocation-method Static --sku Standard
    WriteOutFile -file $FILE -output $cmdOut
    $cmdOut= az network public-ip show --name $publicIpName --resource-group $GRP --query '{address: ipAddress}' --output json | ConvertFrom-Json
    $pip = $cmdOut.address
    WriteOutFile -file $file -output "public ip name: $pip"

    
    # CREATE APP GW
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating app gw"
    WriteOutFile -file $file -output "$obj doesn't exist, creating"    
    $cmdOut = az network application-gateway create -g $GRP -n $appGWName --vnet-name $vnetName --subnet $subnetName `
                                --http-settings-cookie-based-affinity Enabled --priority 100  --public-ip-address $pip --sku Standard_v2
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
        $cmdOut = az network application-gateway address-pool create -g $GRP --gateway-name $appGWName `
                --name $bepool[0] --servers $bepool[1]
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
        $cmdOut = az network application-gateway url-path-map create --resource-group $GRP --gateway-name $appGWName `
                --name $appPathMapName --paths $pathmap[0] `
                --address-pool $pathmap[1] --http-settings  $pathmap[2] `
                --default-address-pool $pathmap[1] --default-http-settings  $pathmap[2]
        WriteOutFile -file $FILE -output $cmdOut

    }

     # CREATE RULE FOR ROUTING
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating rule"
    $gwRule = "rule1"
    $appGWListener = "appGatewayHttpListener"
    $cmdOut = az network application-gateway rule update --resource-group $GRP --gateway-name $appGWName `
        --name $gwRule --priority 99 --http-listener $appGWListener --rule-type PathBasedRouting `
        --address-pool $backendPools[$defaultBePool] --http-settings $defaultHttpSettings1 `
        --url-path-map $appPathMapName
    WriteOutFile -file $FILE -output $cmdOut
    # $sp = 'az network application-gateway rule create --gateway-name $appGWName --resource-group $GRP --name $ruleName --http-listener $listenerName --rule-type PathBasedRoutingRule --backend-address-pool "backendPool"'
    
    
    # UPDATE BACKEND SETTINGS
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating http settings"         
    $cmdOut = az network application-gateway http-settings update --gateway-name $appGWName --name appGatewayBackendHttpSettings `
        --resource-group $GRP --host-name-from-backend-pool true --path '/' --port 80
    WriteOutFile -file $FILE -output $cmdOut

    # UPDATE HEALTH PROBE
    # add health probe - not added for app-gateway creation
    # https://learn.microsoft.com/en-us/cli/azure/network/application-gateway/probe?view=azure-cli-latest#az-network-application-gateway-probe-create
    WriteOutFile -file $file -output "----------------------------"
    WriteOutFile -file $file -output "creating http probe"
    $healthProbeName = "tyrell-appgw-health-probe-001"         
    $cmdOut = az network application-gateway probe create --resource-group $GRP --gateway-name $appGWName `
                --name $healthProbeName `
                --port 80 --path '/'
                # --pickHostNameFromBackendHttpSettings true `
                # --from-settings true `
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
