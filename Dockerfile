# Use an official lightweight Python 3.10 image
FROM python:3.10-slim

# Set a working directory inside the container
WORKDIR /app

# Install system dependencies needed by pdfplumber (poppler) and Pillow backends
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (better for Docker layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project (notebooks, data, outputs folders, etc.)
COPY . .

# Environment variable for OpenAI key (user will override at runtime)
ENV OPENAI_API_KEY=""

# Expose Jupyter's default port
EXPOSE 8888

# Default command: launch Jupyter Notebook
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
