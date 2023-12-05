
import subprocess
import json
from general import findAWSObj

def createRouteTbl(args):

    debug = True
    vpcId = args["vpcId"]
    igwId = args["igwId"]
    name = args["name"]
        
    # rules 
    obj = "Route Table"
    specs = {"obj": obj, "branch": "RouteTables", "commands": ["aws", "ec2", "describe-route-tables", "--filters", f'"Name"="vpc-id","Values"="{vpcId}"'], \
                    "var": "RouteTableId", "RouteTableId": vpcId,  "returnVar": "RouteTableId"}
    rules = [
         {"dataVar": "Routes.GatewayId", "passedVar": "RouteTableId"},
         {"dataVar": "Routes.DestinationCidrBlock", "passedVar": "igwId"}]    


    try:
        # check existing routes
        output = subprocess.check_output(["aws", "ec2", "describe-route-tables", "--filters", f'Name=vpc-id,Values="{vpcId}"'])
        rtOutput = json.loads(output)
        routeTableId = ""

        # check for the main route
        for rt in rtOutput['RouteTables']:
            if len(rt['Associations']) > 0:
                for ass in rt['Associations']:
                    if ass['Main']:
                        routeTableId = rt["RouteTableId"]
            

        if routeTableId: 
            print(f"[{obj}] exists, skipping route table creation")    
            

        else:    
            # create route table
            print(f"[{obj}] Creating {obj}: {igwId}")
            if debug: print(f"    igwId: {igwId}")
            if debug: print(f"    vpc: {vpcId}")

            tags = f"{{Key=Name, Value={name}}}"
            output = subprocess.check_output(["aws", "ec2", "create-route-table", "--vpc-id", vpcId \
                                            , "--tag-specification", f"ResourceType=route-table,Tags=[{tags}]" ])
            
            rtOutput = json.loads(output)
            routeTableId = rtOutput['RouteTable']['RouteTableId']
            print(f"[{obj}] Finished: {routeTableId}")
            
        
        # routes - igw
        obj2 = "IGW route"
        print(f"[{obj2}] Creating: {igwId}")
        output = subprocess.check_output(["aws", "ec2", "create-route", "--route-table-id", routeTableId\
                                , "--destination-cidr-block", "0.0.0.0/0"\
                                , "--gateway-id", igwId])
        if (output): print("igw route created")

        print(f"[{obj2}] Finished: {routeTableId}")
        print(f"[{obj}] Finished: {routeTableId}")

    except Exception as err:
        print(f"Unexpected {err=}, {type(err)=}")
        pass

    return routeTableId

args = {"VpcId": "vpc-0f8e48ac3f31f163c", "igwId" : "igw-0bb250055cd1f500d"}

# aws ec2 describe-route-tables

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-route-tables.html

