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
### Setup & Installation
Run a local version of DynamoDB by running the instructions given in `MINIKUBE.md`, titled below:
1. How to upload local images to Minikube,
2. Deploy Helm chart,
3. Seed local DynamoDB table with entries.

This will first build the image for DynamoDB on Docker locally, then deploy it onto minikube, using the Helm charts. Then running `make ddb-seed` would insert entries into the local Dynamo table to be used by the app.

### Kustomize
We are using `kustomize` to help us with the management of our Kubernetes manifests. To install, run `brew install kustomize`. It may also come with your `kubectl` installation by default. In order to review your `kustomize` patch without applying the manifests, navigate to the `templates/` folder and run the `kustomize build` command on the resource that you would like to build manifests for, e.g.:
```bash
kustomize build overlays/dynamodb
```
Once rendered, and you are happy with the changes, you can apply the changes with `kubectl apply -k`, e.g.:
```bash
kubectl apply -k overlays/dynamodb`
```
Now, once you have ensured that all your Docker files have been built on locally, deploy all three resources to `minikube`.

### Kube Metrics Collection
To install Kube Metrics with Prometheus and Grafana, you can install it very quickly using Helm:
```bash
kubectl create ns monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring
```
This will deploy the following pods:
```bash
kube-prometheus-stack-grafana
kube-prometheus-stack-kube-state-metrics
kube-prometheus-stack-operator
```
Once these pods have started, you should be able to validate that it is functioning by logging into the Grafana dashboard locally by following the instructions given as an output from the `helm install` step.

## How to Test 
- TODO