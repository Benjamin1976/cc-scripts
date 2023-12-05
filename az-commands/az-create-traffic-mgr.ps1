. .\az-commands\general.ps1

$rg = "trafficmgr-rg"
$trafficMgr = "trafficmgr-test-ben-priority-005"
$endpoints = @("trafficmgr-web-app-sg-001", 10), @("trafficmgr-web-app-us-001", 100), @("trafficmgr-web-app-au-001", 20)

Write-Log -level ERROR -message "String failed to be a string"


$service = "Traffic Manager"
opHeader "start" $service
az network traffic-manager profile create `
            --name $trafficMgr `
            --resource-group $rg `
            --routing-method Priority `
            --unique-dns-name $trafficMgr
opHeader "finish" $service

$sp = az network traffic-manager profile show `
            --name $trafficMgr `
            --resource-group $rg `

if ($null -ne $sp) {
    Write-Output "$service exists."
} else {
    Write-Output "$service doesn't exist, exiting"
    Exit
}


$service = "Endpoints"
opHeader "start" $service
$endpoints | ForEach-Object {
    $service = "Endpoint: "
    
    opHeader "start" $service
    Write-Output "endpoint: $($_[0]) with priority: $($_[1])"
    # Write-Output "endpointURL: $($_[0]).azurewebsites.net"
    # Write-Output "priority: $($_[1])"
    az network traffic-manager endpoint create --name $_[0] `
                        --profile-name $trafficMgr `
                        --resource-group $rg `
                        --type "azureEndpoints" `
                        --always-serve "Disabled" `
                        --priority $_[1] `
                        --target "$($_[0]).azurewebsites.net" `
                        --target-resource-id "/subscriptions/9f7feb4a-439a-4294-ab43-1450f2dc7a38/resourceGroups/trafficmgr-rg/providers/Microsoft.Web/sites/$($_[0])"
    Write-Output "-------Creating $service---------"                }
    opHeader "finish" $service
Exit
opHeader "finish" "Endpoints"