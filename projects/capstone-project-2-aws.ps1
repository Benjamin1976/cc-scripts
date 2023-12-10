
$accessKey="AKIAYX5XWMN5DW3FHKUL"
$secretKey="nRH76M/4nSOopJ9Q+sT1p95kXUBBWZBKv/l/fFY2TER541Z"

# VARIABLES TO BE CHANGED BASED ON DEPLOYMENT DETAILS
$NAME_PRE = "tyrell"                        # name prefix for resources
$VMTYPE = "web"                             # vm type for vm naming
$VER = "002"                                # unique number added to end of every resource
$GRP = "cc-capstone2-$VER"                  # resource group
$PROJECT = "CAP2"                           # title for output only


$CIDR_PREFIX = "16"                         # vpc cidr prefix - 1st octet

# vpcs & locations to create
# location (full), location code for tagging resources, cidr 2nd octet, location code
$VPC = @("us-west-2", "westus", "20", "AU-VIC", "us-west-2a"), @("us-east-1", "eastus",  "10", "US-NY", "us-east-1a")
# $VPC = @("us-east-1", "eastus",  "10", "US-NY", "us-east-1a"), @("us-east-2", "eastus2", "20", "AU-VIC", "us-east-2b")
$SUBS = @("pvt", "10", "2"), @("pub", "20", "3")        # vpcs & locations to create
$GRP_LOC = $VPC[0][0]                                 # default location for RG, LBs etc.

# EC2 authentication details
$admin_user = "benjamin"                    # admin username
$admin_pass = "Benjamin_123"                # admin password - would be masked in real environment
$image =  "ami-0cd601a22ac9e6d79"           # ec2 ami - windows server 2022 base
$image =  "ami-0230bd60aa48260c6"           # ec2 ami - amazon linux
$image =  "ami-0fa1ca9559f1892ec"           # ec2 ami - amazon linux 2
$image =  "ami-0fc5d935ebf8bc3bc"           # ec2 ami - ubuntu

# Output file
$FILE = "G:\coding\envs\ps-az-setup\logs\az-creation-log-$GRP-$(get-date -f yyyy-MM-dd).txt"
$CREATE_VM = $true
$debug = $false

function WriteOutFile {
    param($file, $output, $screen)
    Add-Content -Path $FILE -Value $output
    if (($null -eq $screen) -or ($screen)) {
        Write-Host $output
    }
}

function CheckNameTag {
    param($tags, $key, $value)
    
    foreach ($tag in tags) {
        if ($tag.Key.ToUpper() -eq $key.ToUpper()) {
            if ($tag.Value.ToUpper() -eq $value.ToUpper()) {
                return $true
                break
            }
        }
    }
    return $false

}


# ************************  CREATE KEY-PAIR
$sec = "KeyPair"
$keyName = $NAME_PRE, "key", $VER -join "-"
$cmdOut = aws ec2 describe-key-pairs --filters "Name=key-name, Values=$keyName" | ConvertFrom-Json
$keyPairId = ""
if ($cmdOut.KeyPairs.Length -eq 0) {
    Write-Host "[$sec] Creating $sec"
    Write-Host "  name: $keyName"
    Write-Host "  cmd: aws ec2 describe-keypairs --filters ""Name=key-name, Values=$keyName"""
    $cmdOut = aws ec2 create-key-pair --key-name $keyName --query 'KeyMaterial' --output text >"$keyName.pem"
    $cmdOut = aws ec2 describe-key-pairs --filters "Name=key-name, Values=$keyName" | ConvertFrom-Json
}
$keyPairId = $cmdOut.KeyPairs[0].KeyPairId
Write-Host "  keyPairId: $keyPairId"



# ************************  Create Everything else

