FROM ubuntu:26.04

ARG OPENCLAW_VERSION=2026.3.8

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

# Install Brave browser
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    | tee /etc/apt/sources.list.d/brave-browser-release.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends brave-browser && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Create ubuntu user and configure passwordless sudo
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu && \
    mkdir /var/tmp/openclaw-compile-cache && \
    chown -R ubuntu:ubuntu /var/tmp/openclaw-compile-cache


# Switch to ubuntu user
USER ubuntu
WORKDIR /home/ubuntu

# Install Homebrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Source Homebrew environment
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Add Bun to PATH for subsequent commands
ENV BUN_INSTALL="/home/ubuntu/.bun"
ENV PATH="${BUN_INSTALL}/bin:/home/ubuntu/.npm-global/bin:${PATH}"
ENV HOMEBREW_NO_ENV_HINTS=1
ENV OPENCLAW_NO_RESPAWN=1
ENV NODE_COMPILE_CACHE=/var/tmp/openclaw-compile-cache

# Install openclaw from npm (latest stable)
RUN curl -fsSL --proto '=https' --tlsv1.2 https://openclaw.ai/install.sh | bash -s -- --no-onboard --no-prompt --version=${OPENCLAW_VERSION}

RUN brew install --quiet gcc && \
    brew install --quiet cmake && \
    brew install --quiet python@3.12 && \
    brew install --quiet uv && \
    brew install --quiet gemini-cli && \
    bun install -g @tobilu/qmd

SHELL ["/bin/bash", "-lc"]

# Default command
CMD ["openclaw", "gateway", "run", "--allow-unconfigured"]
