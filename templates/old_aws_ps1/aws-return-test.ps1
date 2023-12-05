# $vpcName = "rds-auto-test-2"
# $vpcCidr = "10.2.0.0/16"

$vpcName = $args[0]
$vpcCidr = $args[1]

# rules 
$obj = "VPC"
$subnetIds = New-Object Collections.Generic.List[String]
Write-Output "[$obj] Creating $obj"
# $json = aws ec2 create-vpc --cidr-block 10.5.0.0/16 | ConvertFrom-Json
# $json = aws ec2 create-vpc --cidr-block $vpcCidr --tag-specification ResourceType=vpc,Tags=["{Key=Name, Value=$vpcName}"]  | ConvertFrom-Json
$vpcId = Get-Random
$subnetIds.Add($vpcId)
$vpcId = Get-Random
$subnetIds.Add($vpcId)
# Write-Output $json.Vpc.VpcId
Write-Output "[$obj] Created vpc: $vpcId"


$obj = "VPC"
Write-Output "[$obj] Modifying $obj $vpcName"
# aws ec2 modify-vpc-attribute --vpc-id $vpcId --enable-dns-hostnames '{\"Value\": true}'
Write-Output "[$obj] Modifying Finished"

return $vpcId