
import subprocess
import json
from .general import findAWSObj

def createIGW(args):

	debug = True
	igwName = args["igwName"]
	vpcId = args["vpcId"]
	region = args["region"]

	# rules 
	obj = "Internet Gateway"
	specs = {"obj": obj, "branch": "InternetGateways", "commands" :["aws", "ec2", "describe-internet-gateways", "--region", region], 
					"var": "igwName", "igwName": igwName, "returnVar": "InternetGatewayId"}
	rules = [{"branch": "InternetGateways", "dataVar": "Name", "passedVar": "igwName"}]    

	print( f"[{obj}] Checking if", specs['obj'], "exists")
	igwId = findAWSObj(specs, rules)        

	if igwId: 
		print(f"[{obj}] exists, skipping.")    
	else:    
		print(f"[{obj}] Creating {obj}: {igwName}")
		if debug: print(f"   name: {igwName}")
		if debug: print(f"   vpc: {vpcId}")

		try:

			# create internet gateway
			tags = f"{{Key=Name, Value={igwName}}}"
			output = subprocess.check_output(["aws", "ec2", "create-internet-gateway" \
					, "--region", region \
					, "--tag-specifications", f"ResourceType=internet-gateway,Tags=[{tags}]" \
					])

			igwDetails = json.loads(output)
			igwId = igwDetails['InternetGateway']['InternetGatewayId']
			print(f"[{obj}] Created: {igwId}")
			
			print(f"[{obj}] Attaching: {igwId} to {vpcId}")
			# attach internet gateway to vpc
			output = subprocess.check_output(["aws", "ec2", "attach-internet-gateway" \
					, "--internet-gateway-id", igwId \
					, "--vpc-id", vpcId \
					, "--region", region \
					])
			print(f"[{obj}] Attached: {igwId} to {vpcId}")

		except Exception as err:
			print(f"Unexpected {err=}, {type(err)=}")
			raise

			
	return igwId

def createIGWs(args):
    # debug = False
    # obj = "All Subnets"
    for vpc in args['vpcs']:
        igwId = createIGW({"vpcId": vpc["vpcId"], "region": vpc["region"], "igwName": vpc["igw"]["name"]})
        vpc["igw"]['igwId'] = igwId

    return args


# aws ec2 describe-internet-gateways \
#     --internet-gateway-ids igw-0d0fb496b3EXAMPLE

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-internet-gateways.html

#   describe-internet-gateways
# [--filters <value>]
# [--dry-run | --no-dry-run]
# [--internet-gateway-ids <value>]
# [--cli-input-json | --cli-input-yaml]
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
# [--cli-binary-format <value>]
# [--no-cli-pager]
# [--cli-auto-prompt]
# [--no-cli-auto-prompt]

# {
#     "InternetGateways": [
#         {
#             "Attachments": [
#                 {
#                     "State": "available",
#                     "VpcId": "vpc-0a60eb65b4EXAMPLE"
#                 }
#             ],
#             "InternetGatewayId": "igw-0d0fb496b3EXAMPLE",
#             "OwnerId": "123456789012",
#             "Tags": [
#                 {
#                     "Key": "Name",
#                     "Value": "my-igw"
#                 }
#             ]
#         }
#     ]
# }

# aws ec2 create-internet-gateway \
#     --tag-specifications ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-igw}]

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-internet-gateway.html

#   create-internet-gateway
# [--tag-specifications <value>]
# [--dry-run | --no-dry-run]
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
#     "InternetGateway": {
#         "Attachments": [],
#         "InternetGatewayId": "igw-0d0fb496b3994d755",
#         "OwnerId": "123456789012",
#         "Tags": [
#             {
#                 "Key": "Name",
#                 "Value": "my-igw"
#             }
#         ]
#     }
# }


# aws ec2 attach-internet-gateway \
#     --internet-gateway-id igw-0d0fb496b3EXAMPLE \
#     --vpc-id vpc-0a60eb65b4EXAMPLE

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/attach-internet-gateway.html

#   attach-internet-gateway
# [--dry-run | --no-dry-run]
# --internet-gateway-id <value>
# --vpc-id <value>
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

# Output
# None

