FROM python:3.12-slim

# Set default working directory.
WORKDIR /app

# Install R (v4.2.2 comes with this base image version) and the system
# libraries needed to compile R packages from source (no CRAN binaries
# are available for Debian).
RUN apt-get update && apt-get install -y --no-install-recommends \
    r-base \
    build-essential \
    gfortran \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    zlib1g-dev \
    liblapack-dev \
    libblas-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy over Python dependencies file and install.
COPY requirements.txt .
RUN pip install \
    --no-cache-dir \
    --break-system-packages \
    -r requirements.txt

# Copy over R dependencies file and install.
COPY install_packages.R .
RUN Rscript install_packages.R

# Copy over validation and scoring scripts.
COPY validate.py .
COPY score.R .