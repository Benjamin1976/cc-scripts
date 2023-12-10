import subprocess
import json
from general import findAWSObj


def createSubnetGroup(args):
	debug = True

	groupName = args["groupName"]
	groupDesc = args["groupDesc"]
	subnetIds = args["subnetIds"]

	# rules 
	obj = "Subnet Group"
	if debug: print(f"[{obj}] Creating {obj}")

	specs = {"obj": obj, "branch": "DBSubnetGroups", "commands" :["aws", "rds", "describe-db-subnet-groups"], 
					"var": "groupName", "groupName": groupName, "returnVar": "DBSubnetGroupArn"}
	rules = [{"dataVar": "DBSubnetGroupName", "passedVar": "groupName"}]    

	if debug: print(f"[{obj}] Checking if {obj} exists")
	subnetGroupArn = findAWSObj(specs, rules)

	if subnetGroupArn: 
		print(f"[{obj}] exists, skipping.")              
	else:    
		print(f"[{obj}] Creating {obj}: {groupName}")
		if debug: print(f"    name: {groupName}")
		if debug: print(f"    desc: {groupDesc}")
		if debug: print(f"    subnetIds: {subnetIds}")
		
		subnetList = json.dumps(subnetIds)
		if debug: print(f"[{obj}]    subnetIds: {subnetList}")

		try:
			output = subprocess.check_output(["aws", "rds", "create-db-subnet-group" \
									,"--db-subnet-group-name", groupName \
									,"--db-subnet-group-description", groupDesc \
									,"--subnet-ids", subnetList \
									]) 

			snOutput = json.loads(output)
			subnetGroupArn = snOutput["DBSubnetGroup"]["DBSubnetGroupArn"]
			print(f"[{obj}] Created: {subnetGroupArn}")       
		except Exception as err:
				print(f"Unexpected {err=}, {type(err)=}")
				raise

	return subnetGroupArn



# aws rds describe-db-subnet-groups

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/rds/describe-db-subnet-groups.html#output

# [--db-subnet-group-name <value>]
# [--filters <value>]
# [--cli-input-json <value>]
# [--starting-token <value>]
# [--page-size <value>]
# [--max-items <value>]
# [--generate-cli-skeleton <value>]
# [--debug]
# [--endpoint-url <value>]
# [--no-verify-ssl]
# [--no-paginate]
# [--output <value>]
# [--query <value>]
# [--profile <value>]
# [--region <value>]
# [--version <value>]
# [--color <value>]
# [--no-sign-request]
# [--ca-bundle <value>]
# [--cli-read-timeout <value>]
# [--cli-connect-timeout <value>]


# {
#     "DBSubnetGroups": [
#         {
#             "DBSubnetGroupName": "mydbsubnetgroup",
#             "DBSubnetGroupDescription": "My DB Subnet Group",
#             "VpcId": "vpc-971c12ee",
#             "SubnetGroupStatus": "Complete",
#             "Subnets": [
#                 {
#                     "SubnetIdentifier": "subnet-d8c8e7f4",
#                     "SubnetAvailabilityZone": {
#                         "Name": "us-east-1a"
#                     },
#                     "SubnetStatus": "Active"
#                 },
#                 {
#                     "SubnetIdentifier": "subnet-718fdc7d",
#                     "SubnetAvailabilityZone": {
#                         "Name": "us-east-1f"
#                     },
#                     "SubnetStatus": "Active"
#                 },
#                 {
#                     "SubnetIdentifier": "subnet-cbc8e7e7",
#                     "SubnetAvailabilityZone": {
#                         "Name": "us-east-1a"
#                     },
#                     "SubnetStatus": "Active"
#                 },
#                 {
#                     "SubnetIdentifier": "subnet-0ccde220",
#                     "SubnetAvailabilityZone": {
#                         "Name": "us-east-1a"
#                     },
#                     "SubnetStatus": "Active"
#                 }
#             ],
#             "DBSubnetGroupArn": "arn:aws:rds:us-east-1:123456789012:subgrp:mydbsubnetgroup"
#         }
#     ]
# }


# aws rds create-db-subnet-group \
#     --db-subnet-group-name mysubnetgroup \
#     --db-subnet-group-description "test DB subnet group" \
#     --subnet-ids '["subnet-0a1dc4e1a6f123456","subnet-070dd7ecb3aaaaaaa","subnet-00f5b198bc0abcdef"]'

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/rds/create-db-subnet-group.html

#   create-db-subnet-group
# --db-subnet-group-name <value>
# --db-subnet-group-description <value>
# --subnet-ids <value>
# [--tags <value>]
# [--cli-input-json | --cli-input-yaml]
# [--generate-cli-skeleton <value>]
# [--debug]
# [--endpoint-url <value>]
# [--no-verify-ssl]
# [--no-paginate]
# [--output <value>]
# [--query <value>]
# [--profile <value>]
# [--region <value>]
# [--version <value>]
# [--color <value>]
# [--no-sign-request]
# [--ca-bundle <value>]
# [--cli-read-timeout <value>]
# [--cli-connect-timeout <value>]
# [--cli-binary-format <value>]
# [--no-cli-pager]
# [--cli-auto-prompt]
# [--no-cli-auto-prompt]

# {
#     "DBSubnetGroup": {
#         "DBSubnetGroupName": "mysubnetgroup",
#         "DBSubnetGroupDescription": "test DB subnet group",
#         "VpcId": "vpc-0f08e7610a1b2c3d4",
#         "SubnetGroupStatus": "Complete",
#         "Subnets": [
#             {
#                 "SubnetIdentifier": "subnet-070dd7ecb3aaaaaaa",
#                 "SubnetAvailabilityZone": {
#                     "Name": "us-west-2b"
#                 },
#                 "SubnetStatus": "Active"
#             },
#             {
#                 "SubnetIdentifier": "subnet-00f5b198bc0abcdef",
#                 "SubnetAvailabilityZone": {
#                     "Name": "us-west-2d"
#                 },
#                 "SubnetStatus": "Active"
#             },
#             {
#                 "SubnetIdentifier": "subnet-0a1dc4e1a6f123456",
#                 "SubnetAvailabilityZone": {
#                     "Name": "us-west-2b"
#                 },
#                 "SubnetStatus": "Active"
#             }
#         ],
#         "DBSubnetGroupArn": "arn:aws:rds:us-west-2:0123456789012:subgrp:mysubnetgroup"
#     }
# }