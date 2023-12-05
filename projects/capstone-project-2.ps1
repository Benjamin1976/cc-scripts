

$VER = "003"
$GRP = "cc-capstone2-$VER"
$NAME_PRE = "tyrell"

$FILE = "G:\coding\envs\ps-az-setup\logs\az-creation-log-$GRP-$(get-date -f yyyy-MM-dd).txt"

$SUBSCRIPTIONRES = "/subscriptions/$SUBSCRIPTION/resourceGroups/$GRP/providers/"
$SUBSCRIPTIONFULL = "/subscriptions/$SUBSCRIPTION/resourceGroups/$GRP/providers/Microsoft.Web/sites/"


$CIDR_PREFIX = "10"
$SUBS= @("australiasoutheast", "aus", "20", "AU-VIC"), @("eastus", "eastus",  "10", "US-NY")
$GRP_LOC = $SUBS[0][0]


# azure
# create rg
Write-Host "Creating RG"
$cmdOut = ""
$cmdOut = .\az-commands\az-rg-check.ps1 $GRP $GRP_LOC


# create vnet + subnet
Write-Host "VNET VARS"
$vnetName = $NAME_PRE, "vnet", $SUBS[0][1], $VER -join "-"
$vnetPrefix = ($CIDR_PREFIX, "0", "0", "0" -join ".") + "/16"

$subnetName = $NAME_PRE, "subnet", $SUBS[0][1], $VER -join "-"
$subnetPrefix = ($CIDR_PREFIX, "0", $SUBS[0][2], "0" -join ".") + "/24"

Write-Host "Creating VNET"
$cmdOut = az network vnet create -g $GRP -n $vnetName --address-prefix $vnetPrefix --subnet-name $subnetName --subnet-prefixes $subnetPrefix
$cmdOut

Exit

# create vms

    # add http inbound rule

# create load balancer


Exit

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







function WriteOutFile {
    param($file, $output, $screen)
    Add-Content -Path $FILE -Value $output
    if (($null -eq $screen) -or ($screen)) {
        Write-Host $output
    }
}


WriteOutFile -file $file -output "Creating Resource Group & Setting deployment user"
WriteOutFile -file $file -output "--------------------------------------------------------"


$cmdOut = az group create --location $GRP_LOC --name $GRP | ConvertFrom-Json
WriteOutFile -file $FILE -output $cmdOut

$vm1 = "cap2-az-vm-001"

$cmdOut = az group create --resource-group $GRP --name $vm1 | ConvertFrom-Json
WriteOutFile -file $FILE -output $cmdOut

