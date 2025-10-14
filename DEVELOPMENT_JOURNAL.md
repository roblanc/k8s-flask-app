# Development Journal

## October 14, 2025

### Session Summary: Initial Application Setup and Troubleshooting

**Goal:** Get the Flask application running locally using Docker and verify its functionality.

**Steps Taken & Progress:**
1.  **Read Application Files:** Reviewed `app.py`, `requirements.txt`, and `Dockerfile` to understand the application structure and dependencies.
2.  **Initial Docker Build:** Attempted to build the Docker image.
3.  **Initial Docker Run:** Attempted to run the Docker container.
4.  **Verification:** Used `curl` to check if the application was accessible.

**Challenges & Failures:**
*   **Port Mismatch:** The initial `docker run` command mapped host port 5000 to container port 5000, but the Flask app was configured to run on port 8080 inside the container. This resulted in a `curl` connection error.
    *   **Resolution:** Identified the correct container port (8080) by checking `docker logs`. Stopped and removed the incorrect container, then re-ran `docker run` with the correct port mapping (`-p 5000:8080`).
*   **"Port Already Allocated" Error (Repeated):** Encountered this error multiple times when trying to run new containers.
    *   **Resolution:** This occurred because previous containers were not properly stopped and removed before attempting to start a new one on the same host port. The solution was to explicitly `docker stop` and `docker rm` any container using port 5000 before running a new one.
*   **`docker build` Command Syntax Error:** When attempting to rebuild the image, a `docker buildx build' requires 1 argument` error occurred.
    *   **Resolution:** The `.` (dot) representing the build context was missing from the `docker build -t k8s-flask-app` command. Adding the `.` resolved this.

**Learnings & Takeaways:**
*   Always verify the internal port of a containerized application (e.g., via `Dockerfile` or logs) when setting up port mappings.
*   After making code changes, the Docker image must be **rebuilt**, and a **new container must be run** from that updated image.
*   It's crucial to stop and remove old Docker containers to free up ports before running new ones, especially during development and testing.
*   Pay close attention to command syntax, particularly required arguments like the build context (`.`) for `docker build`.

---

## October 14, 2025 (Continued)

### Moved from README.md: Fixing the CI/CD Pipeline

**Challenge:** Overcame persistent issues with Kubernetes using a cached image tag.
**Resolution:** Switched the deployment manifest to use the **unique, immutable Short Commit SHA (`db58ece`)** instead of the ambiguous `:latest` tag, ensuring guaranteed pull of the new code.

## October 14, 2025 (Continued)

### Discussion: Public Deployment Options

**Goal:** Explore options for deploying the Flask application to a publicly accessible server.

**Discussion Points:**
*   **Vercel/Netlify:** Determined these are not ideal for a persistent Flask backend application, as they are primarily suited for frontends and serverless functions.
*   **Suitable Platforms:** Identified Container-as-as-Service (CaaS) platforms (e.g., Google Cloud Run, Render, Fly.io) and Kubernetes clusters (e.g., GKE, EKS) as more appropriate.
*   **Free Tier Options:** Explored free tier options, with **Google Cloud Run** being highlighted as a strong recommendation due to its serverless nature, generous free tier, and native Docker support.

**Current Status:** The idea of deploying to Google Cloud Run is noted for future consideration. The immediate focus is not on public deployment.

## October 14, 2025 (Continued)

### Clarification: Local vs. Remote Docker Images

**Curiosity:** User inquired about the distinction between running a locally built Docker image (`k8s-flask-app`) and an image pulled from a remote registry (`netrebnic/web-app:latest`).

**Explanation:**
*   **Local Image (`k8s-flask-app`):** Built directly on the user's machine (`docker build .`). Used for quick local development and testing.
*   **Remote Image (`netrebnic/web-app:latest`):** Built and pushed by the CI/CD pipeline (e.g., GitHub Actions) to a remote Docker registry (e.g., Docker Hub). This is the official, pipeline-verified artifact.

**Key Takeaway:** The remote image ensures consistency and reliability, as it's the exact artifact that passed through the automated CI/CD pipeline, crucial for deployment to various environments.

## October 14, 2025 (Continued)

### Troubleshooting: Minikube ImagePullBackOff (DNS Issue) - Persistent Failures

**Problem:** Encountered `ImagePullBackOff` error for Prometheus pods, with `dial tcp: lookup registry.k8s.io ... server misbehaving` in pod events. This evolved into Minikube failing to start the Kubernetes control plane components (`kube-apiserver`, `kube-scheduler`, `kube-controller-manager`) with `connection refused` and `context deadline exceeded` errors.

**Troubleshooting Steps & Findings:**
1.  **Initial Attempt:** `minikube delete && minikube start --driver=docker --memory=3072mb`. Result: Did not resolve the issue; Minikube still reported `Failing to connect to https://registry.k8s.io/`.
2.  **Host Connectivity Check:** Ran `curl -v https://registry.k8s.io/v2/` on the host machine. Result: Confirmed the host *can* reach the registry successfully.
3.  **Docker Daemon DNS Configuration:** Modified `/etc/docker/daemon.json` to use public DNS (`8.8.8.8`, `8.8.4.4`) and restarted Docker. Encountered a JSON syntax error in `daemon.json` which was subsequently fixed.
4.  **Minikube Restart (with DNS fix & reduced memory):** `minikube delete && minikube start --driver=docker --memory=2048mb --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf`. Result: Still failed to start the control plane, with the `Failing to connect to https://registry.k8s.io/` warning persisting.

**Diagnosis:** The issue appears to be a persistent and deeper incompatibility or conflict with the Docker driver on the current system (Arch Linux) and its network configuration, preventing Minikube from establishing a stable Kubernetes cluster.

**Next Proposed Solution:** Switch to a different Minikube driver to bypass the Docker driver's issues. The plan is to try the **VirtualBox driver**.