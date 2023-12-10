import subprocess
import json
from general import findAWSObj

def createSG(args):
    
    debug = True
    sgName = args["sgName"]
    sgDesc = args["sgDesc"]
    vpcId = args["vpcId"]
    myIp = args["myIp"]

    # rules 
    obj = "Security Group"
    specs = {"obj": obj, "branch": "SecurityGroups", "commands" :["aws", "ec2", "describe-security-groups"], 
                    "var": "sgName", "sgName": sgName, "returnVar": "GroupId"}
    rules = [{"dataVar": "GroupName", "passedVar": "sgName"}]    
    
    print(f"-------Checking if {obj} exists---------")
    groupId = findAWSObj(specs, rules)       

    if groupId: 
        print(f"[{obj}] exists, exiting")    
    else:    
        try:
            if debug: print(f"[{obj}] Creating {obj}")
            if debug: print(f"   name: {sgName}")
            if debug: print(f"   desc: {sgDesc}")

            # security groups
            output = subprocess.check_output(["aws", "ec2", "create-security-group", "--vpc-id", vpcId \
                                              , "--group-name", sgName, "--description", sgDesc])
            sgOutput = json.loads(output)
            groupId = sgOutput['GroupId']

            # security group rule
            output = subprocess.check_output(["aws", "ec2", "authorize-security-group-ingress" \
                                    , "--group-id", groupId, "--protocol", "tcp" \
                                    , "--port", "1433", "--cidr", myIp])
            
            print(f"[{obj}] Created: {groupId}")

        except Exception as err:
                print(f"Unexpected {err=}, {type(err)=}")
                raise

    return groupId



# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-security-groups.html

# aws ec2 describe-security-groups \
#     --group-ids sg-903004f8

#   describe-security-groups
# [--filters <value>]
# [--group-ids <value>]
# [--group-names <value>]
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

# {
#     "SecurityGroups": [
#         {
#             "IpPermissionsEgress": [
#                 {
#                     "IpProtocol": "-1",
#                     "IpRanges": [
#                         {
#                             "CidrIp": "0.0.0.0/0"
#                         }
#                     ],
#                     "UserIdGroupPairs": [],
#                     "PrefixListIds": []
#                 }
#             ],
#             "Description": "My security group",
#             "Tags": [
#                 {
#                     "Value": "SG1",
#                     "Key": "Name"
#                 }
#             ],
#             "IpPermissions": [
#                 {
#                     "IpProtocol": "-1",
#                     "IpRanges": [],
#                     "UserIdGroupPairs": [
#                         {
#                             "UserId": "123456789012",
#                             "GroupId": "sg-903004f8"
#                         }
#                     ],
#                     "PrefixListIds": []
#                 },
#                 {
#                     "PrefixListIds": [],
#                     "FromPort": 22,
#                     "IpRanges": [
#                         {
#                             "Description": "Access from NY office",
#                             "CidrIp": "203.0.113.0/24"
#                         }
#                     ],
#                     "ToPort": 22,
#                     "IpProtocol": "tcp",
#                     "UserIdGroupPairs": []
#                     }
#             ],
#             "GroupName": "MySecurityGroup",
#             "VpcId": "vpc-1a2b3c4d",
#             "OwnerId": "123456789012",
#             "GroupId": "sg-903004f8",
#         }
#     ]
# }


# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-security-group.html

    # aws ec2 create-security-group --group-name MySecurityGroup --description "My security group"

    #   create-security-group
    # --description <value>
    # --group-name <value>
    # [--vpc-id <value>]
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
    #     "GroupId": "sg-903004f8"
    # }


#     https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-security-group-rules.html

# aws ec2 describe-security-group-rules \
#     --filters Name="group-id",Values="sg-1234567890abcdef0"

#     describe-security-group-rules
#     [--filters <value>]
#     [--security-group-rule-ids <value>]
#     [--dry-run | --no-dry-run]
#     [--cli-input-json | --cli-input-yaml]
#     [--starting-token <value>]
#     [--page-size <value>]
#     [--max-items <value>]
#     [--generate-cli-skeleton <value>]
#     [--debug]
#     [--endpoint-url <value>]
#     [--no-verify-ssl]
#     [--no-paginate]
#     [--output <value>]
#     [--query <value>]
#     [--profile <value>]
#     [--region <value>]
#     [--version <value>]
#     [--color <value>]
#     [--no-sign-request]
#     [--ca-bundle <value>]
#     [--cli-read-timeout <value>]
#     [--cli-connect-timeout <value>]
#     [--cli-binary-format <value>]
#     [--no-cli-pager]
#     [--cli-auto-prompt]
#     [--no-cli-auto-prompt]


