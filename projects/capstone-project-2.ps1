

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

# create vms
$cmdOut = az network vnet create -g $GRP -n $vnetName --address-prefix $vnetPrefix --subnet-name $subnetName --subnet-prefixes $subnetPrefix

az vmss create --name
               --resource-group
               [--admin-password]
               [--admin-username]
               [--authentication-type {all, password, ssh}]
               [--custom-data]
               [--image]
               [--instance-count]
               [--lb]
               [--lb-nat-rule-name]
               [--lb-sku {Basic, Gateway, Standard}]
               [--license-type {None, RHEL_BASE, RHEL_BASESAPAPPS, RHEL_BASESAPHA, RHEL_BYOS, RHEL_ELS_6, RHEL_EUS, RHEL_SAPAPPS, RHEL_SAPHA, SLES, SLES_BYOS, SLES_HPC, SLES_SAP, SLES_STANDARD, UBUNTU, UBUNTU_PRO, Windows_Client, Windows_Server}]
               [--location]
               [--max-batch-instance-percent]
               [--max-price]
               [--max-surge {false, true}]
               [--max-unhealthy-instance-percent]
               [--max-unhealthy-upgraded-instance-percent]
               [--network-api-version]
               [--no-wait]
               [--nsg]
               [--orchestration-mode {Flexible, Uniform}]
               [--os-disk-caching {None, ReadOnly, ReadWrite}]
               [--os-disk-delete-option {Delete, Detach}]
               [--os-disk-encryption-set]
               [--os-disk-name]
               [--os-disk-secure-vm-disk-encryption-set]
               [--os-disk-security-encryption-type {DiskWithVMGuestState, VMGuestStateOnly}]
               [--os-disk-size-gb]
               [--os-type {linux, windows}]
               [--patch-mode {AutomaticByOS, AutomaticByPlatform, ImageDefault, Manual}]
               [--pause-time-between-batches]
               [--plan-name]
               [--plan-product]
               [--plan-promotion-code]
               [--plan-publisher]
               [--platform-fault-domain-count]
               [--ppg]
               [--prioritize-unhealthy-instances {false, true}]
               [--priority {Low, Regular, Spot}]
               [--public-ip-address]
               [--public-ip-address-allocation {dynamic, static}]
               [--public-ip-address-dns-name]
               [--public-ip-per-vm]
               [--regular-priority-count]
               [--regular-priority-percentage]
               [--role]
               [--scale-in-policy {Default, NewestVM, OldestVM}]
               [--scope]
               [--secrets]
               [--security-type {ConfidentialVM, Standard, TrustedLaunch}]
               [--single-placement-group {false, true}]
               [--specialized {false, true}]
               [--spot-restore-timeout]
               [--ssh-dest-key-path]
               [--ssh-key-values]
               [--storage-container-name]
               [--storage-sku]
               [--subnet]
               [--subnet-address-prefix]
               [--tags]
               [--terminate-notification-time]
               [--ultra-ssd-enabled {false, true}]
               [--upgrade-policy-mode {Automatic, Manual, Rolling}]
               [--use-unmanaged-disk]
               [--user-data]
               [--v-cpus-available]
               [--v-cpus-per-core]
               [--validate]
               [--vm-domain-name]
               [--vm-sku]
               [--vnet-address-prefix]
               [--vnet-name]
               [--zones]

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

