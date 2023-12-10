
import subprocess
import json
from general import findAWSObj

def createVPC (args):
    debug = False

    obj = "VPC"
    specs = {"obj": "VPC", "branch": "Vpcs", "commands" :["aws", "ec2", "describe-vpcs"], 
                "var": "vpcName", "vpcCidr": args['vpcCidr'], "vpcName": args['vpcName'],  "returnVar": "VpcId"}
    rules = [{"dataVar": "Name", "passedVar": "vpcName"},
              {"dataVar": "CidrBlock", "passedVar": "vpcCidr"}]    
    
    print(f"[{obj}] Checking if {obj} exists")
    vpcId = findAWSObj(specs, rules)

    if vpcId: 
      print(f"[{obj}] exists, skipping.")    
    else:
      print(f"[{obj}] Creating {obj}: {args['vpcName']}")

      tags = f"{{Key=Name, Value={args['vpcName']}}}"
      output = subprocess.check_output(["aws", "ec2", "create-vpc", "--cidr-block", args['vpcCidr'] \
                                      , "--tag-specification", f"ResourceType=vpc,Tags=[{tags}]" \
                                        ]) 
      vpcData = json.loads(output)
      vpcId = vpcData['Vpc']['VpcId']
      print(f"[{obj}] Created vpc: {vpcId}")

      # Write-Output $json.Vpc.VpcId
      print(f"[{obj}] Modifying: {args['vpcName']}")
      output = subprocess.check_output(["aws", "ec2", "modify-vpc-attribute", "--vpc-id", vpcId, "--enable-dns-hostnames", '{\"Value\": true}']) 
      print(f"[{obj}] Modified: {args['vpcName']}")

    return vpcId

def createVPCs (args):
    debug = False
   
    obj = "VPC"
    for arg in args:
      vpcId = createVPC({"vpcName": arg["vpcName"], "vpcCidr": arg["vpcCidr"]})
      arg["vpcId"] = vpcId

    return args

    # specs = {"obj": "VPC", "branch": "Vpcs", "commands" :["aws", "ec2", "describe-vpcs"], 
    #             "var": "vpcName", "vpcCidr": args['vpcCidr'], "vpcName": args['vpcName'],  "returnVar": "VpcId"}
    # rules = [{"dataVar": "Name", "passedVar": "vpcName"},
    #           {"dataVar": "CidrBlock", "passedVar": "vpcCidr"}]    
    
    # print(f"[{obj}] Checking if {obj} exists")
    # vpcId = findAWSObj(specs, rules)

    # if vpcId: 
    #   print(f"[{obj}] exists, skipping.")    
    # else:
    #   print(f"[{obj}] Creating {obj}: {args['vpcName']}")

    #   tags = f"{{Key=Name, Value={args['vpcName']}}}"
    #   output = subprocess.check_output(["aws", "ec2", "create-vpc", "--cidr-block", args['vpcCidr'] \
    #                                   , "--tag-specification", f"ResourceType=vpc,Tags=[{tags}]" \
    #                                     ]) 
    #   vpcData = json.loads(output)
    #   vpcId = vpcData['Vpc']['VpcId']
    #   print(f"[{obj}] Created vpc: {vpcId}")

    #   # Write-Output $json.Vpc.VpcId
    #   print(f"[{obj}] Modifying: {args['vpcName']}")
    #   output = subprocess.check_output(["aws", "ec2", "modify-vpc-attribute", "--vpc-id", vpcId, "--enable-dns-hostnames", '{\"Value\": true}']) 
    #   print(f"[{obj}] Modified: {args['vpcName']}")

    return vpcId






# aws ec2 create-vpc \
    # --cidr-block 10.0.0.0/16 \
    # --tag-specification ResourceType=vpc,Tags=[{Key=Name,Value=MyVpc}]

# https://docs.aws.amazon.com/cli/latest/reference/ec2/create-vpc.html

