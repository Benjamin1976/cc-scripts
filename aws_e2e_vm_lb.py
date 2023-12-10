# # yjcd8fy5APEKhl3W7u1NXsErU1rAOcEDnODeCwiK
# # AKIATPLYBEW7OPMNWFNV

# import pylibs.aws_vpc
import subprocess, json
from pylibs.general import readJSONFile, writeJSONFile, getConfig, saveConfig, convertFromJSON, findAWSObj
from pylibs.aws_vpc import  createVPCs
from pylibs.aws_subnet import createSubnets
from pylibs.aws_internet_gateway import createIGWs
from pylibs.aws_route_table import createRouteTbls
from pylibs.aws_security_group import createSGs
from pylibs.aws_keypair import createKeyPairs
from pylibs.aws_ec2 import createEC2s

from pylibs.aws_subnet_group import createSubnetGroup
from pylibs.aws_create_rds_db import createRDSdb

# Project Details
version = "002"
group = "cc-capstone2-" + version
namePrefix = "tyrell" 
vmType = "web"
cidrPre = "16"

# EC2 authentication details
admin_user = "benjamin"                    # admin username
admin_pass = "Benjamin_123"                # admin password - would be masked in real environment
image =  "ami-0cd601a22ac9e6d79"           # ec2 ami - windows server 2022 base
image =  "ami-0230bd60aa48260c6"           # ec2 ami - amazon linux
image =  "ami-0fa1ca9559f1892ec"           # ec2 ami - amazon linux 2
image =  "ami-0fc5d935ebf8bc3bc"           # ec2 ami - ubuntu
keyName = namePrefix + "-aws-keypair2-" + version
instanceType = "t2.micro"
userDataFile = "userdata.txt"

# VPC settings
args_vpcs = [
    {"region": "us-west-2", "locCode": "uswest2", "cidr2": "10", "az": "us-west-2a"},
    {"region": "us-east-1", "locCode": "useast1", "cidr2": "20", "az": "us-east-1a"}
]

# need to move az down to subs from vpc but then it's not so generic.  tbc
#       maybe need to check region to see how many az's and then just increment
#       az.a, az.b until met the az count / limit
subs = [
    {"purpose": "pub", "cidr3": "10", "vms": 2}, 
    {"purpose": "pvt", "cidr3": "20", "vms": 1} 
]



# my IP Configuration
myIp = subprocess.check_output(["curl", "ifcfg.me"])
myIp = myIp.decode("utf-8")


configFile = "deployment.log"
setup = getConfig(configFile)
config = getConfig(configFile)
    

# loop through VPC and enrich data
setup = {"vpcs": [], "myIp": myIp, "keyName": keyName}
for vpc in args_vpcs:
    vpc.update({'subnets': [], "routeTables": [], "secGroups": [], "igw": {}})
    vpc["vpcCidr"] = cidrPre + "." + vpc["cidr2"] + ".0.0/16"
    vpc["vpcName"] = "-".join([namePrefix, "vpc", vpc["locCode"], version])
    
    for sub in subs:
        public = False if sub["purpose"] == "pvt" else True
        
        # create subnet
        subnet = {
            "cidr": cidrPre + "." + vpc["cidr2"] + "." + sub["cidr3"] + ".0/24",
            "name": "-".join([namePrefix, "subnet", sub["purpose"], vpc["locCode"], version]),
            "vms":[]
        }
        vpc['subnets'].append(subnet)

        # create security group
        sg = {"name": "-".join([namePrefix, "sg", sub["purpose"], vpc["locCode"], version]), 
                    "internet": public,
                    "desc": f"Security Group for {group}"}
        vpc['secGroups'].append(sg)        

        # create IGW if public facing
        for i in range(0, sub["vms"]):
            subnet["vms"].append({
                "name": "-".join([namePrefix, vmType, vpc["locCode"], sub["purpose"], version]),
                "groupId": sg["name"],
                "image": image,
                "keyName": keyName,
                "instance-type": instanceType,
                "count": 1,
                "placement": "AvailabilityZone=" + vpc["az"],
                "user-data": userDataFile,
                "public": public
            })

        # create IGW if public facing
        if sub["purpose"] == "pub":
            vpc['igw'] = {"name": "-".join([namePrefix, "igw", vpc["locCode"], version])}

        # add route table
        # need to extend route tables for each az
        vpc['routeTables'].append(
            {"name": "-".join([namePrefix, "routes", sub["purpose"], vpc["locCode"], version]), 
                    "internet": public}
        )
  
        
    setup["vpcs"].append(vpc)


actions = [
    {"name": "KeyPair", "runCheck" : "createdKeyPair", "setupVar": "KeyPairId", "configVar": "KeyPairId", "fnc": createKeyPairs},
    {"name": "VPC", "runCheck" : "createdVPC", "setupVar": "vpcId", "configVar": "vpcId", "fnc": createVPCs},
    {"name": "Subnet", "runCheck" : "createdSubnet", "configVar": "subnetIds", "fnc": createSubnets},
    {"name": "IGW", "runCheck" : "createdIGW", "configVar": "igwId", "fnc": createIGWs},
    {"name": "Route Table", "runCheck" : "createdRouteTbl", "configVar": "routeTableId", "fnc": createRouteTbls},
    {"name": "Security Group", "runCheck" : "createdSecurityGroup", "configVar": "securityGroup", "fnc": createSGs},
    {"name": "EC2", "runCheck" : "createdEC2", "configVar": "EC2", "fnc": createEC2s},
    # {"name": "Subnet", "runCheck" : "createdSubnet", "configVar": "subnetIds", "fnc": createAllSubnets},
    # {"name": "Subnet Group", "runCheck" : "createdSubnetGroup", "configVar": "subnetGroupId", "fnc": createSubnetGroup},
    # {"name": "RDS Db", "runCheck" : "createdRDSdb", "configVar": "rdsDBArn", "fnc": createRDSdb},
]


