

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
$admin_pass = "benjamin_123"
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

function CreateSubnet {
    param($GRP, $sub, $NAME_PRE, $vnetName, $CIDR_PREFIX, $prefix2, $VER)
    
    $sec = "Subnet"
    $prefix3 = $sub[1]
    $subnetName = $NAME_PRE, "subnet", $sub[0], $VER -join "-"
    $subnetPrefix = ($CIDR_PREFIX, $prefix2, $prefix3, "0" -join ".") + "/24"
    # $prefix3 = $sub[1]
    # $subnetName = $NAME_PRE, "subnet", $sub[0], $VER -join "-"
    # $subnetPrefix = ($CIDR_PREFIX, $prefix2, $prefix3, "0" -join ".") + "/24"
    
    Write-Host "[$sec] Checking $sec"
    $cmdOut = az network vnet subnet show -g $GRP -n $subnetName --vnet-name $vnetName | ConvertFrom-Json
    if ($?) {
        Write-Host "[$sec] $subnetName exists."
    } else {
        Write-Host "[$sec] Creating $sec"
        Write-Host "  vnet: $vnetName"
        Write-Host "  subnet: $subnetName, $subnetPrefix"
        $cmdOut = az network vnet subnet create --resource-group $GRP `
                              --vnet-name $vnetName `
                              --name $subnetName `
                              --address-prefixes $subnetPrefix
    }
}

function CreateVnet {
    param($GRP, $NAME_PRE, $vnet, $CIDR_PREFIX, $locCode, $VER)
    #, $NAME_PRE, $vnetName, $CIDR_PREFIX, $prefix2, $VER
    
    $sec = "VNET"
    $prefix2 = $vnet[2]
    $locCode = $vnet[1]
    $location = $vnet[0]
    $vnetName = $NAME_PRE, "vnet", $locCode, $VER -join "-"
    $vnetPrefix = ($CIDR_PREFIX, $prefix2, "0", "0" -join ".") + "/16"
    

    Write-Host "[$sec] Checking $sec"
    $cmdOut = az network vnet show -g $GRP -n $vnetName | ConvertFrom-Json
    if ($?) {
        Write-Host "[$sec] $vnetName exists."
    } else {
        # $sp = $false 
        Write-Host "[$sec] Creating $sec"
        Write-Host "  vnet: $vnetName, $vnetPrefix"
        Write-Host "  location: $location"
        
        $cmdOut = az network vnet create -g $GRP -n $vnetName --address-prefix $vnetPrefix
    }
    return $vnetName

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

    CreateVnet $GRP $NAME_PRE $vnet $CIDR_PREFIX $locCode $VER

    foreach ($sub in $SUBS) {

        CreateSubnet $GRP $sub $NAME_PRE $vnetName $CIDR_PREFIX $prefix2 $VER

        
        if ($CREATE_VM -eq $false) {continue}
        $vms = 1..$sub[2]
        $sec = "VM"
        foreach ($vm in $vms) {
            if ($sub[0] -eq "pub") {
                
            }
            Write-Host "[$sec] Checking $sec"
            $vmName = $NAME_PRE, $VMTYPE, $locCode, $VER -join "-"
            $cmdOut = az vm show --name $vmName --resource-group $GRP | ConvertFrom-Json
            if ($?) {
                Write-Output "[$sec] $vmName exists."
            } else {
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
                            --vnet-name NAME $subnetName `
                            --subnet $subnetName `
                            --location $location `
                            --image $image `
                            --authentication-type password `
                            --admin-password $admin_user `
                            --admin-username $admin_pass `
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


foreach ($vnet in $VNETS) {
    foreach ($sub in $SUBS) {
       
    }
}

# az vm create --name
#              --resource-group
#              [--accelerated-networking {false, true}]
#              [--accept-term]
#              [--admin-password]
#              [--admin-username]
#              [--asgs]
#              [--assign-identity]
#              [--attach-data-disks]
#              [--attach-os-disk]
#              [--authentication-type {all, password, ssh}]
#              [--availability-set]
#              [--boot-diagnostics-storage]
#              [--capacity-reservation-group]
#              [--computer-name]
#              [--count]
#              [--custom-data]
#              [--data-disk-caching]
#              [--data-disk-delete-option]
#              [--data-disk-encryption-sets]
#              [--data-disk-sizes-gb]
#              [--disable-integrity-monitoring-autoupgrade]
#              [--disk-controller-type {NVMe, SCSI}]
#              [--edge-zone]
#              [--enable-agent {false, true}]
#              [--enable-auto-update {false, true}]
#              [--enable-hibernation {false, true}]
#              [--enable-hotpatching {false, true}]
#              [--enable-integrity-monitoring]
#              [--enable-secure-boot {false, true}]
#              [--enable-vtpm {false, true}]
#              [--encryption-at-host {false, true}]
#              [--ephemeral-os-disk {false, true}]
#              [--ephemeral-os-disk-placement {CacheDisk, ResourceDisk}]
#              [--eviction-policy {Deallocate, Delete}]
#              [--generate-ssh-keys]
#              [--host]
#              [--host-group]
#              [--image]
#              [--license-type {None, RHEL_BASE, RHEL_BASESAPAPPS, RHEL_BASESAPHA, RHEL_BYOS, RHEL_ELS_6, RHEL_EUS, RHEL_SAPAPPS, RHEL_SAPHA, SLES, SLES_BYOS, SLES_HPC, SLES_SAP, SLES_STANDARD, UBUNTU, UBUNTU_PRO, Windows_Client, Windows_Server}]
#              [--location]
#              [--max-price]
#              [--nic-delete-option]
#              [--nics]
#              [--no-wait]
#              [--nsg]
#              [--nsg-rule {NONE, RDP, SSH}]
#              [--os-disk-caching {None, ReadOnly, ReadWrite}]
#              [--os-disk-delete-option {Delete, Detach}]
#              [--os-disk-encryption-set]
#              [--os-disk-name]
#              [--os-disk-secure-vm-disk-encryption-set]
#              [--os-disk-security-encryption-type {DiskWithVMGuestState, VMGuestStateOnly}]
#              [--os-disk-size-gb]
#              [--os-type {linux, windows}]
#              [--patch-mode {AutomaticByOS, AutomaticByPlatform, ImageDefault, Manual}]
#              [--plan-name]
#              [--plan-product]
#              [--plan-promotion-code]
#              [--plan-publisher]
#              [--platform-fault-domain]
#              [--ppg]
#              [--priority {Low, Regular, Spot}]
#              [--private-ip-address]
#              [--public-ip-address]
#              [--public-ip-address-allocation {dynamic, static}]
#              [--public-ip-address-dns-name]
#              [--public-ip-sku {Basic, Standard}]
#              [--role]
#              [--scope]
#              [--secrets]
#              [--security-type {ConfidentialVM, Standard, TrustedLaunch}]
#              [--size]
#              [--specialized {false, true}]
#              [--ssh-dest-key-path]
#              [--ssh-key-name]
#              [--ssh-key-values]
#              [--storage-account]
#              [--storage-container-name]
#              [--storage-sku]
#              [--subnet]
#              [--subnet-address-prefix]
#              [--tags]
#              [--ultra-ssd-enabled {false, true}]
#              [--use-unmanaged-disk]
#              [--user-data]
#              [--v-cpus-available]
#              [--v-cpus-per-core]
#              [--validate]
#              [--vmss]
#              [--vnet-address-prefix]
#              [--vnet-name]
#              [--workspace]
#              [--zone]

# az vmss create --name
#                --resource-group
#                [--admin-password]
#                [--admin-username]
#                [--authentication-type {all, password, ssh}]
#                [--custom-data]
#                [--image]
#                [--license-type {None, RHEL_BASE, RHEL_BASESAPAPPS, RHEL_BASESAPHA, RHEL_BYOS, RHEL_ELS_6, RHEL_EUS, RHEL_SAPAPPS, RHEL_SAPHA, SLES, SLES_BYOS, SLES_HPC, SLES_SAP, SLES_STANDARD, UBUNTU, UBUNTU_PRO, Windows_Client, Windows_Server}]
#                [--location]
#                [--os-type {linux, windows}]
#                [--public-ip-address]
#                [--public-ip-address-allocation {dynamic, static}]
#                [--public-ip-address-dns-name]
#                [--public-ip-per-vm]
#                [--ssh-dest-key-path]
#                [--ssh-key-values]
#                [--subnet]
#                [--subnet-address-prefix]
#                [--tags]
#                [--terminate-notification-time]
#                [--ultra-ssd-enabled {false, true}]
#                [--upgrade-policy-mode {Automatic, Manual, Rolling}]
#                [--use-unmanaged-disk]
#                [--user-data]
#                [--v-cpus-available]
#                [--v-cpus-per-core]
#                [--validate]
#                [--vm-domain-name]
#                [--vm-sku]
#                [--vnet-address-prefix]
#                [--vnet-name]
#                [--zones]
# az vmss create --name
#                --resource-group
#                [--admin-password]
#                [--admin-username]
#                [--authentication-type {all, password, ssh}]
#                [--custom-data]
#                [--image]
#                [--instance-count]
#                [--lb]
#                [--lb-nat-rule-name]
#                [--lb-sku {Basic, Gateway, Standard}]
#                [--license-type {None, RHEL_BASE, RHEL_BASESAPAPPS, RHEL_BASESAPHA, RHEL_BYOS, RHEL_ELS_6, RHEL_EUS, RHEL_SAPAPPS, RHEL_SAPHA, SLES, SLES_BYOS, SLES_HPC, SLES_SAP, SLES_STANDARD, UBUNTU, UBUNTU_PRO, Windows_Client, Windows_Server}]
#                [--location]
#                [--max-batch-instance-percent]
#                [--max-price]
#                [--max-surge {false, true}]
#                [--max-unhealthy-instance-percent]
#                [--max-unhealthy-upgraded-instance-percent]
#                [--network-api-version]
#                [--no-wait]
#                [--nsg]
#                [--orchestration-mode {Flexible, Uniform}]
#                [--os-disk-caching {None, ReadOnly, ReadWrite}]
#                [--os-disk-delete-option {Delete, Detach}]
#                [--os-disk-encryption-set]
#                [--os-disk-name]
#                [--os-disk-secure-vm-disk-encryption-set]
#                [--os-disk-security-encryption-type {DiskWithVMGuestState, VMGuestStateOnly}]
#                [--os-disk-size-gb]
#                [--os-type {linux, windows}]
#                [--patch-mode {AutomaticByOS, AutomaticByPlatform, ImageDefault, Manual}]
#                [--pause-time-between-batches]
#                [--plan-name]
#                [--plan-product]
#                [--plan-promotion-code]
#                [--plan-publisher]
#                [--platform-fault-domain-count]
#                [--ppg]
#                [--prioritize-unhealthy-instances {false, true}]
#                [--priority {Low, Regular, Spot}]
#                [--public-ip-address]
#                [--public-ip-address-allocation {dynamic, static}]
#                [--public-ip-address-dns-name]
#                [--public-ip-per-vm]
#                [--regular-priority-count]
#                [--regular-priority-percentage]
#                [--role]
#                [--scale-in-policy {Default, NewestVM, OldestVM}]
#                [--scope]
#                [--secrets]
#                [--security-type {ConfidentialVM, Standard, TrustedLaunch}]
#                [--single-placement-group {false, true}]
#                [--specialized {false, true}]
#                [--spot-restore-timeout]
#                [--ssh-dest-key-path]
#                [--ssh-key-values]
#                [--storage-container-name]
#                [--storage-sku]
#                [--subnet]
#                [--subnet-address-prefix]
#                [--tags]
#                [--terminate-notification-time]
#                [--ultra-ssd-enabled {false, true}]
#                [--upgrade-policy-mode {Automatic, Manual, Rolling}]
#                [--use-unmanaged-disk]
#                [--user-data]
#                [--v-cpus-available]
#                [--v-cpus-per-core]
#                [--validate]
#                [--vm-domain-name]
#                [--vm-sku]
#                [--vnet-address-prefix]
#                [--vnet-name]
#                [--zones]

Exit

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









WriteOutFile -file $file -output "Creating Resource Group & Setting deployment user"
WriteOutFile -file $file -output "--------------------------------------------------------"


$cmdOut = az group create --location $GRP_LOC --name $GRP | ConvertFrom-Json
WriteOutFile -file $FILE -output $cmdOut

$vm1 = "cap2-az-vm-001"

$cmdOut = az group create --resource-group $GRP --name $vm1 | ConvertFrom-Json
WriteOutFile -file $FILE -output $cmdOut