# create-vpc
# [--cidr-block <value>]
# [--amazon-provided-ipv6-cidr-block | --no-amazon-provided-ipv6-cidr-block]
# [--ipv6-pool <value>]
# [--ipv6-cidr-block <value>]
# [--ipv4-ipam-pool-id <value>]
# [--ipv4-netmask-length <value>]
# [--ipv6-ipam-pool-id <value>]
# [--ipv6-netmask-length <value>]
# [--dry-run | --no-dry-run]
# [--instance-tenancy <value>]
# [--ipv6-cidr-block-network-border-group <value>]
# [--tag-specifications <value>]
# [--cli-input-json <value>]
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
#      "Vpc": {
#          "CidrBlock": "10.0.1.0/24",
#          "DhcpOptionsId": "dopt-2afccf50",
#          "State": "pending",
#          "VpcId": "vpc-010e1791024eb0af9",
#          "OwnerId": "123456789012",
#          "InstanceTenancy": "default",
#          "Ipv6CidrBlockAssociationSet": [],
#          "CidrBlockAssociationSet": [
#              {
#                  "AssociationId": "vpc-cidr-assoc-0a77de1d803226d4b",
#                  "CidrBlock": "10.0.1.0/24",
#                  "CidrBlockState": {
#                      "State": "associated"
#                  }
#              }
#          ],
#          "IsDefault": false,
#          "Tags": [
#              {
#                  "Key": "Environment",
#                  "Value": "Preprod"
#              },
#              {
#                  "Key": "Owner",
#                  "Value": "Build Team"
#              }
#          ]
#      }
#  }


# aws ec2 wait vpc-exists \
#     --vpc-ids vpc-1234567890abcdef0

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/wait/vpc-exists.html

#  vpc-exists
# [--filters <value>]
# [--vpc-ids <value>]
# [--dry-run | --no-dry-run]
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





# aws ec2 describe-vpcs

# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html#output

# {
#     "Vpcs": [
#         {
#             "CidrBlock": "30.1.0.0/16",
#             "DhcpOptionsId": "dopt-19edf471",
#             "State": "available",
#             "VpcId": "vpc-0e9801d129EXAMPLE",
#             "OwnerId": "111122223333",
#             "InstanceTenancy": "default",
#             "CidrBlockAssociationSet": [
#                 {
#                     "AssociationId": "vpc-cidr-assoc-062c64cfafEXAMPLE",
#                     "CidrBlock": "30.1.0.0/16",
#                     "CidrBlockState": {
#                         "State": "associated"
#                     }
#                 }
#             ],
#             "IsDefault": false,
#             "Tags": [
#                 {
#                     "Key": "Name",
#                     "Value": "Not Shared"
#                 }
#             ]
#         },
#         {
#             "CidrBlock": "10.0.0.0/16",
#             "DhcpOptionsId": "dopt-19edf471",
#             "State": "available",
#             "VpcId": "vpc-06e4ab6c6cEXAMPLE",
#             "OwnerId": "222222222222",
#             "InstanceTenancy": "default",
#             "CidrBlockAssociationSet": [
#                 {
#                     "AssociationId": "vpc-cidr-assoc-00b17b4eddEXAMPLE",
#                     "CidrBlock": "10.0.0.0/16",
#                     "CidrBlockState": {
#                         "State": "associated"
#                     }
#                 }
#             ],
#             "IsDefault": false,
#             "Tags": [
#                 {
#                     "Key": "Name",
#                     "Value": "Shared VPC"
#                 }
#             ]
#         }
#     ]
# }


# aws ec2 describe-vpcs \
#     --vpc-ids vpc-06e4ab6c6cEXAMPL

# {
#     "Vpcs": [
#         {
#             "CidrBlock": "10.0.0.0/16",
#             "DhcpOptionsId": "dopt-19edf471",
#             "State": "available",
#             "VpcId": "vpc-06e4ab6c6cEXAMPLE",
#             "OwnerId": "111122223333",
#             "InstanceTenancy": "default",
#             "CidrBlockAssociationSet": [
#                 {
#                     "AssociationId": "vpc-cidr-assoc-00b17b4eddEXAMPLE",
#                     "CidrBlock": "10.0.0.0/16",
#                     "CidrBlockState": {
#                         "State": "associated"
#                     }
#                 }
#             ],
#             "IsDefault": false,
#             "Tags": [
#                 {
#                     "Key": "Name",
#                     "Value": "Shared VPC"
#                 }
#             ]
#         }
#     ]
# }