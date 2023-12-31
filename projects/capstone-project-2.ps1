

# VARIABLES TO BE CHANGED BASED ON DEPLOYMENT DETAILS
$NAME_PRE = "tyrell"                        # name prefix for resources
$VMTYPE = "web"                             # vm type for vm naming
$VER = "003"                                # unique number added to end of every resource
$GRP = "cc-capstone2-$VER"                  # resource group
$PROJECT = "CAP2"                           # title for output only


$CIDR_PREFIX = "11"                         # vnet cidr prefix - 1st octet

# vnets & locations to create
# location (full), location code for tagging resources, cidr 2nd octet, location code
$VNETS = @("eastus", "eastus",  "10", "US-NY"), @("australiasoutheast", "aus", "20", "AU-VIC")
$SUBS = @("pvt", "10", "2"), @("pub", "20", "3")        # vnets & locations to create
$GRP_LOC = $VNETS[0][0]                                 # default location for RG, LBs etc.

# VM authentication details
$admin_user = "benjamin"                    # admin username
$admin_pass = "Benjamin_123"                # admin password - would be masked in real environment
$image =  "Ubuntu2204"                      # vm image

# Output file
$FILE = "G:\coding\envs\ps-az-setup\logs\az-creation-log-$GRP-$(get-date -f yyyy-MM-dd).txt"

function GetSubscription {

    $sec = "Subscription"
    Write-Host "[$sec] Creating $sec"
    $subscriptions = az account subscription list | ConvertFrom-Json
    $subscriptionId = ""
    foreach ($subscription in $subscriptions) {
        Write-Host "[$sec] Found Subscription: $subscription"
        if ($null -ne $subscription.id) {
            $subscriptionId = $subscription.id
            Write-Host "[$sec] Found Subscription: $subscriptionId"
            Break
        }
    }
    if ("" -eq $subscriptionId) {
        Write-Host "[$sec] No subscription found, exiting!"
        Exit
    }
    return $subscriptionId
}


$subscriptionId = GetSubscription
$subscriptionProvider = "$subscriptionId/resourceGroups/$GRP/providers/"
$subscriptionWeb = "$subscriptionId/resourceGroups/$GRP/providers/Microsoft.Web/sites/"


$sec = "RG"
Write-Host "[$sec] Creating RG"
Write-Host "  name: $GRP"
Write-Host "  location: $GRP_LOC"
$cmdOut = ""
$cmdout = az group create -l $GRP_LOC -n $GRP | ConvertFrom-Json
$cmdOut

$CREATE_VNETS = $false
$CREATE_SUBNETS = $false
$CREATE_VM = $true

# create vnet + subnet


function WriteOutFile {
    param($file, $output, $screen)
    Add-Content -Path $FILE -Value $output
    if (($null -eq $screen) -or ($screen)) {
        Write-Host $output
    }
}

