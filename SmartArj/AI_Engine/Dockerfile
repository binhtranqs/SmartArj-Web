FROM python:3.11-slim

WORKDIR /app

# Install dependencies first (for Docker layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy entire AI_Engine (app.py, outputs/, etc.)
COPY . .

# Expose FastAPI port
EXPOSE 8001

# Run FastAPI via uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8001"]
