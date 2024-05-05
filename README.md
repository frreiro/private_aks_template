# Azure Infrastructure

This code provisions a terraform infrastructure using the Azure cloud. 
Once the infrastructure is ready, it will provision an `Azure Kubernetes Service` environment integrated with an `Azure Database for PostgreSQL Flexible Server`, `Azure Container Registry`, `Virtual Networks`, `Private DNS Zones`, `Azure Key Vaults` and `Private Endpoints`. All resources are private (except ACR) and communicate privately to increase and maintain security.
A Virtual Machine with OpenVPN free for access to the cluster and other private resources is also created.

#### OpenVPN Pre-requirements

Create a ssh key-pair with key-gen command. Otherwise, you will have to change the ssh public key file path to access the VM in VPN module 

```bash
ssh-keygen -f ~/.ssh/openvpn-p2s -t rsa -b 4096 
```


### Install terraform

Prerequisites

Documentation
    https://developer.hashicorp.com/terraform/downloads

Before installing Terraform, you should have the following prerequisites installed on your Linux machine:

```bash

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install terraform

```
MacOS

```bash

brew tap hashicorp/tap

brew install hashicorp/tap/terraform

```

### Install tfenv

tfenv is a tool that allows you to easily switch between different versions of the Terraform machine learning framework on your local machine. It provides a simple command-line interface for managing Terraform versions.

```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv

echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

tfenv --version

tfenv install 1.3.6

tfenv use 1.3.6

```

## Folders structure

The first level of folders is divided into base_applications and infrastruture.
- `base_applications`: basic applications that will run on the kubernetes cluster
- `infrastruture`: all the project's infrastructure
 
Logically, infrastruture must be deployed before the base applications, cause it also creates the kubernetes cluster. 

The folder pattern is divided by environment, between: dev, prod, staging. Each folder contains everything the environment needs.

## Create a path tmp in root directory

```bash

mkdir tmp

```

To gain access it is mandatory to have the .tfvars file in each environment directory it is necessary to be able to catch the sensitive variables that cannot accompany the code, such as passwords and user data. Please create a file <"stage">.tfvars in root directory

For each environment in `infrastructure` directory, it need the <"stage">.tfvars in the following pattern:

```bash
application_name        = "<application_name>"
resource_group_name     = "<resource_group_name>"
resource_group_location = "<resource_group_location>"
stage                   = "<stage>" -> "PROD", "DEV" or "STAGING"
zones                   = ["<availability_zones_array>"] -> i.e ['1','2','3']
vnet_address_space      = "<vnet_address_space>"
hub_address_space       = "<hub_vnet_address_space>"
subscription_id         = "<subscriptio_id>"
client_id               = "<client_id>"
client_secret           = "<client_secret>"
tenant_id               = "<tenant_id>"
object_id               = "<object_id>"
database_username       = "<database_user>"
database_password       = "<database_password>"
```

And for each environment in `base_applications` directory, it need the <"stage">.tfvars in the following pattern:

```bash
cluster_name            = "<cluster_name>"
resource_group_name     = "<resource_group_name>"
stage                   = "<stage>" -> "PROD", "DEV" or "STAGING"
subscription_id         = "<subscriptio_id>"
client_id               = "<client_id>"
client_secret           = "<client_secret>"
tenant_id               = "<tenant_id>"
object_id               = "<object_id>"
vault_config_name       = "<vault_config_name>"
```

### Login to the Azure

```bash
az login
```
This way you can provision the Terraform state

### Init backend

```bash
terraform init 
```

Make sure your in the right environment !

### Planning

This will check the current configuration against the remote Infrastructure and identify any changes that need to be made. Double check this plan and make *sure* the changes look correct. If you're not sure, ask somebody.

```bash
terraform plan -out tmp/${STAGE}.plan -var-file="${STAGE}.tfvars"
```

### Applying changes

This will make the changes shown in the plan. Submit a pull request before applying changes.

```bash
terraform apply tmp/${STAGE}.plan
```

## Accessing Kubernetes Cluster
### Install k8s tool (Kubectl)

See a documentation:
     https://kubernetes.io/docs/tasks/tools/

Install kubectl binary with curl on Linux

Download the latest release with the command:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

```
Validate the kubectl binary against the checksum file:

```bash
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
```

If valid, the output is:

kubectl: OK

Install kubectl:

```bash
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

If you do not have root access on the target system, you can still install kubectl to the ~/.local/bin directory:

```bash
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
```

See version:
```bash
kubectl version --client
```