# AKIA3X5NUGYYWFCT2AWY
# GQTTGmn+KrQZwE76Fn4SFw6/s1Er+yLTBjCukafX

import subprocess
import os.path
from pylibs.general import readJSONFile, writeJSONFile

from pylibs.aws_vpc import createVPC
from pylibs.aws_subnet import createSubnets
from pylibs.aws_subnet_group import createSubnetGroup
from pylibs.aws_internet_gateway import createIGW
from pylibs.aws_route_table import createRouteTbl
from pylibs.aws_security_group import createSG
from pylibs.aws_create_rds_db import createRDSdb

vpcName = "rds-script-test-002"
vpcCidr = "10.2.0.0/16"

# # subnet variables
vpcCidrPre = "10.2."
vpcCidrSuf = ".0/24"
subnetNamePre = "rds-subnet"
# subnets = [[subnetNamePre, "us-east-1a", "1"], [subnetNamePre, "us-east-1b", "2"], [subnetNamePre, "us-east-1c", "3"], [subnetNamePre, "us-east-1d", "4"], [subnetNamePre, "us-east-1e", "5"], [subnetNamePre, "us-east-1f", "6"]]
subnets = [[subnetNamePre, "us-east-1a", "1"], [subnetNamePre, "us-east-1b", "2"]]
for sn in subnets:
        sn[2] = vpcCidrPre + sn[2] + vpcCidrSuf


# # subnet group name
subnetGroupName = "rds-subnet-grp-002"
subnetGroupDesc = "subnet group for rds server"

# internet gateway name
igwName = "igw-rds-004"

# security group name
sgName = "rds-sg-002"
sgDesc = "security group for rds db"

# my computer IP for connectivity
myIp = "218.212.131.143/32"

# rds Details
rdsName = "rds-db-script-002"
rdsInstance = "db.t3.micro"

# $dbEngine = "mysql"
dbEngine = "sqlserver-ex"
dbSubnetGroup = subnetGroupName
dbSecurityGroups = sgName
username = "admin"
password = "benjamin_123"


configFile = "deployment.log"
configVars = ["status", "createdVPC", "createdSubnet", "createdSubnetGroup", "createdIGW", "createdRouteTbl", "createdSecurityGroup", "createdRDSdb"]
configDefault = {
    "status": "not started",
    "createdVPC": False,
    "createdSubnet": False,
    "createdSubnetGroup": False,
    "createdIGW": False,
    "createdRouteTbl": False,
    "createdSecurityGroup": False,
    "createdRDSdb": False,
}


# add config items if not added
def checkConfigHasValues(configs):
    for config in configVars:
        if not config in configs:
            print(config, "not found, adding")
            configs[config] = configDefault[config]
        else:
            print(config, "found, no action")
    return configs

# retreive the config
def getConfig(configFile):
    if os.path.isfile(configFile):
        config = readJSONFile(configFile)
        config = checkConfigHasValues(config)
    else:
        config = configDefault    
    return config

# save the config
def saveConfig(configFile, data):
    writeJSONFile(configFile, data)

configs = getConfig(configFile)
print("-------------read initial-------------------")
print(type(configs))
print(configs)
print("-------------updated some values-------------------")
configs['status'] = "in progress"
configs['createdSubnet'] = True
del configs['createdVPC']
print(configs)
print("-------------save & read-------------------")
saveConfig(configFile, configs)
print("-------------retrieve saved file-------------------")
configs = getConfig(configFile)
print(configs)
quit()
    


# # # check if to create
# runCreateVPC = False
# runCreateSubnet = False
# runCreateSubnetGroup = False
# runCreateIGW = False
# runCreateRouteTbl = False
# runCreateSecurityGroup = False
# runCreateRDSdb = True


# vpc - enable hostname and resolution
if (runCreateVPC):
    print("Creating VPC")
    vpcId = createVPC(vpcName, vpcCidr)
    configCreated[vpcId] = vpcId
    print("Creating VPC done")
else:
    print("Skipping VPC")
    vpcId = "vpc-04a0b322e0cfe66b6"

# subnets
if (runCreateSubnet):
    print("Creating Subnet(s)")
    subnetIds = createSubnets(vpcId, subnets)
    configCreated[subnetIds] = subnetIds
    print("Creating Subnet(s) done")
else:
    print("Skipping Subnet")
    # add code to retreive subnet Ids
    subnetIds = ["subnet-072b4fc215fe55e22", "subnet-096b19668fc5ef9b4"]

# rds subnet group
if (runCreateSubnetGroup):
    print( "Creating Subnet Group")
    subnetGroupId = createSubnetGroup(subnetGroupName, subnetGroupDesc, subnetIds)
    configCreated[subnetGroupId] = subnetGroupId
    print(f"{subnetGroupId}")
else:
    # add code to retreive subnet group
    print( "Skipping Subnet Group")
    # $subnetGroupId

# # internet gateway
if (runCreateIGW):
    print("Creating IGW")
    igwId = createIGW(igwName, vpcId)
    configCreated[igwId] = igwId
    print(f"Created IGW: {igwId}")
else:
    print("Skipping IGW")
    # igwId = "igw-0c52b04fd9e26666c"

# #  route table
if (runCreateRouteTbl):
    print( "Creating Route Table")
    routeTableId = createRouteTbl(vpcId, igwId)
    configCreated[routeTableId] = routeTableId
    print(f"Created Route Table: {routeTableId}")
else:
    print( "Skipping Route Table")
    # $routeTableId

# # security group & rules
if (runCreateSecurityGroup):
    print("Creating Security Group")
    securityGroup = createSG(sgName, sgDesc, myIp)
    configCreated[securityGroup] = securityGroup
    # securityGroup = createSG(sgName, sgDesc, subnetIds, myIp)
    print(f"Created Security Group: {securityGroup}")
else:
    print( "Skipping Security Group")
    # securityGroup= "sg-0e2aa8cf850166667"


# rds db
if (runCreateRDSdb):
    print( "Creating RDS Db")
    rdsDBArn = createRDSdb(rdsName, rdsInstance, dbEngine, dbSubnetGroup, dbSecurityGroups, username, password)
    configCreated[rdsDBArn] = rdsDBArn
    print(f"Created RDS Db: {rdsDBArn}")
else:
    print( "Skipping RDS Db")

