FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone Dify repository
RUN git clone https://github.com/langgenius/dify.git /tmp/dify && \
    cp -r /tmp/dify/api/* /app/ && \
    rm -rf /tmp/dify

# Install Python dependencies
COPY requirements.txt* ./
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; else \
    pip install --no-cache-dir \
    Flask==2.3.3 \
    gunicorn==21.2.0 \
    psycopg2-binary==2.9.7 \
    redis==4.6.0 \
    celery==5.3.1 \
    SQLAlchemy==2.0.20 \
    Flask-SQLAlchemy==3.0.5 \
    Flask-Migrate==4.0.5 \
    python-dotenv==1.0.0 \
    requests==2.31.0 \
    openai==0.28.1 \
    anthropic==0.3.11; fi

# Copy application code if it exists locally, otherwise use cloned version
COPY . /app/

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "--timeout", "200", "--preload", "--max-requests", "1000", "--max-requests-jitter", "50", "--log-level", "info", "app:app"]