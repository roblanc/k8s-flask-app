from flask import Flask
import os

app = Flask(__name__)

# Get environment variable, or use a default
MESSAGE = os.environ.get("GREETING", "Hello from a Custom DevOps Container!")

@app.route('/')
def hello_devops():
    return f'<h1>{MESSAGE}</h1><h2>Containerized by Romica</h2>'

if __name__ == '__main__':
    # Listen on all interfaces (0.0.0.0) and a common web port (8080)
    app.run(host='0.0.0.0', port=8080)
