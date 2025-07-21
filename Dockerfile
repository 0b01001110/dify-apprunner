FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone Dify repository and setup
RUN git clone https://github.com/langgenius/dify.git /tmp/dify && \
    cp -r /tmp/dify/api/* /app/ && \
    rm -rf /tmp/dify

# Install dependencies from Dify requirements
RUN pip install --no-cache-dir -r requirements.txt

# Create simple health check endpoint
RUN echo 'from flask import Flask; app = Flask(__name__); @app.route("/health"); def health(): return "OK"' > health.py

# Expose port
EXPOSE 8080

# Run the application
CMD ["python", "-c", "from api.app import app; app.run(host='0.0.0.0', port=8080)"]