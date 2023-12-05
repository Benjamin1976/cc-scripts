$rg = "trafficmgr-rg"
$trafficMgr = "trafficmgr-test-ben-priority-001"
$endpoints = @("trafficmgr-web-app-sg-001", 100), @("trafficmgr-web-app-us-001", 50), @("trafficmgr-web-app-au-001", 70)

# foreach ($endpoint in $endpoints) {
$endpoints | ForEach-Object {
    Write-Output "-------Creating Endpoints---------"
    Write-Output "endpoint: $($_[0])"
    Write-Output "endpointURL: $($_[0]).azurewebsites.net"
    Write-Output "priority: $($_[1])"
    az network traffic-manager endpoint create --name $_[0] `
                        --profile-name $trafficMgr `
                        --resource-group $rg `
                        --type "azureEndpoints" `
                        --always-serve "Disabled" `
                        --priority $_[1] `
                        --target "$($_[0]).azurewebsites.net" `
                        --target-resource-id "/subscriptions/9f7feb4a-439a-4294-ab43-1450f2dc7a38/resourceGroups/trafficmgr-rg/providers/Microsoft.Web/sites/$($_[0])" `
}
Exit

# az network traffic-manager endpoint create --name $endpointName `
#                     --profile-name $trafficMgr `
#                     --resource-group $rg `
#                     --type "azureEndpoints" `
#                     --always-serve "Disabled" `
#                     --priority $priority `
#                     --target $endpointURL `
#                     --target-resource-id "/subscriptions/9f7feb4a-439a-4294-ab43-1450f2dc7a38/resourceGroups/trafficmgr-rg/providers/Microsoft.Web/sites/$endpointName" `

# az network traffic-manager endpoint create --name "trafficmgr-endpoint-au-001" --profile-name "trafficmgr-test-ben-priority-001" --resource-group "trafficmgr-rg"
#                                            --type {azureEndpoints, externalEndpoints, nestedEndpoints}
#                                            [--always-serve {Disabled, Enabled}]
#                                            [--custom-headers]
#                                            [--endpoint-location]
#                                            [--endpoint-monitor-status]
#                                            [--endpoint-status {Disabled, Enabled}]
#                                            [--geo-mapping]
#                                            [--min-child-endpoints]
#                                            [--min-child-ipv4]
#                                            [--min-child-ipv6]
#                                            [--priority]
#                                            [--subnets]
#                                            [--target]
#                                            [--target-resource-id]
#                                            [--weight]