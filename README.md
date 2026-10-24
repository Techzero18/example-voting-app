# Capstone 1: Kubernetes Microservices Deployment

## Project Overview
This project demonstrates a complete DevOps lifecycle by deploying a 5-tier microservices Voting Application to an AWS Elastic Kubernetes Service (EKS) cluster. The infrastructure was provisioned using Terraform, and the application is packaged and deployed via Helm.

![Architecture Diagram](./architecture-diagram.png) 

## CI/CD Pipeline & Security
Continuous Integration and Deployment are handled via GitHub Actions. On every push to the `main` branch, the pipeline:
1. Builds the Docker images.
2. Scans the images for CRITICAL and HIGH vulnerabilities using **Trivy**.
3. Pushes the secure images to Docker Hub (account: `techzero19`), tagged with the unique GitHub Commit SHA for complete traceability.

## Helm Configuration
The application is packaged into a single Helm chart located in the `./helm` directory, satisfying the "one chart, one values file" requirement. 
- **Chart:** `voting-app`
- **Configuration:** The `values.yaml` file controls the specific image tag for the frontend vote application, allowing for rapid versioning and rollbacks.

## Deployment Instructions
To deploy the application to your cluster, run the following command from the repository root:
```bash
helm install my-voting-app ./helm
```

## Fault Tolerance & Rollback Demonstration
To test Kubernetes fault tolerance and Helm's rollback capabilities, follow these steps to simulate a bad release and instantly recover.

**1. Deploy a broken version (simulating a failed tag):**
```bash
helm upgrade my-voting-app ./helm --set voteImageTag=broken-tag-123
```
*Verification:* Running `kubectl get pods` will show the `vote` pod failing with an `ImagePullBackOff` error.

**2. Roll back to the known-good state:**
```bash
helm rollback my-voting-app
```
*Verification:* The broken pod is instantly terminated, and the previous healthy container takes over, restoring service with zero lasting downtime.