$sec = "VPC"
Write-Host "[$sec] Creating $($sec)s ($($VPC.Length))"
foreach ($vpc in $VPC) {

    # ************************  Create VPC
    $prefix2 = $vpc[2]
    $locCode = $vpc[1]
    $location = $vpc[0]
    $az = $vpc[4]
    $vpcName = $NAME_PRE, "vpc", $locCode, $VER -join "-"
    $vpcPrefix = ($CIDR_PREFIX, $prefix2, "0", "0" -join ".") + "/16"
    
    # Check VPC exists
    $sec = "VPC"
    Write-Host "[$sec] Creating $sec"
    Write-Host "  vpc: $vpcName, $vpcPrefix"
    Write-Host "  location: $location"
    if ($debug) {Write-Host "  cmd: aws ec2 describe-vpcs --filters ""Name=cidr, Values=$vpcPrefix"""}
    # $cmdOut = aws ec2 describe-vpcs --region $location `
    #         --filters "Name=cidr, Values=$vpcPrefix" | ConvertFrom-Json
    
    $cmdOut = aws ec2 describe-vpcs --region $location `
            --filters "Name=cidr, Values=$vpcPrefix" | ConvertFrom-Json
    if ($debug) {$cmdOut}

    $vpcId = ""
    $found = $false
    if ($cmdOut.Vpcs.Length -gt 0) {
        foreach ($Vpc in $cmdOut.$Vpcs) {
            $found = CheckNameTag $Vpc.Tags "Name" $vpcName
            if ($found) { break }
        }
    }

    # Create VPC if exists
    if ($found) {
        $tags = "{Key=Name, Value=$vpcName},{Key=RG, Value=$GRP}"
        $cmdOut = aws ec2 create-vpc --cidr-block $vpcPrefix `
                --region $location `
                --tag-specifications "ResourceType=vpc,Tags=[$tags]" | ConvertFrom-Json

        $cmdOut = aws ec2 describe-vpcs --region $location --filters "Name=cidr, Values=$vpcPrefix" | ConvertFrom-Json
        if ($debug) {$cmdOut}
        $vpcId = $cmdOut.Vpcs[0].VpcId
    } else {
        $vpcId = $cmdOut.Vpcs[0].VpcId
    }
    Write-Host "  vpcId: $vpcId"

    

    # ************************  Create Security Group
    $sec = "SecurityGroup"
    # $pubPvt = $sub[0]
    $sgName = $NAME_PRE, $locCode, $pubPvt, $VER -join "-"
    $sgName = $NAME_PRE, $locCode, $VER -join "-"
    
    Write-Host "[$sec] Creating $sec"
    Write-Host "  name: $sgName"
    Write-Host "  vpc-id $vpcId"
    if ($debug) {Write-Host "  cmd: aws ec2 create-security-group --group-name $sgName --vpc-id $vpcId --description ""Security group for $PROJECT"" --tag-specifications ""ResourceType=security-group,Tags=[$tags]"""}
    $tags = "{Key=Name, Value=$sgName},{Key=RG, Value=$GRP}"
    $cmdOut = aws ec2 describe-security-groups --region $location `
                    --filters "Name=group-name, Values=$sgName" `
                    --query """SecurityGroups[*].{Name:GroupName,ID:GroupId}""" | ConvertFrom-Json
    
    $sgFound = $cmdOut.Length
    if ($sgFound -ne 0) {
        $groupId = $cmdOut[0].ID
    } else {
        $cmdOut = aws ec2 create-security-group --group-name $sgName `
                    --vpc-id $vpcId `
                    --region $location `
                    --description "Security group for $PROJECT" `
                    --tag-specifications "ResourceType=security-group,Tags=[$tags]" | ConvertFrom-Json
        $groupId = $cmdOut.GroupId
    }
    Write-Host "  security groupId: $groupId"
    



    # ************************  Create Ingress Rule for HTTP
    $sec = "Ingress Rule"
    $sourceCidr = "0.0.0.0/0"
    $port = "80"
    Write-Host "[$sec] Creating $sec"
    Write-Host "  sgName: $sgName"
    Write-Host "  groupId: $groupId"
    if ($debug) {Write-Host "  cmd: aws ec2 authorize-security-group-ingress --group-name $groupId --cidr $sourceCidr --protocol tcp --port 80" }

    # $cmdOut = aws ec2 describe-security-group-rules --filters "[{""Name""=""group-id"", ""Values""=""$groupId""}, {""Name""=""vpc-id"", Values=""$vpcId""}]" | ConvertFrom-Json
    $cmdOut = aws ec2 describe-security-group-rules --filters "Name=group-id, Values=$groupId" | ConvertFrom-Json

    $ruleFound = $false
    foreach ($rule in $cmdOut.SecurityGroupRules) {
        if (($rule.CidrIpv4 -eq $sourceCidr) -and ($rule.FromPort -eq $port) -and ($rule.ToPort -eq $port) -and ($rule.IsEgress -eq $false)) {
            $ruleFound = $true
            break
        }
    }

    if ($ruleFound -eq 0) {
        $tags = "{Key=rule, Value=$sgName},{Key=RG, Value=$GRP}"
        $cmdOut = aws ec2 authorize-security-group-ingress --group-id $groupId `
                    --cidr $sourceCidr `
                    --protocol tcp `
                    --port $port | ConvertFrom-Json
                    # --tag-specifications "ResourceType=ingress-rule,Tags=[$tags]" | ConvertFrom-Json
    }
    if ($debug) {$cmdOut}


    foreach ($sub in $SUBS) {

        # ************************  Create Subnets
        $prefix3 = $sub[1]
        $subnetName = $NAME_PRE, "subnet", $sub[0], $VER -join "-"
        $subnetPrefix = ($CIDR_PREFIX, $prefix2, $prefix3, "0" -join ".") + "/24"
        
        $sec = "Subnet"
        Write-Host "[$sec] Creating $sec"
        Write-Host "  vpc: $vpcName"
        Write-Host "  subnet: $subnetName, $subnetPrefix"
     
        $cmdOut = aws ec2 describe-subnets `
            --filters "Name=vpc-id, Values=$vpcId" | ConvertFrom-Json

        $subNetFound = $false
        foreach ($sub in $cmdOut.Subnets) {
            if ($sub.CidrBlock -eq $subnetPrefix) {
                $subNetFound = $true
                $subnetId = $sub.SubnetId
                break
            }
        }

        if ($subnetFound -eq $false) {
            if ($debug) {Write-Host "  cmd: aws create-subnet --vpc-id $vpcId  --cidr-block $subnetPrefix --region $location --tag-specifications ""ResourceType=subnet,Tags=[$tags]"" | ConvertFrom-Json"}
            $tags = "{Key=Name, Value=$subnetName},{Key=RG, Value=$GRP}"
            $cmdOut = aws ec2 create-subnet --vpc-id $vpcId  `
                                    --cidr-block $subnetPrefix `
                                    --availability-zone $az `
                                    --region $location `
                                    --tag-specifications "ResourceType=subnet,Tags=[$tags]" | ConvertFrom-Json

            if ($debug) {$cmdOut}
            $subnetId = $cmdOut.Subnet.SubnetId
        }
        Write-Host "  subnetId: $subnetId"

        # if ($CREATE_VM -eq $false) {continue}
        
       
        # ************************  Create EC2s
        $vms = 1..$sub[2]
        foreach ($vm in $vms) {

            $sec = "EC2"
            $pubPvt = $sub[0]
            $vmName = $NAME_PRE, $VMTYPE, $locCode, $pubPvt, $vm -join "-"
            
            Write-Host "[$sec] Creating $sec"
            Write-Host "  name: $vmName"
            Write-Host "  subnet: $subnetName"
            Write-Host "  image: $image"
            Write-Host "  keyPair: $keyName"
            

            # $cmdOut = aws ec2 instance-exists `
            #         --filters "Name=vpc-id, Values=$vpcId" | ConvertFrom-Json

            # check if instance exists
            $cmdOut = aws ec2 describe-instances `
                    --filters "Name=vpc-id, Values=$vpcId" | ConvertFrom-Json
            $foundInst = $false
            $instanceId = ""
            if ($cmdOut.Reservations.Length -gt 0) {
                foreach ($inst in $cmdOut.Reservations) {
                    if ($inst.Instances[0].Tags.Length -gt 0) {
                        foreach ($tag in $inst.Instances[0].Tags) {
                            if ($tag.Key -eq "Name") {
                                if ($tag.Value -eq $vmName) {
                                    $foundInst = $true
                                    $instanceId = $inst.InstanceId
                                    break
                                }
                            }
                        }
                    }
                    if ($foundInst -eq $true) {break}
                }
            }


            # create if the instance doesn't exists
            if ($foundInst -eq $true) {
                Write-Host "[$sec] Found instance: $vmName"
        
            } else {
                $customData = "#!/bin/bash
                    # Use this for your user data (script from top to bottom)
                    # install httpd (Linux 2 version)  
                    sudo apt -y update
                    sudo apt install -y apache2
                    echo ""<h1>Welcome to AWS Web VM, $($vmName)</h1>"" > /var/www/html/index.html"
                    # echo ""<h1>Welcome to AWS Web VM, $(hostname): $(hostname -f)</h1>"" > /var/www/html/index.html"/

                $user_data = "userdata.txt"
                New-Item  -Name $user_data -ItemType "file" -Value $customData -Force | Out-Null
         
                $tags = "{Key=Name, Value=$vmName},{Key=RG, Value=$GRP}"
                if ($debug) {Write-Host "  cmd: aws ec2 run-instances --security-group-ids $groupId --image-id $image --subnet-id $subnetId --instance-type ""t2.micro"" --count 1 --placement ""AvailabilityZone=$az"" --key-name $keyName --user-data ""file://$user_data"" --tag-specifications ""ResourceType=ec2,Tags=[$tags]"""}
                $cmdOut = aws ec2 run-instances --security-group-ids $groupId `
                        --image-id $image `
                        --subnet-id $subnetId `
                        --instance-type "t2.micro" `
                        --count 1 `
                        --placement "AvailabilityZone=$az" `
                        --key-name $keyName `
                        --user-data "file://$user_data" `
                        --associate-public-ip-address `
                        --tag-specifications "ResourceType=instance,Tags=[$tags]" | ConvertFrom-Json


                if ($debug) {$cmdOut}
                if ($cmdOut.Instances.Length -eq 0) {
                    Write-Host "  Error creating instance"
                    $cmdOut    
                    continue
                }
                $instanceId = $cmdOut.Instances[0].InstanceId
                Write-Host "  instanceId: $instanceId"

                # ************************  Create EBS Volume
                $sec = "EBS Volume"
                $pubPvt = $sub[0]
                $vmName = $NAME_PRE, $VMTYPE, $locCode, $pubPvt, $vm -join "-"
                
                Write-Host "[$sec] Creating $sec"
                Write-Host "  az: $az"
                if ($debug) {Write-Host "  cmd: aws ec2 create-volume --volume-type gp2 --size 1 --availability-zone $az"}
    
                $cmdOut = aws ec2 create-volume --volume-type gp2 `
                            --size 1 `
                            --availability-zone $az | ConvertFrom-Json
                            
                if ($debug) {$cmdOut}
                $volumeId = $cmdOut.VolumeId
                Write-Host "  volumeId: $volumeId"
    

                # # ************************  Attach EBS Volume
                # Write-Host "[$sec] Attaching $sec"
                # Write-Host "  instance-id: $instanceId"
                # Write-Host "  volume-id: $volumeId"
                # Write-Host "  device: /dev/sdh"
                # if ($debug) {Write-Host "  cmd: aws ec2 attach-volume --device /dev/sdh --instance-id $instanceId --volume-id $volumeId"}
                # $cmdOut = aws ec2 attach-volume --device /dev/sdh --instance-id $instanceId --volume-id $volumeId
                # if ($debug) {$cmdOut}
            }

        }
    }

}

