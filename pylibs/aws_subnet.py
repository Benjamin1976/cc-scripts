
import subprocess
import json
from .general import findAWSObj

def createSubnet(args):
    debug = True
    vpcId = args["vpcId"]
    subnet = args["subnet"]
    region = args["region"]
    az = args["az"]


    obj = "Subnet"
    specs = {"obj": "Subnet", "branch": "Subnets", "commands" :["aws", "ec2", "describe-subnets", "--region", region, "--filters", 'Name=vpc-id,Values=' + vpcId + ''], 
        "var": "cidr", "cidr": subnet["cidr"], "returnVar": "SubnetId"}
    rules = [
        {"branch": "Subnets", "dataVar": "CidrBlock", "passedVar": "cidr"}    
    ]
    
    print(f"[{obj}] ----- Checking & creating subnet: {subnet['cidr']}")
    if debug: print(f"[{obj}] Checking if", specs['obj'], "exists")
    subnetId = findAWSObj(specs, rules)

    if subnetId: 
        print(f"[{obj}] exists, skipping.")            
    else:
        print(f"[{obj}] {obj} doesn't exist, creating with cidr:", subnet["cidr"])
        if debug: print( f"    vpc: {vpcId}")
        if debug: print( f"    region: {region}")
        if debug: print( f"    subnet: {subnet['name']}")
        if debug: print( f"    cidr: {subnet['cidr']}")
        
        tags = f"{{Key=Name, Value='{subnet['name']}'}}"
        output = subprocess.check_output(["aws", "ec2", "create-subnet", "--vpc-id", vpcId 
                                            , "--cidr-block", subnet['cidr'] \
                                            , "--region", region \
                                            , "--availability-zone", az \
                                            , "--tag-specification", f"ResourceType=subnet,Tags=[{tags}]" ]) 
        
        snOutput = json.loads(output)
        subnetId = snOutput["Subnet"]["SubnetId"]
        print(f"[{obj}] Created Subnet: {subnetId}")
    
    if debug: print(f"[{obj}] Finished:", obj)
    return subnetId


def createSubnets(args):
    # debug = False
    # obj = "All Subnets"
    for vpc in args['vpcs']:
        for subnet in vpc['subnets']:
            subnetId = createSubnet({"vpcId": vpc["vpcId"], "subnet": subnet, "region": vpc["region"], "az": vpc["az"]})
            subnet["subnetId"] = subnetId

    return args
