# Cow wisdom web server


# Problem Statement
Deploy the wisecow application as a k8s app

## Requirement
## Create Dockerfile for the image and corresponding k8s manifest to deploy in k8s env. 

1. I have created a Dockerfile and K8s manifests files in K8s folder
2. App has been exposed as LoadBalancer service

   
## Github action for creating new image when changes are made to this repo
1. Github Actions file is inside .github/workflows folder


## [Challenge goal]: Enable secure TLS communication for the wisecow app. 
1. I have created 3 manifest files for TLS secure communication

   cert-manager.yaml   ---  To setup a cert-manager
   clusterIssuer.yaml  ---  To issue production level certificate 
   certificate.yaml    ---  To create a secret tls-cert

   Finally TLS was added to the ingress.yaml file


## Deployment on EKS Cluster
1. Created a AWS EKS cluster and deployed app there using Github Actions
 
