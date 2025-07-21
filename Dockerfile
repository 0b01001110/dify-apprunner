FROM python:3.10-slim

WORKDIR /app

# Install basic dependencies
RUN pip install flask gunicorn

# Create a simple Flask app
RUN echo 'from flask import Flask\n\
app = Flask(__name__)\n\
\n\
@app.route("/")\n\
def hello():\n\
    return "Dify App is running!"\n\
\n\
@app.route("/health")\n\
def health():\n\
    return "OK"\n\
\n\
if __name__ == "__main__":\n\
    app.run(host="0.0.0.0", port=8080)' > app.py

# Expose port
EXPOSE 8080

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "app:app"]