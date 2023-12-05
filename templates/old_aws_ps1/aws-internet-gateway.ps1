$igwName = $args[0]
$vpcId = $args[1]

# rules 
$obj = "Internet Gateway"
Write-Output "[$obj] Creating $obj"

Write-Output "-------Creating Group---------"
Write-Output "name: $igwName"
Write-Output "vpc: $vpcId"

# create internet gateway
$json = aws ec2 create-internet-gateway `
        --tag-specifications ResourceType=internet-gateway,Tags=["{Key=Name, Value=$igwName}"] | ConvertFrom-Json

$igwId = $json.InternetGateway.InternetGatewayId
Write-Output "[$obj] Created: $igwId"

Write-Output "[$obj] Attaching: $igwId to $vpcId"
# attach internet gateway to vpc
$json = aws ec2 attach-internet-gateway `
        --internet-gateway-id $igwId `
        --vpc-id $vpcId 

Write-Output "[$obj] Attaching: done"

return $igwId

# {
#         "InternetGateway": {
#             "Attachments": [],
#             "InternetGatewayId": "igw-0d0fb496b3994d755",
#             "OwnerId": "123456789012",
#             "Tags": [
#                 {
#                     "Key": "Name",
#                     "Value": "my-igw"
#                 }
#             ]
#         }
#     }