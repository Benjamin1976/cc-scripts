
Write-Output "reading variables"

$vpcId = $args[0]
$subnets = $args[1]

# rules 
$obj = "Subnets"
Write-Output "[$obj] Creating $obj"
# $subnetIds = @()
$subnetIds = New-Object Collections.Generic.List[String]
$subnets | ForEach-Object {
    Write-Output "-------Creating Subnet---------"
    Write-Output "subnet: $($_[0])"
    Write-Output "location: $($_[1])"
    Write-Output "cidr: $($_[2])"
    $json = aws ec2 create-subnet --vpc-id $vpcId --cidr-block $_[2] `
         --availability-zone $_[1] `
         --tag-specification ResourceType=subnet,Tags=["{Key=Name, Value=""$($_[0])-$($_[1])""}"] | ConvertFrom-Json
    $subnetId = $json.Subnet.SubnetId
    $subnetIds.Add($subnetId)
    Write-Output "Created Subnet: $subnetId"
}
Write-Output "[$obj] Finshed $obj"

return $subnetIds


# {
#     "Subnet": {
#         "AvailabilityZone": "us-east-1b",
#         "AvailabilityZoneId": "use1-az4",
#         "AvailableIpAddressCount": 251,
#         "CidrBlock": "10.2.10.0/24",
#         "DefaultForAz": false,
#         "MapPublicIpOnLaunch": false,
#         "State": "available",
#         "SubnetId": "subnet-045d9b87af09e3689",
#         "VpcId": "vpc-0f11c718a52403578",
#         "OwnerId": "946229218607",
#         "AssignIpv6AddressOnCreation": false,
#         "Ipv6CidrBlockAssociationSet": [],
#         "Tags": [
#             {
#                 "Key": "Name",
#                 "Value": "rds-subnet-us-east-1b"
#             }
#         ],
#         "SubnetArn": "arn:aws:ec2:us-east-1:946229218607:subnet/subnet-045d9b87af09e3689",
#         "EnableDns64": false,
#         "Ipv6Native": false,
#         "PrivateDnsNameOptionsOnLaunch": {
#             "HostnameType": "ip-name",
#             "EnableResourceNameDnsARecord": false,
#             "EnableResourceNameDnsAAAARecord": false
#         }
#     }
# }