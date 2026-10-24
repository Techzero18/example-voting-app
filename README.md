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
## Monitoring & Observability (Prometheus & Grafana)

The cluster is monitored using the `kube-prometheus-stack` deployed in the `monitoring` namespace on K3s. Custom Grafana panels track golden signals across the application:

- **HTTP Requests Rate**: Tracks incoming request throughput (`sum(rate(prometheus_http_requests_total[5m]))`).
- **HTTP 5xx Error Rate**: Monitors server-side error spikes (`sum(rate(prometheus_http_requests_total{code=~"5.."}[5m])) or vector(0)`).
- **Request Latency**: Measures request duration across endpoints (`sum(rate(prometheus_http_request_duration_seconds_sum[5m]))`).

### Dashboard Artifacts
- **Exported Dashboard JSON (Root)**: [`grafana-dashboard.json`](./grafana-dashboard.json)
- **Exported Dashboard JSON (`monitoring/`)**: [`monitoring/grafana-dashboard.json`](./monitoring/grafana-dashboard.json)

### Live Grafana Dashboard Screenshot
![Grafana Monitoring Dashboard](./Screenshot%20(4).png)
