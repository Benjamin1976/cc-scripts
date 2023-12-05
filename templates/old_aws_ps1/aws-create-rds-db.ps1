$rdsName = $args[0]
$rdsInstance = $args[1]
$dbEngine = $args[2]
$dbSubnetGroup = $args[3]
$dbSecurityGroups = $args[4]
$username = $args[5]
$password = $args[6]

$dbSgList = New-Object Collections.Generic.List[String]
$dbSecurityGroups  | ForEach-Object {$dbSgList.Add($_)}


# rules 
$obj = "RDS Database"
Write-Output "[$obj] Creating $obj"

Write-Output "-------Creating Group---------"
Write-Output "name: $groupName"
Write-Output "desc: $groupDesc"
Write-Output "subnets: $subnetIdsString"

$json = aws rds create-db-instance `
        --db-instance-identifier $rdsName `
        --db-instance-class $rdsInstance `
        --engine $dbEngine `
        --master-username $username `
        --master-user-password $password `
        --allocated-storage 20 `
        --db-subnet-group-name $dbSubnetGroup `
        --vpc-security-group-ids $dbSgList `
        | ConvertFrom-Json

$json
$rdsArn = $json.DBInstance.DBInstanceArn
Write-Output "[$obj] Created: $rdsArn"

return $rdsArn


# aurora-mysql (for Aurora MySQL DB instances)
# aurora-postgresql (for Aurora PostgreSQL DB instances)
# custom-oracle-ee (for RDS Custom for Oracle DB instances)
# custom-oracle-ee-cdb (for RDS Custom for Oracle DB instances)
# custom-sqlserver-ee (for RDS Custom for SQL Server DB instances)
# custom-sqlserver-se (for RDS Custom for SQL Server DB instances)
# custom-sqlserver-web (for RDS Custom for SQL Server DB instances)
# mariadb
# mysql
# oracle-ee
# oracle-ee-cdb
# oracle-se2
# oracle-se2-cdb
# postgres
# sqlserver-ee
# sqlserver-se
# sqlserver-ex
# sqlserver-web



# {
#         "DBInstance": {
#             "DBInstanceIdentifier": "test-mysql-instance",
#             "DBInstanceClass": "db.t3.micro",
#             "Engine": "mysql",
#             "DBInstanceStatus": "creating",
#             "MasterUsername": "admin",
#             "AllocatedStorage": 20,
#             "PreferredBackupWindow": "12:55-13:25",
#             "BackupRetentionPeriod": 1,
#             "DBSecurityGroups": [],
#             "VpcSecurityGroups": [
#                 {
#                     "VpcSecurityGroupId": "sg-12345abc",
#                     "Status": "active"
#                 }
#             ],
#             "DBParameterGroups": [
#                 {
#                     "DBParameterGroupName": "default.mysql5.7",
#                     "ParameterApplyStatus": "in-sync"
#                 }
#             ],
#             "DBSubnetGroup": {
#                 "DBSubnetGroupName": "default",
#                 "DBSubnetGroupDescription": "default",
#                 "VpcId": "vpc-2ff2ff2f",
#                 "SubnetGroupStatus": "Complete",
#                 "Subnets": [
#                     {
#                         "SubnetIdentifier": "subnet-########",
#                         "SubnetAvailabilityZone": {
#                             "Name": "us-west-2c"
#                         },
#                         "SubnetStatus": "Active"
#                     },
#                     {
#                         "SubnetIdentifier": "subnet-########",
#                         "SubnetAvailabilityZone": {
#                             "Name": "us-west-2d"
#                         },
#                         "SubnetStatus": "Active"
#                     },
#                     {
#                         "SubnetIdentifier": "subnet-########",
#                         "SubnetAvailabilityZone": {
#                             "Name": "us-west-2a"
#                         },
#                         "SubnetStatus": "Active"
#                     },
#                     {
#                         "SubnetIdentifier": "subnet-########",
#                         "SubnetAvailabilityZone": {
#                             "Name": "us-west-2b"
#                         },
#                         "SubnetStatus": "Active"
#                     }
#                 ]
#             },
#             "PreferredMaintenanceWindow": "sun:08:07-sun:08:37",
#             "PendingModifiedValues": {
#                 "MasterUserPassword": "****"
#             },
#             "MultiAZ": false,
#             "EngineVersion": "5.7.22",
#             "AutoMinorVersionUpgrade": true,
#             "ReadReplicaDBInstanceIdentifiers": [],
#             "LicenseModel": "general-public-license",
#             "OptionGroupMemberships": [
#                 {
#                     "OptionGroupName": "default:mysql-5-7",
#                     "Status": "in-sync"
#                 }
#             ],
#             "PubliclyAccessible": true,
#             "StorageType": "gp2",
#             "DbInstancePort": 0,
#             "StorageEncrypted": false,
#             "DbiResourceId": "db-5555EXAMPLE44444444EXAMPLE",
#             "CACertificateIdentifier": "rds-ca-2019",
#             "DomainMemberships": [],
#             "CopyTagsToSnapshot": false,
#             "MonitoringInterval": 0,
#             "DBInstanceArn": "arn:aws:rds:us-west-2:123456789012:db:test-mysql-instance",
#             "IAMDatabaseAuthenticationEnabled": false,
#             "PerformanceInsightsEnabled": false,
#             "DeletionProtection": false,
#             "AssociatedRoles": []
#         }
#     }


# create-db-instance
# [--db-name <value>]
# --db-instance-identifier <value>
# [--allocated-storage <value>]
# --db-instance-class <value>
# --engine <value>
# [--master-username <value>]
# [--master-user-password <value>]
# [--db-security-groups <value>]
# [--vpc-security-group-ids <value>]
# [--availability-zone <value>]
# [--db-subnet-group-name <value>]
# [--preferred-maintenance-window <value>]
# [--db-parameter-group-name <value>]
# [--backup-retention-period <value>]
# [--preferred-backup-window <value>]
# [--port <value>]
# [--multi-az | --no-multi-az]
# [--engine-version <value>]
# [--auto-minor-version-upgrade | --no-auto-minor-version-upgrade]
# [--license-model <value>]
# [--iops <value>]
# [--option-group-name <value>]
# [--character-set-name <value>]
# [--nchar-character-set-name <value>]
# [--publicly-accessible | --no-publicly-accessible]
# [--tags <value>]
# [--db-cluster-identifier <value>]
# [--storage-type <value>]
# [--tde-credential-arn <value>]
# [--tde-credential-password <value>]
# [--storage-encrypted | --no-storage-encrypted]
# [--kms-key-id <value>]
# [--domain <value>]
# [--domain-fqdn <value>]
# [--domain-ou <value>]
# [--domain-auth-secret-arn <value>]
# [--domain-dns-ips <value>]
# [--copy-tags-to-snapshot | --no-copy-tags-to-snapshot]
# [--monitoring-interval <value>]
# [--monitoring-role-arn <value>]
# [--domain-iam-role-name <value>]
# [--promotion-tier <value>]
# [--timezone <value>]
# [--enable-iam-database-authentication | --no-enable-iam-database-authentication]
# [--enable-performance-insights | --no-enable-performance-insights]
# [--performance-insights-kms-key-id <value>]
# [--performance-insights-retention-period <value>]
# [--enable-cloudwatch-logs-exports <value>]
# [--processor-features <value>]
# [--deletion-protection | --no-deletion-protection]
# [--max-allocated-storage <value>]
# [--enable-customer-owned-ip | --no-enable-customer-owned-ip]
# [--custom-iam-instance-profile <value>]
# [--backup-target <value>]
# [--network-type <value>]
# [--storage-throughput <value>]
# [--manage-master-user-password | --no-manage-master-user-password]
# [--master-user-secret-kms-key-id <value>]
# [--ca-certificate-identifier <value>]
# [--db-system-id <value>]
# [--dedicated-log-volume | --no-dedicated-log-volume]
# [--multi-tenant | --no-multi-tenant]
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