# $publicIpName = $NAME_PRE, "publicIp", $VER -join "-"

# $sec = "Public IP"
# Write-Host "[$sec] Creating $sec"
# Write-Host "  name: $publicIpName"
# Write-Host "  location: $GRP_LOC"

# # Create a public IP address
# $cmdOut = az network public-ip create --resource-group $GRP `
#         --name $publicIpName `
#         --location $GRP_LOC `
#         --allocation-method Static --sku Standard

# Write-Host "az network public-ip create --resource-group $GRP --name $publicIpName --location $GRP_LOC --allocation-method Static --sku Standard"


# # Read the created public IP into a variable
# $sp = az network public-ip show --resource-group $GRP `
#         --name $publicIpName --query "{address: ipAddress}" --output json | ConvertFrom-Json
# $publicIpAddress = $sp.address

# # add http inbound rule

# # create load balancer
# $pools = @()
# $frontEndIp = $NAME_PRE, "frontEndIp", $VER -join "-"
# $lbName = $NAME_PRE, "lb", $VER -join "-"
# $poolName = $NAME_PRE, "pool", $VER -join "-"

# $sec = "Load Balancer"
# Write-Host "[$sec] Creating $sec"
# Write-Host "  name: $publicIpName"
# Write-Host "  location: $GRP_LOC"

