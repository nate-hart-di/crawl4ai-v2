FROM python:3.12-slim

# Install system dependencies and Playwright dependencies
RUN apt-get update && apt-get install -y \
  git \
  gcc \
  g++ \
  curl \
  wget \
  gnupg \
  ca-certificates \
  fonts-liberation \
  libasound2 \
  libatk-bridge2.0-0 \
  libatk1.0-0 \
  libatspi2.0-0 \
  libcups2 \
  libdbus-1-3 \
  libdrm2 \
  libgtk-3-0 \
  libnspr4 \
  libnss3 \
  libx11-xcb1 \
  libxcomposite1 \
  libxdamage1 \
  libxrandr2 \
  xvfb \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Upgrade pip and install Python dependencies
RUN pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir -r requirements.txt

# Install Playwright and its Chromium dependencies as root
RUN pip install --no-cache-dir playwright && playwright install-deps chromium

# Create non-root user
RUN useradd -m -u 1000 crawl4ai

# Copy the rest of the code (after pip install for cache efficiency)
COPY src/ ./src/
COPY knowledge_graphs/ ./knowledge_graphs/
COPY pyproject.toml .

# Install the local package in editable mode
RUN pip install --no-deps -e .

# Switch to non-root user for browser use
USER crawl4ai

# Install Playwright browser as non-root user
RUN playwright install chromium

# Set environment variables
ENV PYTHONPATH=/app/src
ARG PORT=8051
ENV PORT=${PORT}

# Expose port
EXPOSE ${PORT}

# Health check (looks for crawl4ai_mcp process)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD pgrep -f "crawl4ai_mcp" > /dev/null || exit 1

# Start the MCP server
CMD ["python", "-m", "src.crawl4ai_mcp"]
