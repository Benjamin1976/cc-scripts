

$VER = "003"
$GRP = "cc-capstone2-$VER"
$PROJECT = "CAP2"
$NAME_PRE = "tyrell"

$FILE = "G:\coding\envs\ps-az-setup\logs\az-creation-log-$GRP-$(get-date -f yyyy-MM-dd).txt"

$CIDR_PREFIX = "11"
$VNETS = @("eastus", "eastus",  "10", "US-NY"), @("australiasoutheast", "aus", "20", "AU-VIC")
$SUBS = @("pvt", "10", "0"), @("pub", "20", "1")
$GRP_LOC = $VNETS[0][0]
$VMTYPE = "web"

$admin_user = "benjamin"
$admin_pass = "Benjamin_123"
$image =  "Ubuntu2204" 

# azure
# $OUTHD = "[$($PROJECT)]"

# create rg


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
$cmdOut = .\az-commands\az-rg-check.ps1 $GRP $GRP_LOC
$cmdOut

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

    $sec = "VNET"
    $prefix2 = $vnet[2]
    $locCode = $vnet[1]
    $location = $vnet[0]
    $vnetName = $NAME_PRE, "vnet", $locCode, $VER -join "-"
    $vnetPrefix = ($CIDR_PREFIX, $prefix2, "0", "0" -join ".") + "/16"
    

    Write-Host "[$sec] Checking $sec"
    # $cmdOut = az network vnet show -g $GRP -n $vnetName | ConvertFrom-Json
    # if ($?) {
    #     Write-Host "[$sec] $vnetName exists."
    # } else {
        # $sp = $false 
        Write-Host "[$sec] Creating $sec"
        Write-Host "  vnet: $vnetName, $vnetPrefix"
        Write-Host "  location: $location"
        
        $cmdOut = az network vnet create -g $GRP -n $vnetName `
                --address-prefix $vnetPrefix `
                --location $location
    # }

    foreach ($sub in $SUBS) {

        $sec = "Subnet"
        $prefix3 = $sub[1]
        $subnetName = $NAME_PRE, "subnet", $sub[0], $VER -join "-"
        $subnetPrefix = ($CIDR_PREFIX, $prefix2, $prefix3, "0" -join ".") + "/24"
        # $prefix3 = $sub[1]
        # $subnetName = $NAME_PRE, "subnet", $sub[0], $VER -join "-"
        # $subnetPrefix = ($CIDR_PREFIX, $prefix2, $prefix3, "0" -join ".") + "/24"
        
        Write-Host "[$sec] Checking $sec"
        $cmdOut = az network vnet subnet show -g $GRP -n $subnetName --vnet-name $vnetName | ConvertFrom-Json
        # if ($?) {
        #     Write-Host "[$sec] $subnetName exists."
        # } else {
            Write-Host "[$sec] Creating $sec"
            Write-Host "  vnet: $vnetName"
            Write-Host "  subnet: $subnetName, $subnetPrefix"
            $cmdOut = az network vnet subnet create --resource-group $GRP `
                                  --vnet-name $vnetName `
                                  --name $subnetName `
                                  --address-prefixes $subnetPrefix
        # }
        
        if ($CREATE_VM -eq $false) {continue}
        $vms = 1..$sub[2]
        $sec = "VM"
        foreach ($vm in $vms) {
            if ($sub[0] -eq "pub") {
                
            }
            Write-Host "[$sec] Checking $sec"
            $vmName = $NAME_PRE, $VMTYPE, $locCode, $VER -join "-"
            # $cmdOut = az vm show --name $vmName --resource-group $GRP | ConvertFrom-Json
            # if ($?) {
            #     Write-Output "[$sec] $vmName exists."
            # } else {
                Write-Host "[$sec] Creating $sec"
                Write-Host "  name: $vmName"
                # Write-Host "location: $subnetName, $subnetPrefix"
                Write-Host "  subnet: $subnetName"
                Write-Host "  image: $image"
                Write-Host "  user: $admin_user, $admin_pass"

                $customData = '#!/bin/bash
                    # Use this for your user data (script from top to bottom)
                    # install httpd (Linux 2 version)  
                    sudo apt -y update
                    sudo apt install -y apache2
                    echo "<h1>Welcome to Azure Static Web VM, $(hostname): $(hostname -f)</h1>" > /var/www/html/index.html '
    
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
            # }

        }
    }
    
    # Write-Host "Creating Public IP"
    # $publicIPName = $NAME_PRE, $VER -join "-"
    # $cmdOut = az network public-ip create -g $GRP -n $publicIPName `
    #     --allocation-method Dynamic --version IPv4
    # $cmdOut
    
    # Write-Host "Creating NIC"
    # $cmdOut = az network nic create -g $GRP --vnet-name $vnetName `
    #     --subnet $subnetName -n python-example-nic `
    #     --public-ip-address python-example-ip
}
Exit




Exit
# $sp = az network public-ip show --name $publicIpName --resource-group $GRP
# if ($null -ne $sp) {
#     Write-Host "$obj $publicIpName exists."
# } else {
    # $sp = $false 
    Write-Host "$obj $publicIpName doesn't exist"
    Write-Host "Creating $obj : $publicIpName"
    # Create a public IP address
    $cmdOut = az network public-ip create --name $publicIpName `
            --resource-group $GRP --location $loc `
            --allocation-method Static --sku Standard
# }

# Read the created public IP into a variable
$sp = az network public-ip show --name $publicIpName --resource-group $GRP --query "{address: ipAddress}" --output json | ConvertFrom-Json
$publicIpAddress = $sp.address

# add http inbound rule

# create load balancer
$pools = @()
$frontEndIp = "myFrontEnd1"
$poolName = "myBackEndPool"

$cmdOut = az network lb create --resource-group $GRP `
    --name myLoadBalancer --sku Standard `
    --public-ip-address $publicIpName `
    --frontend-ip-name $frontEndIp `
    --backend-pool-name $poolName 

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

