import subprocess
import json


def createSubnetGroup(groupName, groupDesc, subnetIds):

        # rules 
        obj = "Subnet Group"
        print(f"{obj} Creating obj")

        print("-------Creating Group---------")
        print(f"name: {groupName}")
        print(f"desc: {groupDesc}")
        print(f"subnetIds: {subnetIds}")
        strList = "['" + "', '".join(map(str,subnetIds)) + "']"
        print(f"subnetIds: {strList}")

        
 
        # output = subprocess.check_output(["aws", "ec2", "create-subnet", "--vpc-id", vpcId, \
        #                                         "--cidr-block", subnet[2], "--availability-zone", subnet[1] \
        #                                         ]) 
        output = subprocess.check_output(["aws", "rds", "create-db-subnet-group" \
                                          ,"--db-subnet-group-name", groupName \
                                          ,"--db-subnet-group-description", groupDesc \
                                          ,"--subnet-ids", strList \
                                        ]) 
        # output = subprocess.check_output(["aws", "rds", "create-db-subnet-group" \
        #                                   ,"--db-subnet-group-name", groupName \
        #                                   ,"--db-subnet-group-description", groupDesc \
        #                                   ,"--subnet-ids", subnetIds \
        #                                 ]) 
        
        snOutput = json.loads(output)
        subnetGroupArn = snOutput["DBSubnetGroup"]["DBSubnetGroupArn"]
        print(f"{obj} Created: {subnetGroupArn}")

        return subnetGroupArn

# {
#     "DBSubnetGroup": {
#         "DBSubnetGroupName": "subnetgroup2",
#         "DBSubnetGroupDescription": "subnetgroup2",
#         "VpcId": "vpc-0f11c718a52403578",
#         "SubnetGroupStatus": "Complete",
#         "Subnets": [
#             {
#                 "SubnetIdentifier": "subnet-01444aeb3aa04fa8f",
#                 "SubnetAvailabilityZone": {
#                     "Name": "us-east-1a"
#                 },
#                 "SubnetOutpost": {},
#                 "SubnetStatus": "Active"
#             },
#             {
#                 "SubnetIdentifier": "subnet-041e26797b328dba4",
#                 "SubnetAvailabilityZone": {
#                     "Name": "us-east-1b"
#                 },
#                 "SubnetOutpost": {},
#                 "SubnetStatus": "Active"
#             }
#         ],
#         "DBSubnetGroupArn": "arn:aws:rds:us-east-1:946229218607:subgrp:subnetgroup2"
#     }
# }