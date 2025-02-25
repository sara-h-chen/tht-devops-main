# Terraform and ECS-EC2 cluster
## How to deploy
### Setup & Installation
Ensure you have the following tools installed on your local machine:
1. Python3.9 and above (any in-support Python versions)
2. Terraform
3. Docker Desktop
4. AWS CLI
5. `minikube`
6. `kubectl`

##### Python
Python3 should be installed by default on a Linux machine. However, if you are running a Windows machine, download and run the installer from the [Python website](https://www.python.org/downloads/windows/).

##### Terraform
Follow the instructions on Hashicorp's [official documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

##### Docker Desktop
The easiest way to start using Docker on your machine is to install Docker Desktop from the official [Docker website](https://docs.docker.com/desktop/).

If using a Mac, you can install Docker via `brew`, without having to install Virtualbox:
```bash
brew install --cask docker 
open /Applications/Docker.app
```

##### AWS CLI
`brew install awscli` if you are on MacOS, or follow the instructions on the official [AWS Documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) for other OSes.

##### minikube
`brew install minikube` if you are on MacOS, or follow the instructions on [minikube docs](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Fx86-64%2Fstable%2Fhomebrew).

##### kubectl
`brew install kubectl` or follow instructions on official [Kubernetes documentation](https://kubernetes.io/docs/tasks/tools/#kubectl).

### Deploying Infrastructure with Terraform
This project is divided into 2 workspaces:
1. `supporting-infrastructure`
2. `ecs-ec2`

Each of the folders in the `deploy/` folder In order to deploy the infrastructure, navigate to the `terraform` folders:
```bash
.
└── deploy
    ├── ecs-ec2
    │   └── terraform
    └── supporting-infrastructure
        └── terraform
```
Run Terraform commands manually, such as `terraform apply` by referring to the Terraform documentation or run `terraform -help`.

#### Supporting Infrastructure
Ensure that the first workspace that you deploy is the `supporting-infrastructure` workspace, as this contains the infrastructure that will underpin the rest of your infrastructure. Once this is complete, you will need to build and upload your Docker image to ECR for use by your ECS Tasks.

#### Deploying Docker images to ECR
Do this by running the `upload.sh` script in the `supporting-infrastructure` folder. This script will authenticate you against ECR, and then upload the images to the ECR repositories that were created in the previous step.

#### Deploying the ECS cluster
A `makefile` has been made available in the directory, which allows you to run the following commands: `make tf-cluster-[init|plan|apply|destroy|graph]`. This will output the results of your `terraform plan` runs in JSON format, allowing you to read and check the resulting infrastructure that will be built. 

## How to Test 
- _See notes in DecisionsLog on what I would have loved to add here._

# Kubernetes and Helm
## How to deploy to MiniKube
- 

## How to Test 
- 