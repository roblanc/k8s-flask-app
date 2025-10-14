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
