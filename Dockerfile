FROM ubuntu:26.04

ARG OPENCLAW_VERSION=2026.2.26

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
    && rm -rf /var/lib/apt/lists/*

# Create ubuntu user and configure passwordless sudo
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu

# Switch to ubuntu user
USER ubuntu
WORKDIR /home/ubuntu

# Install Homebrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.bashrc && \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.profile

# Source Homebrew environment
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash && \
    echo 'export BUN_INSTALL="$HOME/.bun"' >> /home/ubuntu/.profile && \
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> /home/ubuntu/.profile

# Add Bun to PATH for subsequent commands
ENV BUN_INSTALL="/home/ubuntu/.bun"
ENV PATH="${BUN_INSTALL}/bin:/home/ubuntu/.npm-global/bin:${PATH}"
ENV HOMEBREW_NO_ENV_HINTS=1

# Install openclaw from npm (latest stable)
RUN curl -fsSL --proto '=https' --tlsv1.2 https://openclaw.ai/install.sh | bash -s -- --no-onboard --no-prompt --version=${OPENCLAW_VERSION}

# Verify installations
RUN bash -lc 'which openclaw && openclaw --version' && \
    bash -lc 'which bun && bun --version' && \
    bash -lc 'which brew && brew --version'

RUN brew install --quiet gcc && \
    brew install --quiet cmake && \
    brew install --quiet python@3.12 && \
    brew install --quiet uv && \
    bun install -g @tobilu/qmd

SHELL ["/bin/bash", "-lc"]

# Default command
CMD ["openclaw", "gateway", "--allow-unconfigured"]
