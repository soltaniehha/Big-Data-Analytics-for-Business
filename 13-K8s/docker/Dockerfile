FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install only essential system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install dependencies one at a time to reduce peak disk usage
# Install PyTorch CPU-only version (much smaller than CUDA version)
RUN pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

# Install other dependencies
RUN pip install --no-cache-dir transformers huggingface-hub pandas gcsfs

# Copy application code
COPY app.py .

# Copy the 2015 summary CSV into the image
# (Make sure the CSV is in the same directory as the Dockerfile)
COPY 2015-summary.csv .

# Set environment variable for Hugging Face cache
ENV HF_HOME=/app/.cache/huggingface

# Run the application
CMD ["python", "app.py"]
