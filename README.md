# tf-aws

Terraform modules for AWS resources

Each module declares the region of its provider only. The rest of the aws provider configuration will be inherited.

Modules accept an `env` parameter used for naming resources. Resources will also have a tag `KubernetesCluster` applied with the value of `env` - this shouldn't hurt anything for non-kubernetes resources, but is necessary for kubernetes to discover subnets for dynamic allocations so it is applied everywhere.

## dns

Creates a private hosted zone associated with the given VPC.

## encrypt

Creates a KMS encryption key with a [restrictive policy](encrypt/kms/policy.json) applied. An owner arn is required to avoid orphaned keys.

## network

### vpc

Creates a VPC with private, public, and NAT'd subnets. NAT'd subnets each have a NAT Gateway attached for high availability. Subnet sizing supports up to 5 availability zones.

### peering

Establishes a VPC peering connection between two VPCs. The connection is set to auto accept, so this may have undefined behavior for VPCs not owned by the same account.

## ssh

Creates an ssh key pair for the given `public_key`.
