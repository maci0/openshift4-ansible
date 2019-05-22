# openshift4-ansible

This playbook creates the OpenShift 4 UPI (User provided
Infrastructure) on AWS into an existing VPC with existing private and
public subnets and DNS Zones.

It is also possible to deploy the API server without exposing it to
the Internet, this will require that the host that runs this Ansible
playbook can access the VPC subnets.

The Cloudformation templates are based on these:
https://github.com/openshift/installer/tree/master/upi/aws/cloudformation

Some information has to be provided. Mainly information about your AWS
VPC, your subnets etc. See `inventory/group_vars/all`


## Setup

Create an administrative IAM user to perform the install.
See https://github.com/openshift/installer/blob/master/docs/user/aws/iam.md

This user can be removed after the installation

To set up a bastion host follow these steps:

Start with a RHEL7 Instance.

Become root and install the needed tools:

```bash
sudo -i

subscription-manager repos --enable rhel-7-server-ansible-2.8-rpms

yum install -y ansible

yum install -y \
  https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

yum -y install \
  python2-boto python2-boto3 python2-simplejson

yum erase -y epel-release

exit
```

With your own account, create ~/.aws/credentials with the following
content, replacing the AWSKEY and AWSSECRETKEY with the right values
from AWS.

```
[default]
aws_access_key_id = AWSKEY
aws_secret_access_key = AWSSECRETKEY
```

## Usage

Modify `inventory/group_vars/all`.

```bash
ansible-playbook install-upi.yaml
```

To delete all AWS resources that were created for an OpenShift cluster, use the same `inventory/group_vars/all` that was used for the
installation. In particular, the clustername has to match. You also need the `/tmp/CLUSTERNAME` directory that was created
by the installation playbook.

```bash
ansible-playbook uninstall-upi.yaml
```

### Disk Encryption

To enable encryption of the EBS volumes attached to the master and worker nodes, the RHCOS AMI needs to be copied before 
the installation is started. This can be done by running

```bash
ansible-playbook create-encrypted-ami.yaml
```

The playbook uses the AMI ID `rhcos_ami` from `vars.yaml` as the
source and creates a private AMI that is identical to the source AMI,
except that disk encryption is enabled.

install-upi.yaml looks for a private AMI created by
`create-encrypted-ami.yaml`. If none is found, it uses AMI ID
`rhcos_ami` from `inventory/group_vars/all`.
