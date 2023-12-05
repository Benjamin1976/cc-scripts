$groupName = $args[0]
$groupDesc = $args[1]
$subnetIds = $args[2]
$subnetList = New-Object Collections.Generic.List[String]
$subnetIds  | ForEach-Object {$subnetList.Add($_)}
$subnetList
Exit

# rules 
$obj = "Subnet Group"
Write-Output "[$obj] Creating $obj"

Write-Output "-------Creating Group---------"
Write-Output "name: $groupName"
Write-Output "desc: $groupDesc"
Write-Output "subnets: $subnetIdsString"

$json = aws rds create-db-subnet-group `
        --db-subnet-group-name $groupName `
        --db-subnet-group-description $groupDesc `
        --subnet-ids $subnetList | ConvertFrom-Json
$json
$subnetGroupArn = $json.DBSubnetGroup.DBSubnetGroupArn
Write-Output "[$obj] Created: $subnetGroupArn"

return $subnetGroupArn

# {
#     "DBSubnetGroup": {
#         "DBSubnetGroupName": "subnetgroup2",
#         "DBSubnetGroupDescription": "subnetgroup2",
#         "VpcId": "vpc-0f11c718a52403578",
#         "SubnetGroupStatus": "Complete",
#         "Subnets": [
#             {
#                 "SubnetIdentifier": "subnet-01444aeb3aa04fa8f",
#                 "SubnetAvailabilityZone": {
#                     "Name": "us-east-1a"
#                 },
#                 "SubnetOutpost": {},
#                 "SubnetStatus": "Active"
#             },
#             {
#                 "SubnetIdentifier": "subnet-041e26797b328dba4",
#                 "SubnetAvailabilityZone": {
#                     "Name": "us-east-1b"
#                 },
#                 "SubnetOutpost": {},
#                 "SubnetStatus": "Active"
#             }
#         ],
#         "DBSubnetGroupArn": "arn:aws:rds:us-east-1:946229218607:subgrp:subnetgroup2"
#     }
# }