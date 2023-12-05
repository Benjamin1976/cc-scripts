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

# Define the log file path with date and time
$logFileName = Get-Date -Format "yyyyMMddHHmmss"
$logFilePath = "deployment_log_$logFileName.txt"

# Create or append to the log file
$null >> $logFilePath

# Function to execute a command and log the output
function ExecuteAndLogCommand {
    param(
        [string]$command
    )
    $commandOutput = Invoke-Expression $command
    $commandOutput | Out-File -Append -FilePath $logFilePath
}

# Check if the resource group exists, if not, create it
$rgExists = az group show --name $resourceGroupName --query "name" --output tsv
if (-not $rgExists) {
    ExecuteAndLogCommand "az group create --name $resourceGroupName --location $location"
}

# Check if the App Service Plan exists, if not, create it
$appServicePlanExists = az appservice plan show --name $appServicePlanName --resource-group $resourceGroupName --query "name" --output tsv
if (-not $appServicePlanExists) {
    ExecuteAndLogCommand "az appservice plan create --name $appServicePlanName --resource-group $resourceGroupName --sku S1 --location $location"
}

# Check if the first Web App exists, if not, create it
$webApp1Exists = az webapp show --name $webApp1Name --resource-group $resourceGroupName --query "name" --output tsv
if (-not $webApp1Exists) {
    ExecuteAndLogCommand "az webapp create --name $webApp1Name --resource-group $resourceGroupName --plan $appServicePlanName --runtime 'DOTNET|5.0'"
}

# Check if the second Web App exists, if not, create it
$webApp2Exists = az webapp show --name $webApp2Name --resource-group $resourceGroupName --query "name" --output tsv
if (-not $webApp2Exists) {
    ExecuteAndLogCommand "az webapp create --name $webApp2Name --resource-group $resourceGroupName --plan $appServicePlanName --runtime 'DOTNET|5.0'"
}

# Check if the Application Gateway exists, if not, create it
$appGatewayExists = az network application-gateway show --name $appGatewayName --resource-group $resourceGroupName --query "name" --output tsv
if (-not $appGatewayExists) {
    ExecuteAndLogCommand "az network application-gateway create --name $appGatewayName --resource-group $resourceGroupName --location $location --capacity 2 --sku WAF_v2"
}

# Check if the frontend IP configuration exists, if not, create it
$frontendIPExists = az network application-gateway frontend-ip show --name $frontendIPName --gateway-name $appGatewayName --resource-group $resourceGroupName --query "name" --output tsv
if (-not $frontendIPExists) {
    ExecuteAndLogCommand "az network application-gateway frontend-ip create --name $frontendIPName --gateway-name $appGatewayName --resource-group $resourceGroupName --public-ip-address ''"
}

# Check if the HTTP listener exists, if not, create it
$httpListenerExists = az network application-gateway http-listener show --name $httpListenerName --frontend-ip $frontendIPName --frontend-port 80 --resource-group $resourceGroupName --gateway-name $appGatewayName --query "name" --output tsv
if (-not $httpListenerExists) {
    ExecuteAndLogCommand "az network application-gateway http-listener create --name $httpListenerName --frontend-ip $frontendIPName --frontend-port 80 --resource-group $resourceGroupName --gateway-name $appGatewayName --rule-name ''"
}

# Define a backend address pool
ExecuteAndLogCommand "az network application-gateway address-pool create --gateway-name $appGatewayName --resource-group $resourceGroupName --name 'backendPool' --servers $webApp1Name $webApp2Name"

# Check if the routing rule exists, if not, create it
$ruleExists = az network application-gateway rule show --name $ruleName --gateway-name $appGatewayName --resource-group $resourceGroupName --query "name" --output tsv
if (-not $ruleExists) {
    ExecuteAndLogCommand "az network application-gateway rule create --gateway-name $appGatewayName --resource-group $resourceGroupName --name $ruleName --http-listener $httpListenerName --rule-type PathBasedRoutingRule --backend-address-pool 'backendPool'"
}
