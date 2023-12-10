
import subprocess
import json
from .general import findAWSObj

def getInstance(vpc, vmName):
    vpcId = vpc["vpcId"]
    region = vpc["region"]

    cmd = ["aws", "ec2", "describe-instances", "--region", region, "--filters", 'Name=vpc-id,Values=' + vpcId + '']
    output = subprocess.getoutput(cmd)
    data = json.loads(output)
    
    # check if instance created
    instanceId = ""
    for inst in data["Reservations"]:
        for tag in inst["Instances"][0]["Tags"]:
            print(tag)
            if tag["Key"] == "Name" and tag["Value"] == vmName:
                instanceId = inst["instanceId"]    
                return instanceId
        if instanceId: break
    return False


def createEC2(args):
    debug = True
    vpc = args["vpc"]
    vpcId = vpc["vpcId"]
    region = vpc["region"]
    az = vpc["az"]
    subnet = args["subnet"]
    vm = args["vm"]
    vmName = vm["name"]
                 
    # cmd = ["aws", "ec2", "describe-instances", "--region", region, "--filters", 'Name=vpc-id,Values=' + vpcId + '']
    # output = subprocess.check_output(cmd)
    # print(output)
    # quit()
    # cmd = ["aws", "ec2", "describe-instances", "--region", region, "--filters", 'Name=vpc-id,Values=' + vpcId + '']
    cmd = ["aws", "ec2", "describe-instances", "--region", region, "--filters", 'Name=vpc-id,Values=' + vpcId + ''
       , "Name=tag:Name,Values=" + vmName
       , "--query", 'Reservations[*].Instances[*].[InstanceId]', "--output", "text"]
    
    obj = "EC2"
    specs = {"obj": obj, "branch": "Reservations.Instances", "commands" : cmd, 
        "var": "name", "name": vmName, "returnVar": "InstanceId"}
    rules = [
        {"dataVar": "Name", "passedVar": "name"}
    ]
    
    if debug: print(f"[{obj}] Checking if", specs['obj'], ":", vmName, "exists")
    output = subprocess.check_output(cmd)
    instanceId = ""

    if not output.decode("utf-8"):
        instanceId = ""
    else:
        instanceId = output.decode("utf-8")
    print(instanceId)

    if instanceId: 
        print(f"[{obj}] exists, skipping.")            
    else:
        print(f"[{obj}] {obj} doesn't exist, creating :", subnet["cidr"])
        if debug: print( f"    vpc: {vpcId}")
        if debug: print( f"    vmName: {vmName}")
        if debug: print( f"    subnet: {subnet['name']}")
        if debug: print( f"    az: {az}")

        # tags = f"{{Key=Name, Value={vmName}}},{{Key=RG, Value=$GRP}}"
        tags = f"{{Key=Name, Value={vmName}}}"
        cmd = ["aws", "ec2", "run-instances" \
                ,"--security-group-ids", vm['groupId'] \
                ,"--image-id", vm['image'] \
                ,"--subnet-id", subnet["subnetId"] \
                ,"--instance-type", "t2.micro" \
                ,"--count", str(vm['count']) \
                ,"--key-name", vm["keyName"] \
                ,"--user-data", f"file://{vm['user-data']}"
                ,"--tag-specifications", f"ResourceType=instance,Tags=[{tags}]"]
        print(" ".join(cmd))

                # ,"--placement", f"""AvailabilityZone={az}""" \
        
        if vm['public']: cmd.append("--associate-public-ip-address")
        
        # creating EC2 instance
        output = subprocess.check_output(cmd)
        snOutput = json.loads(output)
        
        instanceId = snOutput["Instances"][0]["InstanceId"]
        print(f"[{obj}] Created Instance: {instanceId}")
    
    if debug: print(f"[{obj}] Finished:", obj)
    return instanceId


def createEC2s(args):
    # debug = False
    # obj = "EC2"
    for vpc in args['vpcs']:
        for subnet in vpc['subnets']:
            for vm in subnet['vms']:
                instanceId = createEC2({"vpc": vpc, "subnet": subnet, "vm": vm})
                vm["instanceId"] = instanceId

    return args




    
# customData = f"#!/bin/bash" \
#     + "# Use this for your user data (script from top to bottom)" \
#     + "# install httpd (Linux 2 version)" \
#     + "sudo apt -y update" \
#     + "sudo apt install -y apache2" \
#     + "echo ""<h1>Welcome to AWS Web VM, {vmName}</h1>"" > /var/www/html/index.html"
    # echo ""<h1>Welcome to AWS Web VM, $(hostname): $(hostname -f)</h1>"" > /var/www/html/index.html"

