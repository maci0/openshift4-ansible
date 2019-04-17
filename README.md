# openshift4-ansible

Creates UPI on AWS into an existing VPC. The Cloudformation templates are based on these: https://github.com/openshift/installer/tree/master/upi/aws/cloudformation

Some information has to be provided. Mainly information about your aws VPC, your subnets etc. See `vars.yaml`

## Setup

To set up a bastion host follow these steps:

Start with a RHEL7 Instance.

Become root and install the needed tools.
```sudo su -

yum -y install unzip python wget

curl -L "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip

./awscli-bundle/install -i /usr/local/aws -b /bin/aws

aws --version
rm -rf /root/awscli-bundle /root/awscli-bundle.zip

INSTALLER_VERSION=v0.16.1
curl -L https://github.com/openshift/installer/releases/download/${INSTALLER_VERSION}/openshift-install-linux-amd64 -o /usr/bin/openshift-install
chmod +x /usr/bin/openshift-install

OC_CLI_VERSION=4.0.22
curl -L -O https://mirror.openshift.com/pub/openshift-v3/clients/${OC_CLI_VERSION}/linux/oc.tar.gz
tar zxvf oc.tar.gz -C /usr/bin
rm -f oc.tar.gz
chmod +x /usr/bin/oc

oc completion bash >/etc/bash_completion.d/openshift
openshift-install completion >> /etc/bash_completion.d/openshift

source /usr/local/aws/activate
pip install ansible boto3 botocore
cp /usr/lib64/python2.7/site-packages/selinux /usr/local/aws/lib/python2.7/site-packages/ -r

exit
```

As user:

```
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

```
source /usr/local/aws/activate

ansible-playbook install-upi.yaml

```