for action in actions:
    name = action['name']
    cfgVar = action['configVar']
    runCheck = action["runCheck"]

    print(f"[e2e] Creating: {name}")
    setup = action['fnc'](setup)
    print(f"[e2e] Finished: {name}")

# for action in actions:
#     name = action['name']
#     cfgVar = action['configVar']
#     runCheck = action["runCheck"]
#     # args = action['arguments']

#     if (not config[runCheck] is False):
#         print(f"[e2e] Creating: {name}")

#         # check arguments
#         # for item in args.keys():
#         #     if "config." in args[item]:
#         #         arg_name = args[item].split(".")[-1]
#         #         args[item] = config[arg_name]

#         # data = action['fnc'](action['arguments'])
#         setup = action['fnc'](setup)
#         # setup["setupVar"] = data
#         # print(setup)
#         # setup
#         # config[cfgVar] = data
#         # config[runCheck] = True
#         # saveConfig(configFile, setup)

#         print(f"[e2e] Finished: {name}")
#     else:
#         print(f"[e2e] Skipping:", {name})
#         if not cfgVar in config:
#             print("Cannot find:", name, ":", cfgVar)
#         # config[action['configVar']] = "vpc-04a0b322e0cfe66b6"

#     # break
  
quit()


# # # subnet group name
# args_subgroup = {
#     "subnetGroupName": "rds-subnet-grp-00" + version,
#     "subnetGroupDesc": "subnet group for rds server"
# }



# # rds Details
# args_rds = {
#     "rdsName": "rds-db-script-00" + version,
#     "rdsInstance": "db.t3.micro",
#     "dbEngine": "sqlserver-ex",
#     "dbSubnetGroup": args_subgroup["subnetGroupName"],
#     "dbSecurityGroups": args_sg["sgName"],
#     "username": "admin",
#     "password": "benjamin_123"
# }


# actions = [
#     {"name": "KeyPair", "runCheck" : "checkKeyPair", "setupVar": "KeyPairId", "configVar": "KeyPairId", "fnc": createKeyPairs, "arguments": {"vpcs": setup['vpcs']}},
#     {"name": "VPC", "runCheck" : "createdVPC", "setupVar": "vpcId", "configVar": "vpcId", "fnc": createVPCs, "arguments": {"vpcs": setup['vpcs']}},
#     {"name": "Subnet", "runCheck" : "createdSubnet", "configVar": "subnetIds", "fnc": createSubnets, "arguments": {"vpcId": "config.vpcId", "subnets": setup}},
#     {"name": "IGW", "runCheck" : "createdIGW", "configVar": "igwId", "fnc": createIGWs, "arguments": {"igwName": args_igw["igwName"], "vpcId": "config.vpcId"}},
#     {"name": "Route Table", "runCheck" : "createdRouteTbl", "configVar": "routeTableId", "fnc": createRouteTbls, "arguments": {"igwId": "config.igwId", "vpcId": "config.vpcId", "name": args_rtable["name"]}},
#     {"name": "Security Group", "runCheck" : "createdSecurityGroup", "configVar": "securityGroup", "fnc": createSGs, "arguments": {"sgName": args_sg["sgName"],"sgDesc": args_sg["sgDesc"], "myIp": args_sg["myIp"], "vpcId": "config.vpcId"}},
#     {"name": "EC2", "runCheck" : "createEC2", "configVar": "EC2", "fnc": createEC2s, "arguments": {"sgName": args_sg["sgName"],"sgDesc": args_sg["sgDesc"], "myIp": args_sg["myIp"], "vpcId": "config.vpcId"}},
#     # {"name": "Subnet", "runCheck" : "createdSubnet", "configVar": "subnetIds", "fnc": createAllSubnets, "arguments": {"vpcId": "config.vpcId", "subnets": args_subs}},
#     # {"name": "Subnet Group", "runCheck" : "createdSubnetGroup", "configVar": "subnetGroupId", "fnc": createSubnetGroup, "arguments": {"groupName": args_subgroup["subnetGroupName"], \
#     #             "groupDesc": args_subgroup["subnetGroupDesc"], "subnetIds": "config.subnetIds"}},
#     # {"name": "RDS Db", "runCheck" : "createdRDSdb", "configVar": "rdsDBArn", "fnc": createRDSdb, "arguments": {"rdsName": args_rds["rdsName"], "rdsInstance": args_rds["rdsInstance"], \
#     #             "dbEngine": args_rds["dbEngine"], "dbSubnetGroup": args_rds["dbSubnetGroup"], "dbSecurityGroups": "config.securityGroup", "username": args_rds["username"], "password": args_rds["password"]}},
# ]

