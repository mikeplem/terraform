# RDS Bastion Server

I am testing the process to access an RDS database without needing a VPN or some other zero trust system. [AWS has documented this process](https://aws.amazon.com/blogs/database/securely-connect-to-an-amazon-rds-or-amazon-ec2-database-instance-remotely-with-your-preferred-gui/) and I think this is an interesting way to use AWS native facilities to reach a database from a personal computer.

I have been able to successfully get the bastion hop to work. I am using a Bash shell helper function to make the connection to the EC2 bastion and RDS database.

## Why this matters

It is not necessary to connect to a VPN or some other service to be able to reach a RDS database on a private subnet. The EC2 instance as zero inbound ports so that server has a very small surface area when it comes to network exposure. The RDS database only needs subnet to allow private subnets to access it.

## Connection Example

This is how the helper shell functions works.

```
❯ rds_proxy_port rds_bastion rds 5432 5432

Starting session with SessionId: plemmonsapi-05070904055738489
Port 5432 opened for sessionId plemmonsapi-05070904055738489.
Waiting for connections...

Connection accepted for session [plemmonsapi-05070904055738489]
```

Here is what the localhost `psql` command looks like

```
❯ psql -h localhost -U root postgres
Password for user root: 
psql (14.6 (Ubuntu 14.6-0ubuntu0.22.04.1))
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

postgres=> 
```

## RDS Bastion Shell Helper

This function takes 4 arguments

* Any tag value of the EC2 basion host
* The tag value of the `Name` key of the RDS database instance
* The local port number to listen on
* The port the RDS database is listening on

```
function rds_proxy_port {
  local filter
  local EC2ID

  case "${1}" in
    10*)
    filter="Name=network-interface.addresses.private-ip-address,Values=${1}"
    ;;
    i-*)
    filter="Name=instance-id,Values=${1}"
    ;;
    *)
    filter="Name=tag-value,Values=${1}"
    ;;
  esac

  EC2ID=$(aws ec2 describe-instances --filters "${filter}" Name=instance-state-name,Values=running --query 'Reservations[].Instances[].InstanceId' --output text)

  RDSARN=$(aws resourcegroupstaggingapi get-resources --resource-type-filters rds:db --tag-filters "Key=Name,Values=${2}" --query 'ResourceTagMappingList[].ResourceARN' --output text)

  RDSID=$(aws rds describe-db-instances --filters "Name=db-instance-id,Values=${RDSARN}" | jq -r '.DBInstances[].Endpoint.Address')

  [ -n "${EC2ID}" ] && aws ssm start-session \
    --region us-east-1 \
    --target "${EC2ID}" \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters host="${RDSID}",portNumber="${4}",localPortNumber="${3}" || echo "Instance not found"
}

```