# $user_data = "userdata.txt"
# New-Item  -Name $user_data -ItemType "file" -Value $customData -Force | Out-Null


#   # ************************  Create EC2s
#         $vms = 1..$sub[2]
#         foreach ($vm in $vms) {

#             $sec = "EC2"
#             $pubPvt = $sub[0]
#             $vmName = $NAME_PRE, $VMTYPE, $locCode, $pubPvt, $vm -join "-"
            
#             Write-Host "[$sec] Creating $sec"
#             Write-Host "  name: $vmName"
#             Write-Host "  subnet: $subnetName"
#             Write-Host "  image: $image"
#             Write-Host "  keyPair: $keyName"
            


#             # create if the instance doesn't exists
#             if ($foundInst -eq $true) {
#                 Write-Host "[$sec] Found instance: $vmName"
        
#             } else {
#                 $customData = "#!/bin/bash
#                     # Use this for your user data (script from top to bottom)
#                     # install httpd (Linux 2 version)  
#                     sudo apt -y update
#                     sudo apt install -y apache2
#                     echo ""<h1>Welcome to AWS Web VM, $($vmName)</h1>"" > /var/www/html/index.html"
#                     # echo ""<h1>Welcome to AWS Web VM, $(hostname): $(hostname -f)</h1>"" > /var/www/html/index.html"/

#                 $user_data = "userdata.txt"
#                 New-Item  -Name $user_data -ItemType "file" -Value $customData -Force | Out-Null
         
#                 $tags = "{Key=Name, Value=$vmName},{Key=RG, Value=$GRP}"
#                 if ($debug) {Write-Host "  cmd: aws ec2 run-instances --security-group-ids $groupId --image-id $image --subnet-id $subnetId --instance-type ""t2.micro"" --count 1 --placement ""AvailabilityZone=$az"" --key-name $keyName --user-data ""file://$user_data"" --tag-specifications ""ResourceType=ec2,Tags=[$tags]"""}
#                 $cmdOut = aws ec2 run-instances --security-group-ids $groupId `
#                         --image-id $image `
#                         --subnet-id $subnetId `
#                         --instance-type "t2.micro" `
#                         --count 1 `
#                         --placement "AvailabilityZone=$az" `
#                         --key-name $keyName `
#                         --user-data "file://$user_data" `
#                         --associate-public-ip-address `
#                         --tag-specifications "ResourceType=instance,Tags=[$tags]" | ConvertFrom-Json


#                 if ($debug) {$cmdOut}
#                 if ($cmdOut.Instances.Length -eq 0) {
#                     Write-Host "  Error creating instance"
#                     $cmdOut    
#                     continue
#                 }
#                 $instanceId = $cmdOut.Instances[0].InstanceId
#                 Write-Host "  instanceId: $instanceId"

#                 # ************************  Create EBS Volume
#                 $sec = "EBS Volume"
#                 $pubPvt = $sub[0]
#                 $vmName = $NAME_PRE, $VMTYPE, $locCode, $pubPvt, $vm -join "-"
                
#                 Write-Host "[$sec] Creating $sec"
#                 Write-Host "  az: $az"
#                 if ($debug) {Write-Host "  cmd: aws ec2 create-volume --volume-type gp2 --size 1 --availability-zone $az"}
    
#                 $cmdOut = aws ec2 create-volume --volume-type gp2 `
#                             --size 1 `
#                             --availability-zone $az | ConvertFrom-Json
                            
#                 if ($debug) {$cmdOut}
#                 $volumeId = $cmdOut.VolumeId
#                 Write-Host "  volumeId: $volumeId"
    

#                 # # ************************  Attach EBS Volume
#                 # Write-Host "[$sec] Attaching $sec"
#                 # Write-Host "  instance-id: $instanceId"
#                 # Write-Host "  volume-id: $volumeId"
#                 # Write-Host "  device: /dev/sdh"
#                 # if ($debug) {Write-Host "  cmd: aws ec2 attach-volume --device /dev/sdh --instance-id $instanceId --volume-id $volumeId"}
#                 # $cmdOut = aws ec2 attach-volume --device /dev/sdh --instance-id $instanceId --volume-id $volumeId
#                 # if ($debug) {$cmdOut}
#             }

#         }