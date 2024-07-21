# Cow wisdom web server


# Problem Statement
Deploy the wisecow application as a k8s app

## Requirement
## Create Dockerfile for the image and corresponding k8s manifest to deploy in k8s env. 

- I have created a Dockerfile and K8s manifests files in K8s folder
-  App has been exposed as LoadBalancer service

   
## Github action for creating new image when changes are made to this repo
- Github Actions file is inside .github/workflows folder


## [Challenge goal]: Enable secure TLS communication for the wisecow app. 
- I have created 3 manifest files for TLS secure communication

- cert-manager.yaml   ---  To setup a cert-manager
- clusterIssuer.yaml  ---  To issue production level certificate 
-  certificate.yaml    ---  To create a secret tls-cert

-   Finally TLS was added to the ingress.yaml file


## Deployment on EKS Cluster
-  Created a AWS EKS cluster and deployed app there using Github Actions.
-  I have created the EKS cluster using Terraform.
-  Terraform main.tf file has been added in the repo. It can be used to quickly create an EKS cluster 
 
