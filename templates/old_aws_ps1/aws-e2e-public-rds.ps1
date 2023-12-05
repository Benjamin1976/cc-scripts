# AKIAWFGLKRXCNQZ4YLGA
# TPm3Y2bKpyRYIpPed20Y4bViXfUDyfM0TQMHJHLi

$vpcName = "rds-script-test-007"
$vpcCidr = "10.7.0.0/16"

# subnet variables
$vpcCidrPre = "10.7."
$vpcCidrSuf = ".0/24"
$subnetNamePre = "rds-subnet"
# $subnets = @($subnetNamePre, "us-east-1a", "1"), @($subnetNamePre, "us-east-1b", "2"), @($subnetNamePre, "us-east-1c", "3"), @($subnetNamePre, "us-east-1d", "4"), @($subnetNamePre, "us-east-1e", "5"), @($subnetNamePre, "us-east-1f", "6")
$subnets = @($subnetNamePre, "us-east-1a", "1"), @($subnetNamePre, "us-east-1b", "2")
$subnets | ForEach-Object {$_[2] = $vpcCidrPre +  $_[2] + $vpcCidrSuf}
# $subnets = @("rds-subnet", "us-east-1a", "13"), @("rds-subnet", "us-east-1b", "14")

# subnet group name
$groupName = "rds-subnet-grp-007"
$groupDesc = "subnet group for rds server"

# internet gateway name
$igwName = "igw-rds-007"

# security group name
$sgName = "rds-sg-007"
$sgDesc = "security group for rds db"
# my computer IP for connectivity
$myIp = "218.212.131.143/32"

# rds Details
$rdsName = "rds-db-script-007"
$rdsInstance = "db.t3.micro"
# $dbEngine = "mysql"
$dbEngine = "sqlserver-ee"
$dbSubnetGroup = $groupName
$dbSecurityGroups = $sgName
$username = "admin"
$password = "benjamin_123"


# check if to create
$createVPC = $true
$createSubnet = $true
$createSubnetGroup = $true
$createIGW = $true
$createRouteTbl = $true
$createSecurityGroup = $true
$createRDSdb = $true


# vpc - enable hostname and resolution
if ($createVPC -eq $true) {
    Write-Output "Creating VPC"
    # $vpcId = .\aws-vpc.ps1 $vpcName $vpcCidr
    Write-Output "****************"
    $vpcId = python aws-return-test.py $vpcName $vpcCidr
    Write-Output "****************"
    $vpcId
    Write-Output "****************"
} else {
    Write-Output "Skipping VPC"
    $vpcId = "vpc-02b526429610a60c4"
}


# Write-Output "Creating VPC"
# $vpcId = .\aws-return-test.ps1 $vpcName $vpcCidr
# Write-Output "****************"
# $vpcId
# Write-Output "****************"



Exit

# delete
# subnets
if ($createSubnet -eq $true) {
    Write-Output "Creating Subnet"
    # $subnetIds = .\aws-subnet.ps1 $vpcId $subnets
    . .\aws-subnet.ps1
    $subnetIds = createSubnets $vpcId $subnets
    # $subnetIds
    # $subnetIds = .\aws-subnet.ps1 $vpcId $subnets
    Write-Output "---------subnets"
    $subnetIds[-1]
    Write-Output "---------count"
    $subnetIds.Count 
    Write-Output "---------list"
    $subnetIds | ForEach-Object {"Subnet: $PSItem"}
    # .\aws-subnet-read.ps1 $vpcId $subnets
    Write-Output "Creating Subnet done"
} else {
    Write-Output "Skipping Subnet"
    # $subnetIds = @("subnet-01444aeb3aa04fa8f", "subnet-041e26797b328dba4")
}
Exit

# rds subnet group
if ($createSubnetGroup -eq $true) {
    Write-Output "Creating Subnet Group"
    $subnetGroupId = .\aws-subnet-group.ps1 $groupName $groupDesc $subnetIds
    $subnetGroupId
} else {
    Write-Output "Skipping Subnet Group"
    # $subnetGroupId
}

# internet gateway
if ($createIGW -eq $true) {
    Write-Output "Creating IGW"
    $igwId = .\aws-internet-gateway.ps1 $igwName $vpcId
    $igwId
} else {
    Write-Output "Skipping IGW"
    $igwId = "igw-0510da662c5a26e63"
}

#  route table
if ($createRouteTbl -eq $true) {
    Write-Output "Creating Route Table"
    $routeTableId = .\aws-subnet-group.ps1 $groupName $groupDesc $subnetIds
    $routeTableId
} else {
    Write-Output "Skipping Route Table"
    # $routeTableId
}

# security group & rules
if ($createSecurityGroup -eq $true) {
    Write-Output "Creating Security Group"
    $securityGroup = .\aws-security-group.ps1 $sgName $sgDesc $subnetIds $myIp
    $securityGroup
} else {
    Write-Output "Skipping Security Group"
    $securityGroup= "sg-0e2aa8cf850166667"
}

# rds db
if ($createRDSdb -eq $true) {
    Write-Output "Creating RDS Db"
    $rdsDBArn = .\aws-create-rds-db.ps1 $rdsName $rdsInstance $dbEngine $dbSubnetGroup $securityGroup $username $password
    $rdsDBArn
} else {
    Write-Output "Skipping RDS Db"
    $rdsDBArn
}

