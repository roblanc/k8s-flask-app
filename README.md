# k8s-flask-app

This project demonstrates a complete, end-to-end **Continuous Integration/Continuous Deployment (CI/CD)** pipeline for a containerized Python **Flask web application** deployed onto a Kubernetes cluster (using Minikube/K3s for local development).

## What We Did

| Component | Goal | Implementation |
| :--- | :--- | :--- |
| **Application** | Created a minimal Python Flask app (`app.py`) designed to read environment variables for versioning. | Built a **Dockerfile** to containerize the application, exposing it on port 8080. |
| **CI/CD Pipeline** | Automated the build, test, and push process upon code commit. | Configured a **GitHub Actions Workflow** (`build-and-push.yaml`) to automatically log into Docker Hub, build the image, and push it with two tags: **`:latest`** and a unique **Short Commit SHA** (`db58ece`). |
| **Deployment** | Defined the necessary resources to run the application securely and scalably in Kubernetes. | Created `app-deploy.yaml` defining a **Deployment** (for replicas) and a **NodePort Service** (to expose the application). |
| **Fixing the Pipeline** | Overcame persistent issues with Kubernetes using a cached image tag. | Switched the deployment manifest to use the **unique, immutable Short Commit SHA (`db58ece`)** instead of the ambiguous `:latest` tag, ensuring guaranteed pull of the new code. |
| **Observability** | Prepared the environment for production-grade monitoring. | Installed **Helm** and added the necessary repository to deploy Prometheus and Grafana. |

## Current Status

The CI/CD pipeline is **fully functional and robust**. The application is currently running and verified with the latest code, accessible via NodePort.

*   **Application:** Flask App V2 (**`Hello from Flask in K8s!FINAL V2 TEST`**) is successfully running.
*   **Deployment:** Managed by the `flask-app-deployment` using image tag `netrebnic/web-app:db58ece`.
*   **Tools Ready:** `kubectl`, `helm`, and a local Kubernetes environment (Minikube/K3s) are configured.
*   **Next Phase:** Monitoring and resource optimization are ready to begin.

## Next Steps and Roadmap

The next phase of the project is to enhance production readiness by implementing **Observability** and optimizing the infrastructure.

### Phase 1: Observability (Monitoring) 📊

1.  **Deploy Prometheus and Grafana:** Complete the monitoring stack deployment using Helm, placing all components in the `monitoring` namespace.
2.  **Configure Access:** Set up port forwarding to access the Grafana web interface and use the generated `admin` password.
3.  **Validate Metrics:** Explore the default dashboards to verify metrics are being collected from the Kubernetes control plane and node resources.

### Phase 2: Production Readiness & Optimization ⚙️

1.  **Resource Limits:** Update `app-deploy.yaml` to define specific `requests` and `limits` for CPU and Memory. This prevents the Flask application from consuming excessive resources and destabilizing the node.
2.  **Horizontal Pod Autoscaler (HPA):** Deploy an HPA resource to automatically scale the `flask-app-deployment` up or down based on CPU utilization, ensuring the application can handle traffic spikes.
3.  **Liveness and Readiness Probes:** Add `livenessProbe` (to restart failed containers) and `readinessProbe` (to control service traffic) to the Deployment manifest.
4.  **Ingress:** Replace the less efficient NodePort Service with an **Ingress resource** backed by an Ingress Controller (like NGINX), allowing traffic to be routed based on hostnames or paths on a single IP/port.