$sec = "VNETS"
Write-Host "[$sec] Creating VNETs ($($VNETS.Length))"
foreach ($vnet in $VNETS) {

   
    $prefix2 = $vnet[2]
    $locCode = $vnet[1]
    $location = $vnet[0]
    $vnetName = $NAME_PRE, "vnet", $locCode, $VER -join "-"
    $vnetPrefix = ($CIDR_PREFIX, $prefix2, "0", "0" -join ".") + "/16"
    
    $sec = "VNET"
    Write-Host "[$sec] Checking $sec"
    Write-Host "[$sec] Creating $sec"
    Write-Host "  vnet: $vnetName, $vnetPrefix"
    Write-Host "  location: $location"
    
    if ($CREATE_VNETS) {
    $cmdOut = az network vnet create -g $GRP -n $vnetName `
            --address-prefix $vnetPrefix `
            --location $location
    }

    foreach ($sub in $SUBS) {

       
        $prefix3 = $sub[1]
        $subnetName = $NAME_PRE, "subnet", $sub[0], $VER -join "-"
        $subnetPrefix = ($CIDR_PREFIX, $prefix2, $prefix3, "0" -join ".") + "/24"
        
        $sec = "Subnet"
        Write-Host "[$sec] Creating $sec"
        Write-Host "  vnet: $vnetName"
        Write-Host "  subnet: $subnetName, $subnetPrefix"

        if ($CREATE_SUBNETS) {
            $cmdOut = az network vnet subnet create --resource-group $GRP `
                                    --vnet-name $vnetName `
                                    --name $subnetName `
                                    --address-prefixes $subnetPrefix
        }
        
        
       
        $vms = 1..$sub[2]
        foreach ($vm in $vms) {
            if ($sub[0] -eq "pub") {
                
            }
            $sec = "VM"
            $pubPvt = $sub[0]
            $vmName = $NAME_PRE, $VMTYPE, $locCode, $pubPvt, $vm -join "-"
            
            Write-Host "[$sec] Creating $sec"
            Write-Host "  name: $vmName"
            Write-Host "  subnet: $subnetName"
            Write-Host "  image: $image"
            Write-Host "  user: $admin_user, $admin_pass"

            $customData = '#!/bin/bash
                # Use this for your user data (script from top to bottom)
                # install httpd (Linux 2 version)  
                sudo apt -y update
                sudo apt install -y apache2
                echo "<h1>Welcome to Azure Static Web VM, $(hostname): $(hostname -f)</h1>" > /var/www/html/index.html '

            if ($CREATE_VM -eq $false) {
                $cmdOut = az vm create --name $vmName `
                            --resource-group $GRP `
                            --vnet-name  $vnetName `
                            --subnet $subnetName `
                            --location $location `
                            --image $image `
                            --authentication-type password `
                            --admin-password $admin_pass `
                            --admin-username $admin_user `
                            --custom-data $customData
                
                            # --public-ip-address `
                            # [--count]
                            # [--generate-ssh-keys]
                            # [--ssh-dest-key-path]
                            # [--ssh-key-name]
                            # [--ssh-key-values]
                            # [--authentication-type {all, password, ssh}]
                            # [--public-ip-address-allocation {dynamic, static}]
                            # [--public-ip-address-dns-name]
                            # [--public-ip-sku {Basic, Standard}]
                            # [--license-type {None, RHEL_BASE, RHEL_BASESAPAPPS, RHEL_BASESAPHA, RHEL_BYOS, RHEL_ELS_6, RHEL_EUS, RHEL_SAPAPPS, RHEL_SAPHA, SLES, SLES_BYOS, SLES_HPC, SLES_SAP, SLES_STANDARD, UBUNTU, UBUNTU_PRO, Windows_Client, Windows_Server}]
                            # [--os-type {linux, windows}]
                            # [--nics]
                            # [--tags]
                            # [--vnet-name]
            }

        }
    }

}

$publicIpName = $NAME_PRE, "publicIp", $VER -join "-"

$sec = "Public IP"
Write-Host "[$sec] Creating $sec"
Write-Host "  name: $publicIpName"
Write-Host "  location: $GRP_LOC"

# Create a public IP address
$cmdOut = az network public-ip create --resource-group $GRP `
        --name $publicIpName `
        --location $GRP_LOC `
        --allocation-method Static --sku Standard

Write-Host "az network public-ip create --resource-group $GRP --name $publicIpName --location $GRP_LOC --allocation-method Static --sku Standard"


# Read the created public IP into a variable
$sp = az network public-ip show --resource-group $GRP `
        --name $publicIpName --query "{address: ipAddress}" --output json | ConvertFrom-Json
$publicIpAddress = $sp.address

# add http inbound rule

# create load balancer
$pools = @()
$frontEndIp = $NAME_PRE, "frontEndIp", $VER -join "-"
$lbName = $NAME_PRE, "lb", $VER -join "-"
$poolName = $NAME_PRE, "pool", $VER -join "-"

$sec = "Load Balancer"
Write-Host "[$sec] Creating $sec"
Write-Host "  name: $publicIpName"
Write-Host "  location: $GRP_LOC"

$cmdOut = az network lb create --resource-group $GRP `
    --location $GRP_LOC `
    --name $lbName `
    --public-ip-address $publicIpName `
    --frontend-ip-name $frontEndIp `
    --backend-pool-name $poolName `
    --sku Standard

Write-Host "az network lb create --resource-group $GRP --location $GRP_LOC --name $lbName --public-ip-address $publicIpName --frontend-ip-name $frontEndIp --backend-pool-name $poolName --sku Standard"

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









WriteOutFile -file $file -output "Creating Resource Group & Setting deployment user"
WriteOutFile -file $file -output "--------------------------------------------------------"


$cmdOut = az group create --location $GRP_LOC --name $GRP | ConvertFrom-Json
WriteOutFile -file $FILE -output $cmdOut

$vm1 = "cap2-az-vm-001"

$cmdOut = az group create --resource-group $GRP --name $vm1 | ConvertFrom-Json
WriteOutFile -file $FILE -output $cmdOut

