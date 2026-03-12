FROM ubuntu:26.04

ARG OPENCLAW_VERSION=2026.3.11

ENV DEBIAN_FRONTEND=noninteractive

# Install base packages including sudo
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    git \
    build-essential \
    make \
    cmake \
    ca-certificates \
    unzip \
    python3 \
    python3-pip \
    ffmpeg ffmpegthumbnailer \
    && rm -rf /var/lib/apt/lists/*

# Create ubuntu user and configure passwordless sudo
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu && \
    mkdir /var/tmp/openclaw-compile-cache && \
    chown -R ubuntu:ubuntu /var/tmp/openclaw-compile-cache

# Switch to ubuntu user
USER ubuntu
WORKDIR /home/ubuntu

# Install Homebrew
RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash && \
    curl -fsSL https://astral.sh/uv/install.sh | bash

# Source Homebrew environment
ENV BREW_INSTALL="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"
ENV PATH="${PATH}:${BREW_INSTALL}"
ENV HOMEBREW_NO_ENV_HINTS=1
ENV OPENCLAW_NO_RESPAWN=1
ENV NODE_COMPILE_CACHE=/var/tmp/openclaw-compile-cache

# Install openclaw from npm (latest stable)
RUN curl -fsSL --proto '=https' --tlsv1.2 https://openclaw.ai/install.sh | \
    bash -s -- --no-onboard --no-prompt --version=${OPENCLAW_VERSION}

# Install additional tools via Homebrew and npm
RUN brew install --quiet gcc && \
    brew install --quiet gemini-cli && \
    npm install -g @tobilu/qmd

# Default command
CMD ["openclaw", "gateway", "run", "--allow-unconfigured"]
