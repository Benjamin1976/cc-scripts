$sgName = $args[0]
$sgDesc = $args[1]
$myIp = $args[3]

# rules 
$obj = "Security Group"
Write-Output "[$obj] Creating $obj"
Write-Output "name: $sgName"
Write-Output "desc: $sgDesc"

# security groups
$sgName = "Security Group Name"
$sgDesc = "Security Group Desc"
# $json = aws ec2 create-security-group --group-name $sgName --description $sgDesc | ConvertFrom-Json
$groupId = $json.GroupId

# $groupId = "sg-0e2aa8cf850166667"
# $myIp = "218.212.131.143/32"

# security group rule
$json = aws ec2 authorize-security-group-ingress `
    --group-id $groupId `
    --protocol tcp `
    --port 1433 `
    --cidr $myIp `
    | ConvertFrom-Json

$json
Write-Output "[$obj] Created: $groupId"

return $groupId


# https://awscli.amazonaws.com/v2/documentation/api/2.0.33/reference/ec2/authorize-security-group-ingress.html

# {
#         "GroupId": "sg-903004f8"
# }



# security group rule - multiple rules
# aws ec2 authorize-security-group-ingress
# –group-id sg-1234567890abcdef0 
#               –ip-permissions IpProtocol=tcp,FromPort=3389,ToPort=3389,IpRanges=”[{CidrIp=172.31.0.0/16}]” `
#                               IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges=”[{CidrIp=172.31.0.0/16}]”

# security group rule - single port
# aws ec2 authorize-security-group-ingress \
#     --group-id $groupId\
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