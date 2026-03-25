FROM python:3.11-slim

WORKDIR /app

# Install dependencies first (for Docker layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy entire AI_Engine (app.py, outputs/, etc.)
COPY . .

# Render assigns $PORT dynamically (default 10000)
# Use shell form to allow env var expansion
CMD uvicorn app:app --host 0.0.0.0 --port ${PORT:-8001}
