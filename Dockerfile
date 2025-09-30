# Stage 1: Choose a small, official base image for Python
FROM python:3.10-alpine 

# Stage 2: Set the working directory inside the container
WORKDIR /app

# Stage 3: Copy dependencies and install them (leverages caching)
COPY requirements.txt .
RUN pip install -r requirements.txt --no-cache-dir

# Stage 4: Copy the actual application code
COPY app.py .

# Stage 5: Define the port the container expects to listen on
EXPOSE 8080 

# Stage 6: Define the command to run the application when the container starts
CMD ["python", "app.py"]
