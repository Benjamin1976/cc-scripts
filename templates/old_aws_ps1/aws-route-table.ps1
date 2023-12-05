$vpcId = $args[0]
$igwId = $args[1]

# rules 
$obj = "Route Table"
Write-Output "[$obj] Creating $obj"
Write-Output "vpc: $vpcId"
Write-Output "igwId: $igwId"

# route table
$json = aws ec2 create-route-table --vpc-id $vpcId | ConvertFrom-Json
$routeTableId = $json.RouteTable.RouteTableId
Write-Output "[$obj] Finished $obj\: $routeTableId"

# routes - igw
$obj2 = "IGW route"
Write-Output "[$obj] Creating $obj2\: $igwId"
$json = aws ec2 create-route --route-table-id $routeTableId --destination-cidr-block 0.0.0.0/0 --gateway-id $igwId | ConvertFrom-Json
$json
Write-Output "[$obj] Finished $obj2\: $routeTableId"

Write-Output "[$obj] Created: $routeTableId"

return $routeTableId


# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-route-table.html
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-route.html


# create-route-table
# [--dry-run | --no-dry-run]
# --vpc-id <value>
# [--tag-specifications <value>]
# [--cli-input-json | --cli-input-yaml]
# [--generate-cli-skeleton <value>]
# [--debug]
# [--endpoint-url <value>]
# [--no-verify-ssl]
# [--no-paginate]
# [--output <value>]
# [--query <value>]
# [--profile <value>]
# [--region <value>]
# [--version <value>]
# [--color <value>]
# [--no-sign-request]
# [--ca-bundle <value>]
# [--cli-read-timeout <value>]
# [--cli-connect-timeout <value>]
# [--cli-binary-format <value>]
# [--no-cli-pager]
# [--cli-auto-prompt]
# [--no-cli-auto-prompt]


# {
#     "RouteTable": {
#         "Associations": [],
#         "RouteTableId": "rtb-22574640",
#         "VpcId": "vpc-a01106c2",
#         "PropagatingVgws": [],
#         "Tags": [],
#         "Routes": [
#             {
#                 "GatewayId": "local",
#                 "DestinationCidrBlock": "10.0.0.0/16",
#                 "State": "active"
#             }
#         ]
#     }
# }


# create-route
# [--destination-cidr-block <value>]
# [--destination-ipv6-cidr-block <value>]
# [--destination-prefix-list-id <value>]
# [--dry-run | --no-dry-run]
# [--vpc-endpoint-id <value>]
# [--egress-only-internet-gateway-id <value>]
# [--gateway-id <value>]
# [--instance-id <value>]
# [--nat-gateway-id <value>]
# [--transit-gateway-id <value>]
# [--local-gateway-id <value>]
# [--carrier-gateway-id <value>]
# [--network-interface-id <value>]
# --route-table-id <value>
# [--vpc-peering-connection-id <value>]
# [--core-network-arn <value>]
# [--cli-input-json | --cli-input-yaml]
# [--generate-cli-skeleton <value>]
# [--debug]
# [--endpoint-url <value>]
# [--no-verify-ssl]
# [--no-paginate]
# [--output <value>]
# [--query <value>]
# [--profile <value>]
# [--region <value>]
# [--version <value>]
# [--color <value>]
# [--no-sign-request]
# [--ca-bundle <value>]
# [--cli-read-timeout <value>]
# [--cli-connect-timeout <value>]
# [--cli-binary-format <value>]
# [--no-cli-pager]
# [--cli-auto-prompt]
# [--no-cli-auto-prompt]

# Returns true if the request succeeds; otherwise, it returns an error.