# $cmdOut = az network lb create --resource-group $GRP `
#     --location $GRP_LOC `
#     --name $lbName `
#     --public-ip-address $publicIpName `
#     --frontend-ip-name $frontEndIp `
#     --backend-pool-name $poolName `
#     --sku Standard

# Write-Host "az network lb create --resource-group $GRP --location $GRP_LOC --name $lbName --public-ip-address $publicIpName --frontend-ip-name $frontEndIp --backend-pool-name $poolName --sku Standard"

# Exit

# aws
# create vpc


# create ec2s

# ensure route table / security rules are setup

# create elastic load balancer

# create route 53


# manually configure domain namserver pointing
# add to namecheap first manage page to point to custom dns
# add rules to ELB & Azure Load balancer


# vpc - enable hostname and resolution
# subnets
# rds subnet group
# rds db - 
# route table
# security groups









# WriteOutFile -file $file -output "Creating Resource Group & Setting deployment user"
# WriteOutFile -file $file -output "--------------------------------------------------------"


# $cmdOut = az group create --location $GRP_LOC --name $GRP | ConvertFrom-Json
# WriteOutFile -file $FILE -output $cmdOut

# $vm1 = "cap2-az-vm-001"

# $cmdOut = az group create --resource-group $GRP --name $vm1 | ConvertFrom-Json
# WriteOutFile -file $FILE -output $cmdOut