#   describe-route-tables
# [--filters <value>]
# [--dry-run | --no-dry-run]
# [--route-table-ids <value>]
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
#     "RouteTables": [
#         {
#             "Associations": [
#                 {
#                     "Main": true,
#                     "RouteTableAssociationId": "rtbassoc-0df3f54e06EXAMPLE",
#                     "RouteTableId": "rtb-09ba434c1bEXAMPLE"
#                 }
#             ],
#             "PropagatingVgws": [],
#             "RouteTableId": "rtb-09ba434c1bEXAMPLE",
#             "Routes": [
#                 {
#                     "DestinationCidrBlock": "10.0.0.0/16",
#                     "GatewayId": "local",
#                     "Origin": "CreateRouteTable",
#                     "State": "active"
#                 },
#                 {
#                     "DestinationCidrBlock": "0.0.0.0/0",
#                     "NatGatewayId": "nat-06c018cbd8EXAMPLE",
#                     "Origin": "CreateRoute",
#                     "State": "blackhole"
#                 }
#             ],
#             "Tags": [],
#             "VpcId": "vpc-0065acced4EXAMPLE",
#             "OwnerId": "111122223333"
#         },
#         {
#             "Associations": [
#                 {
#                     "Main": true,
#                     "RouteTableAssociationId": "rtbassoc-9EXAMPLE",
#                     "RouteTableId": "rtb-a1eec7de"
#                 }
#             ],
#             "PropagatingVgws": [],
#             "RouteTableId": "rtb-a1eec7de",
#             "Routes": [
#                 {
#                     "DestinationCidrBlock": "172.31.0.0/16",
#                     "GatewayId": "local",
#                     "Origin": "CreateRouteTable",
#                     "State": "active"
#                 },
#                 {
#                     "DestinationCidrBlock": "0.0.0.0/0",
#                     "GatewayId": "igw-fEXAMPLE",
#                     "Origin": "CreateRoute",
#                     "State": "active"
#                 }
#             ],
#             "Tags": [],
#             "VpcId": "vpc-3EXAMPLE",
#             "OwnerId": "111122223333"
#         },
#         {
#             "Associations": [
#                 {
#                     "Main": false,
#                     "RouteTableAssociationId": "rtbassoc-0b100c28b2EXAMPLE",
#                     "RouteTableId": "rtb-07a98f76e5EXAMPLE",
#                     "SubnetId": "subnet-0d3d002af8EXAMPLE"
#                 }
#             ],
#             "PropagatingVgws": [],
#             "RouteTableId": "rtb-07a98f76e5EXAMPLE",
#             "Routes": [
#                 {
#                     "DestinationCidrBlock": "10.0.0.0/16",
#                     "GatewayId": "local",
#                     "Origin": "CreateRouteTable",
#                     "State": "active"
#                 },
#                 {
#                     "DestinationCidrBlock": "0.0.0.0/0",
#                     "GatewayId": "igw-06cf664d80EXAMPLE",
#                     "Origin": "CreateRoute",
#                     "State": "active"
#                 }
#             ],
#             "Tags": [],
#             "VpcId": "vpc-0065acced4EXAMPLE",
#             "OwnerId": "111122223333"
#         }
#     ]
# }


# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-route-table.html


# create-route-table
# [--dry-run | --no-dry-run]
# --vpc-id <value>
# [--tag-specifications <value>]
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
#     "RouteTable": {
#         "Associations": [],
#         "RouteTableId": "rtb-22574640",
#         "VpcId": "vpc-a01106c2",
#         "PropagatingVgws": [],
#         "Tags": [],
#         "Routes": [
#             {
#                 "GatewayId": "local",
#                 "DestinationCidrBlock": "10.0.0.0/16",
#                 "State": "active"
#             }
#         ]
#     }
# }



# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-route.html


# aws ec2 create-route --route-table-id rtb-22574640 --destination-cidr-block 0.0.0.0/0 
    # --gateway-id igw-c0a643a9

# aws ec2 create-route --route-table-id rtb-g8ff4ea2 --destination-cidr-block 10.0.0.0/16 
#     --vpc-peering-connection-id pcx-1a2b3c4d

# aws ec2 create-route --route-table-id rtb-dce620b8 --destination-ipv6-cidr-block ::/0 
#     --egress-only-internet-gateway-id eigw-01eadbd45ecd7943f

# create-route
# [--destination-cidr-block <value>]
# [--destination-ipv6-cidr-block <value>]
# [--destination-prefix-list-id <value>]
# [--dry-run | --no-dry-run]
# [--vpc-endpoint-id <value>]
# [--egress-only-internet-gateway-id <value>]
# [--gateway-id <value>]
# [--instance-id <value>]
# [--nat-gateway-id <value>]
# [--transit-gateway-id <value>]
# [--local-gateway-id <value>]
# [--carrier-gateway-id <value>]
# [--network-interface-id <value>]
# --route-table-id <value>
# [--vpc-peering-connection-id <value>]
# [--core-network-arn <value>]
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

# Returns true if the request succeeds; otherwise, it returns an error.