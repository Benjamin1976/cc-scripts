# Define variables
$resourceGroupName = "AppGatewayPSDemo"
$appServicePlanName = "WebAppServicePlan"
$webApp1Name = "web-app-01"
$webApp2Name = "web-app-02"
$location = "eastus"
$appGatewayName = "app-gateway-01"
$frontendIPName = "pip-app-gw-01"
$httpListenerName = "http-listener"
$ruleName = "http-rule-01"
$publicIpName = "YourPublicIpName"

# Create a public IP address
az network public-ip create --name $publicIpName --resource-group $resourceGroupName --location $location --allocation-method Static

# Read the created public IP into a variable
$publicIpInfo = az network public-ip show --name $publicIpName --resource-group $resourceGroupName --query "{address: ipAddress}" --output json | ConvertFrom-Json
$publicIpAddress = $publicIpInfo.address

# Use $publicIpAddress in other commands
Write-Host "The public IP address is: $publicIpAddress"

# ...

# The rest of your script (health probe, VNet, service endpoint, and backend settings)



# Create a new resource group
az group create --name $resourceGroupName --location $location

# Create an App Service Plan
az appservice plan create --name $appServicePlanName --resource-group $resourceGroupName --sku S1 --location $location

# Create the first Web App
az webapp create --name $webApp1Name --resource-group $resourceGroupName --plan $appServicePlanName --runtime "DOTNET|5.0"

# Create the second Web App
az webapp create --name $webApp2Name --resource-group $resourceGroupName --plan $appServicePlanName --runtime "DOTNET|5.0"

# Create a public IP address
az network public-ip create --name $publicIpName --resource-group $resourceGroupName --location $location --allocation-method Static

# Create an Application Gateway
az network application-gateway create --name $appGatewayName --resource-group $resourceGroupName --location $location --capacity 2 --sku WAF_v2

# Create a frontend IP configuration
az network application-gateway frontend-ip create --name $frontendIPName --gateway-name $appGatewayName --resource-group $resourceGroupName --public-ip-address ""

# Create an HTTP listener
az network application-gateway http-listener create --name $httpListenerName --frontend-ip $frontendIPName --frontend-port 80 --resource-group $resourceGroupName --gateway-name $appGatewayName --rule-name ""

# Define a backend address pool
az network application-gateway address-pool create --gateway-name $appGatewayName --resource-group $resourceGroupName --name "backendPool" --servers $webApp1Name $webApp2Name

# Create a request routing rule
az network application-gateway rule create --gateway-name $appGatewayName --resource-group $resourceGroupName --name $ruleName --http-listener $httpListenerName --rule-type PathBasedRoutingRule --backend-address-pool "backendPool"


# ...

# Create a health probe
az network application-gateway probe create --gateway-name $appGatewayName --resource-group $resourceGroupName --name "healthProbe" --protocol Http --host "yourwebsite.com" --path "/health" --interval 30 --threshold 2
az network application-gateway probe create --gateway-name $appGatewayName --resource-group $resourceGroupName --name "healthProbe" --protocol Http --host "yourwebsite.com" --path "/health" --interval 30 --threshold 2

# Get information about the Virtual Network
$vnetInfo = az network vnet show --name YourVNetName --resource-group $resourceGroupName

# Create a service endpoint on the Virtual Network
az network vnet subnet update --resource-group $resourceGroupName --vnet-name YourVNetName --name YourSubnetName --service-endpoints "Microsoft.Web"

# Override the backend HTTP settings
az network application-gateway http-settings update --gateway-name $appGatewayName --resource-group $resourceGroupName --name "YourHttpSettings" --host-name-from-backend-pool
