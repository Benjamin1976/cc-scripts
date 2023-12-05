
$vpcId = $args[0]
$subnets = $args[1]

# rules 
$obj = "Subnets"
Write-Output "[$obj] Reading $obj"
$subnetIds = @()
$json = aws ec2 describe-subnets  --filters "Name=vpc-id,Values=$vpcId" | ConvertFrom-Json
$json.Subnets | ForEach-Object {
    Write-Output "subnet: $($_.SubnetId)"
    Write-Output "location: $($_.CidrBlock)"
    Write-Output "az: $($_.AvailabilityZone)"
    $subnetId = $_.SubnetId
    $subnetIds += $subnetId
    Write-Output "Added to list: $subnetId"
}
Write-Output "[$obj] Read all subnets"

return $subnetIds

# {
#     "Subnets": [
#         {
#             "AvailabilityZone": "us-east-1d",
#             "AvailabilityZoneId": "use1-az2",
#             "AvailableIpAddressCount": 4089,
#             "CidrBlock": "172.31.80.0/20",
#             "DefaultForAz": true,
#             "MapPublicIpOnLaunch": true,
#             "MapCustomerOwnedIpOnLaunch": false,
#             "State": "available",
#             "SubnetId": "subnet-8EXAMPLE",
#             "VpcId": "vpc-3EXAMPLE",
#             "OwnerId": "1111222233333",
#             "AssignIpv6AddressOnCreation": false,
#             "Ipv6CidrBlockAssociationSet": [],
#             "Tags": [
#                 {
#                     "Key": "Name",
#                     "Value": "MySubnet"
#                 }
#             ],
#             "SubnetArn": "arn:aws:ec2:us-east-1:111122223333:subnet/subnet-8EXAMPLE",
#             "EnableDns64": false,
#             "Ipv6Native": false,
#             "PrivateDnsNameOptionsOnLaunch": {
#                 "HostnameType": "ip-name",
#                 "EnableResourceNameDnsARecord": false,
#                 "EnableResourceNameDnsAAAARecord": false
#             }
#         }
#     ]
# }