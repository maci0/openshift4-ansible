# openshift4-ansible

This playbook creates the OpenShift 4 UPI (User provided Infrastructure) on AWS into an existing VPC with existing private and public subnets and DNS Zones.

It is also possible to deploy the API server without exposing it to the internet, this will require that the host that runs this ansible playbook does live in the same VPC.

The Cloudformation templates are based on these: https://github.com/openshift/installer/tree/master/upi/aws/cloudformation

Some information has to be provided. Mainly information about your aws VPC, your subnets etc. See `vars.yaml`


## Setup

Create an administrative IAM user to perform the install.
See https://github.com/openshift/installer/blob/master/docs/user/aws/iam.md

This user can be removed after the installation

To set up a bastion host follow these steps:

Start with a RHEL7 Instance.

Become root and install the needed tools.
```bash
sudo su -

yum -y install unzip python wget

curl -L "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip

./awscli-bundle/install -i /usr/local/aws -b /bin/aws

aws --version
rm -rf /root/awscli-bundle /root/awscli-bundle.zip

OPENSHIFT_RELEASE=4.1.0-rc.0
curl -L -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux-${OPENSHIFT_RELEASE}.tar.gz
tar xzf openshift-install-linux-${OPENSHIFT_RELEASE}.tar.gz --overwrite -C /usr/bin

rm -f openshift-install-linux-${OPENSHIFT_RELEASE}.tar.gz

curl -L -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-${OPENSHIFT_RELEASE}.tar.gz
tar xzf openshift-client-linux-${OPENSHIFT_RELEASE}.tar.gz --overwrite -C /usr/bin

rm -f openshift-client-linux-${OPENSHIFT_RELEASE}.tar.gz

oc completion bash >/etc/bash_completion.d/openshift
openshift-install completion >> /etc/bash_completion.d/openshift

source /usr/local/aws/activate
pip install ansible boto3 botocore boto
cp /usr/lib64/python2.7/site-packages/selinux /usr/local/aws/lib/python2.7/site-packages/ -r

exit
```

As user:

```bash
source /etc/bash_completion.d/openshift

export AWSKEY=MYSUPERSECRETKEY
export AWSSECRETKEY=MYSUPERSECRETSECRETKEY
export REGION=us-west-2

mkdir $HOME/.aws
cat << EOF >>  $HOME/.aws/credentials
[default]
aws_access_key_id = ${AWSKEY}
aws_secret_access_key = ${AWSSECRETKEY}
region = $REGION
EOF

aws sts get-caller-identity
```

## Usage

Modify `vars.yaml`

```bash
source /usr/local/aws/activate

ansible-playbook install-upi.yaml
```

To delete all AWS resources that were created for an OpenShift cluster, use the same `vars.yaml` that was used for the
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

The playbook uses the AMI ID `rhcos_ami` from `vars.yaml` as the source and creates a private AMI that is identical 
to the source AMI, except that disk encryption is enabled.

install-upi.yaml looks for a private AMI created by `create-encrypted-ami.yaml`. If none is found, it uses AMI ID 
`rhcos_ami` from `vars.yaml`.
