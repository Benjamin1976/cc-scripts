
import subprocess
import json
from general import findAWSObj


def createSubnets(args):
    debug = False
    vpcId = args["vpcId"]
    subnets = args["subnets"]
    print(vpcId)
    print(subnets)

    obj = "Subnet"
    subnetIds = []
    for subnet in subnets:
        specs = {"obj": "Subnet", "branch": "Subnets", "commands" :["aws", "ec2", "describe-subnets", "--filters", 'Name=vpc-id,Values=' + vpcId + ''], 
            "var": "cidr", "cidr": subnet["cidr"], "returnVar": "SubnetId"}
        rules = [{"dataVar": "CidrBlock", "passedVar": "cidr"}]
        
        if debug: print(f"[{obj}] Checking if", specs['obj'], "exists")
        subnetId = findAWSObj(specs, rules)

        if subnetId: 
            print(f"[{obj}] exists, skipping.")            
        else:
            print(f"[{obj}] {obj} doesn't exist, creating with cidr:", subnet["cidr"])
            if debug: print( f"    subnet: {subnet['name']}")
            if debug: print( f"    location: {subnet['location']}")
            if debug: print( f"    cidr: {subnet['cidr']}")
            
            tags = f"{{Key=Name, Value='{subnet['name']}-{subnet['location']}'}}"
            output = subprocess.check_output(["aws", "ec2", "create-subnet", "--vpc-id", vpcId , "--cidr-block", subnet['cidr'] \
                                              , "--availability-zone", subnet['location'] \
                                              , "--tag-specification", f"ResourceType=subnet,Tags=[{tags}]" ]) 
            
            snOutput = json.loads(output)
            subnetId = snOutput["Subnet"]["SubnetId"]
            print(f"[{obj}] Created Subnet: {subnetId}")

        subnetIds.append(subnetId)
    
    if debug: print(f"[{obj}] Finished:", obj)
    return subnetIds


def createAllSubnets(args):
    debug = False

    obj = "All Subnets"
    for arg in args:
      subnetIds = createSubnets({"vpcId": "config.vpcId", "subnets": arg["subnets"]})
      arg["subnetIds"] = subnetIds

    return args

    # vpcId = args["vpcId"]
    # subnets = args["subnets"]
    # print(vpcId)
    # print(subnets)

    # obj = "Subnet"
    # subnetIds = []
    # for subnet in subnets:
    #     specs = {"obj": "Subnet", "branch": "Subnets", "commands" :["aws", "ec2", "describe-subnets", "--filters", 'Name=vpc-id,Values=' + vpcId + ''], 
    #         "var": "cidr", "cidr": subnet[2], "returnVar": "SubnetId"}
    #     rules = [{"dataVar": "CidrBlock", "passedVar": "cidr"}]
        
    #     if debug: print(f"[{obj}] Checking if", specs['obj'], "exists")
    #     subnetId = findAWSObj(specs, rules)

    #     if subnetId: 
    #         print(f"[{obj}] exists, skipping.")            
    #     else:
    #         print(f"[{obj}] {obj} doesn't exist, creating with cidr:", subnet[2])
    #         if debug: print( f"    subnet: {subnet[0]}")
    #         if debug: print( f"    location: {subnet[1]}")
    #         if debug: print( f"    cidr: {subnet[2]}")
            
    #         tags = f"{{Key=Name, Value='{subnet[0]}-{subnet[1]}'}}"
    #         output = subprocess.check_output(["aws", "ec2", "create-subnet", "--vpc-id", vpcId , "--cidr-block", subnet[2] \
    #                                           , "--availability-zone", subnet[1] \
    #                                           , "--tag-specification", f"ResourceType=subnet,Tags=[{tags}]" ]) 
            
    #         snOutput = json.loads(output)
    #         subnetId = snOutput["Subnet"]["SubnetId"]
    #         print(f"[{obj}] Created Subnet: {subnetId}")

    #     subnetIds.append(subnetId)
    
    # if debug: print(f"[{obj}] Finished:", obj)
    # return subnetIds


# specs = {"obj": "Subnet", "branch": "Subnets", "commands" :["aws", "ec2", "describe-subnets", "--filters", 'Name=vpc-id,Values=' + 'vpc-07b7c12074c7f4b25' + ''], 
#     "var": "cidr", "cidr": "10.2.1.0/24", "returnVar": "SubnetId"}
# specs = {"obj": "Subnet", "branch": "Subnets", "commands" :["aws", "ec2", "describe-subnets"], 
#     "var": "cidr", "cidr": "10.2.1.0/24", "returnVar": "SubnetId"}
# rules = [{"dataVar": "CidrBlock", "passedVar": "cidr"}]

# print( "-------Checking if", specs['obj'], "exists---------")
# subnetId = findAWSObj(specs, rules)
# print(subnetId)

# {
#     "Subnet": {
#         "AvailabilityZone": "us-east-1b",
#         "AvailabilityZoneId": "use1-az4",
#         "AvailableIpAddressCount": 251,
#         "CidrBlock": "10.2.10.0/24",
#         "DefaultForAz": false,
#         "MapPublicIpOnLaunch": false,
#         "State": "available",
#         "SubnetId": "subnet-045d9b87af09e3689",
#         "VpcId": "vpc-0f11c718a52403578",
#         "OwnerId": "946229218607",
#         "AssignIpv6AddressOnCreation": false,
#         "Ipv6CidrBlockAssociationSet": [],
#         "Tags": [
#             {
#                 "Key": "Name",
#                 "Value": "rds-subnet-us-east-1b"
#             }
#         ],
#         "SubnetArn": "arn:aws:ec2:us-east-1:946229218607:subnet/subnet-045d9b87af09e3689",
#         "EnableDns64": false,
#         "Ipv6Native": false,
#         "PrivateDnsNameOptionsOnLaunch": {
#             "HostnameType": "ip-name",
#             "EnableResourceNameDnsARecord": false,
#             "EnableResourceNameDnsAAAARecord": false
#         }
#     }
# }