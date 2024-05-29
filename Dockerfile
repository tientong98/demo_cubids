# Use an official Ubuntu as a parent image
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    python3-venv \
    wget \
    zip \
    unzip \
    git \
    sudo \
    squashfs-tools \
    libseccomp-dev \
    pkg-config \
    uuid-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://golang.org/dl/go1.16.3.linux-arm64.tar.gz && \
    tar -C /usr/local -xzf go1.16.3.linux-arm64.tar.gz && \
    rm go1.16.3.linux-arm64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

# Build and install Singularity
RUN git clone https://github.com/apptainer/singularity.git && \
    cd singularity && \
    ./mconfig && \
    make -C ./builddir && \
    make -C ./builddir install && \
    cd .. && \
    rm -rf singularity

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh && \
    chmod +x /tmp/miniconda.sh && \
    /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

# Set up Conda environment
ENV PATH="/opt/conda/bin:${PATH}"

# Install Jupyter Lab using conda
RUN conda install -y jupyterlab && \
    conda clean -ya

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - && \
    apt-get install -y nodejs

# Install Slurm dependencies and Slurm
RUN apt-get update && \
    apt-get install -y \
    slurm-wlm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Update package lists and install Git and Git Annex
RUN apt-get update && \
    apt-get install -y git git-annex

# Create a directory for Jupyter Notebooks
RUN mkdir /notebooks
WORKDIR /notebooks

# Expose the Jupyter Lab port
EXPOSE 8888

# Start bash shell session and activate Conda environment
CMD ["/bin/bash", "-c", "source /opt/conda/bin/activate && jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root"]

