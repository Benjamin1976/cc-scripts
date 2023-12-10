from pylibs.general import readJSONFile, writeJSONFile, getConfig, saveConfig

from pylibs.aws_vpc import createVPC, createVPCs
from pylibs.aws_subnet import createSubnets
from pylibs.aws_subnet_group import createSubnetGroup
from pylibs.aws_internet_gateway import createIGW
from pylibs.aws_route_table import createRouteTbl
from pylibs.aws_security_group import createSG
from pylibs.aws_create_rds_db import createRDSdb

# AKIAWZWSRYDQTZLFIMXU
# wURvYuUpFRW5iKDgNmVOQcpEXfwduxCSAoA4byLU
quit()
index = "2"
args_vpc = {
    "vpcName": "rds-script-test-00" + index,
    "vpcCidr": "10." + index + ".0.0/16"
}

# # subnet variables
args_sub = {
    "vpcCidrPre": "10." + index + ".",
    "vpcCidrSuf": ".0/24",
    "subnetNamePre": "rds-subnet",
    "subnets": [["rds-subnet", "us-east-1a", "1"], ["rds-subnet", "us-east-1b", "2"]]
}
# subnets = [[subnetNamePre, "us-east-1a", "1"], [subnetNamePre, "us-east-1b", "2"], [subnetNamePre, "us-east-1c", "3"], [subnetNamePre, "us-east-1d", "4"], [subnetNamePre, "us-east-1e", "5"], [subnetNamePre, "us-east-1f", "6"]]
for sn in args_sub["subnets"]:
    sn[2] = args_sub["vpcCidrPre"] + sn[2] + args_sub["vpcCidrSuf"]


# # subnet group name
args_subgroup = {
    "subnetGroupName": "rds-subnet-grp-00" + index,
    "subnetGroupDesc": "subnet group for rds server"
}

# internet gateway name
args_igw = {
    "igwName": "igw-rds-00" + index
}

# route table
args_rtable = {
    "name": "rt-igw-00" + index,
}

# security group name
args_sg = {
    "sgName": "rds-sg-00" + index,
    "sgDesc": "security group for rds db",
    "myIp": "218.212.131.0/24"
}


# rds Details
args_rds = {
    "rdsName": "rds-db-script-00" + index,
    "rdsInstance": "db.t3.micro",
    "dbEngine": "sqlserver-ex",
    "dbSubnetGroup": args_subgroup["subnetGroupName"],
    "dbSecurityGroups": args_sg["sgName"],
    "username": "admin",
    "password": "benjamin_123"
}


configFile = "deployment.log"
config = getConfig(configFile)

# # # check if to create
# runCreateVPC = False
# runCreateSubnet = False
# runCreateSubnetGroup = False
# runCreateIGW = False
# runCreateRouteTbl = False
# runCreateSecurityGroup = False
# runCreateRDSdb = True

# "createdVPC": False,
# "createdSubnet": False,
# "createdSubnetGroup": False,
# "createdIGW": False,
# "createdRouteTbl": False,
# "createdSecurityGroup": False,
# "createdRDSdb": False,


actions = [
    {"name": "VPC", "runCheck" : "createdVPC", "configVar": "vpcId", "fnc": createVPCs, "arguments": {"vpcName": args_vpc["vpcName"], "vpcCidr": args_vpc["vpcCidr"]}},
    {"name": "Subnet", "runCheck" : "createdSubnet", "configVar": "subnetIds", "fnc": createSubnets, "arguments": {"vpcId": "config.vpcId", "subnets": args_sub["subnets"]}},
    {"name": "Subnet Group", "runCheck" : "createdSubnetGroup", "configVar": "subnetGroupId", "fnc": createSubnetGroup, "arguments": {"groupName": args_subgroup["subnetGroupName"], \
                "groupDesc": args_subgroup["subnetGroupDesc"], "subnetIds": "config.subnetIds"}},
    {"name": "IGW", "runCheck" : "createdIGW", "configVar": "igwId", "fnc": createIGW, "arguments": {"igwName": args_igw["igwName"], "vpcId": "config.vpcId"}},
    {"name": "Route Table", "runCheck" : "createdRouteTbl", "configVar": "routeTableId", "fnc": createRouteTbl, "arguments": {"igwId": "config.igwId", "vpcId": "config.vpcId", "name": args_rtable["name"]}},
    {"name": "Security Group", "runCheck" : "createdSecurityGroup", "configVar": "securityGroup", "fnc": createSG, "arguments": {"sgName": args_sg["sgName"],"sgDesc": args_sg["sgDesc"], "myIp": args_sg["myIp"], "vpcId": "config.vpcId"}},
    {"name": "RDS Db", "runCheck" : "createdRDSdb", "configVar": "rdsDBArn", "fnc": createRDSdb, "arguments": {"rdsName": args_rds["rdsName"], "rdsInstance": args_rds["rdsInstance"], \
                "dbEngine": args_rds["dbEngine"], "dbSubnetGroup": args_rds["dbSubnetGroup"], "dbSecurityGroups": "config.securityGroup", "username": args_rds["username"], "password": args_rds["password"]}},
]


for action in actions:
    name = action['name']
    cfgVar = action['configVar']
    runCheck = action["runCheck"]
    args = action['arguments']

    if (config[runCheck] is False):
        print(f"[e2e] Creating: {name}")

        # check arguments
        for item in args.keys():
            if "config." in args[item]:
                arg_name = args[item].split(".")[-1]
                args[item] = config[arg_name]

        data = action['fnc'](action['arguments'])
        config[cfgVar] = data
        config[runCheck] = True
        saveConfig(configFile, config)

        print(f"[e2e] Finished: {name}")
    else:
        print(f"[e2e] Skipping:", {name})
        if not cfgVar in config:
            print("Cannot find:", name, ":", cfgVar)
        # config[action['configVar']] = "vpc-04a0b322e0cfe66b6"
  
quit()