#     {
#         "SecurityGroupRules": [
#             {
#                 "SecurityGroupRuleId": "sgr-abcdef01234567890",
#                 "GroupId": "sg-1234567890abcdef0",
#                 "GroupOwnerId": "111122223333",
#                 "IsEgress": false,
#                 "IpProtocol": "-1",
#                 "FromPort": -1,
#                 "ToPort": -1,
#                 "ReferencedGroupInfo": {
#                     "GroupId": "sg-1234567890abcdef0",
#                     "UserId": "111122223333"
#                 },
#                 "Tags": []
#             },
#             {
#                 "SecurityGroupRuleId": "sgr-bcdef01234567890a",
#                 "GroupId": "sg-1234567890abcdef0",
#                 "GroupOwnerId": "111122223333",
#                 "IsEgress": true,
#                 "IpProtocol": "-1",
#                 "FromPort": -1,
#                 "ToPort": -1,
#                 "CidrIpv6": "::/0",
#                 "Tags": []
#             },
#             {
#                 "SecurityGroupRuleId": "sgr-cdef01234567890ab",
#                 "GroupId": "sg-1234567890abcdef0",
#                 "GroupOwnerId": "111122223333",
#                 "IsEgress": true,
#                 "IpProtocol": "-1",
#                 "FromPort": -1,
#                 "ToPort": -1,
#                 "CidrIpv4": "0.0.0.0/0",
#                 "Tags": []
#             }
#         ]
#     }




# https://awscli.amazonaws.com/v2/documentation/api/2.0.33/reference/ec2/authorize-security-group-ingress.html

# security group rule - multiple rules
# aws ec2 authorize-security-group-ingress
# –group-id sg-1234567890abcdef0 
#               –ip-permissions IpProtocol=tcp,FromPort=3389,ToPort=3389,IpRanges=”[{CidrIp=172.31.0.0/16}]” `
#                               IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges=”[{CidrIp=172.31.0.0/16}]”

# security group rule - single port
# aws ec2 authorize-security-group-ingress \
#     --group-id groupId\
#     --protocol tcp \
#     --port 22 \
#     --cidr 203.0.113.0/24

# security group rule - between security groups
# aws ec2 authorize-security-group-ingress \
#     --group-id sg-1234567890abcdef0 \
#     --protocol tcp \
#     --port 80 \
#     --source-group sg-1a2b3c4d


# security group rule - icmp
# aws ec2 authorize-security-group-ingress
# –group-id sg-1234567890abcdef0 –ip-permissions IpProtocol=icmp,FromPort=3,ToPort=4,IpRanges=”[{CidrIp=0.0.0.0/0}]”

# security group rule - with description
# aws ec2 authorize-security-group-ingress
# –group-id sg-1234567890abcdef0 –ip-permissions IpProtocol=tcp,FromPort=3389,ToPort=3389,IpRanges=”[{CidrIp=203.0.113.0/24,Description=’RDP access from NY office’}]”


#   authorize-security-group-ingress
# [--group-id <value>]
# [--group-name <value>]
# [--ip-permissions <value>]
# [--dry-run | --no-dry-run]
# [--protocol <value>]
# [--port <value>]
# [--cidr <value>]
# [--source-group <value>]
# [--group-owner <value>]
# [--cli-input-json | --cli-input-yaml]
# [--generate-cli-skeleton <value>]
# [--cli-auto-prompt <value>]

# Output¶
# None







#   authorize-security-group-ingress
# [--group-id <value>]
# [--group-name <value>]
# [--ip-permissions <value>]
# [--dry-run | --no-dry-run]
# [--protocol <value>]
# [--port <value>]
# [--cidr <value>]
# [--source-group <value>]
# [--group-owner <value>]
# [--cli-input-json | --cli-input-yaml]
# [--generate-cli-skeleton <value>]
# [--cli-auto-prompt <value>]