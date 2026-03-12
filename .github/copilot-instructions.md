# OpenClaw Docker Environment

## Project Overview

This project provides a production-ready containerized environment for OpenClaw, an AI coding assistant. The Dockerfile creates an Ubuntu 26.04-based image with multiple package managers (apt, Homebrew, Bun) and development tools pre-installed. **The image pins OpenClaw via `OPENCLAW_VERSION` (currently `2026.3.11`)** for predictable production deployments.

## Architecture

**User Setup Pattern**: The container uses a two-phase user configuration:

1. Root user installs system packages and creates `ubuntu` user with passwordless sudo
2. All subsequent tools (Homebrew, Bun, OpenClaw) install as `ubuntu` user to avoid permission issues

**Why this matters**: Never install user-level tools as root. Always maintain the ubuntu user context for Homebrew/Bun operations.

## Package Manager Orchestration

Three package managers work together:

- **apt**: System-level dependencies (sudo, curl, git, build-essential, ffmpeg)
- **Homebrew** (`/home/linuxbrew/.linuxbrew`): C/C++ toolchain (gcc, cmake), Python runtime
- **Bun** (`~/.bun`): JavaScript runtime and package manager, used for global npm packages

## Environment Variables & PATH

Critical PATH entries:

```dockerfile
/home/linuxbrew/.linuxbrew/bin  # Homebrew binaries
/home/linuxbrew/.linuxbrew/sbin # Homebrew sbin
```

`PATH` is appended with `${BREW_INSTALL}` in the Dockerfile. Bun and npm global binaries are provided by the OpenClaw installer and npm.

## OpenClaw Installation

OpenClaw installs via custom script with flags:

```dockerfile
curl -fsSL --proto '=https' --tlsv1.2 https://openclaw.ai/install.sh | bash -s -- --no-onboard --no-prompt --version=${OPENCLAW_VERSION}
```

The `--no-onboard --no-prompt` flags are essential for non-interactive Docker builds. `--version` keeps builds reproducible.

## Production Deployment

### Version Strategy

This image is designed for **production use** and pins OpenClaw with `OPENCLAW_VERSION`. Rebuilds keep the pinned OpenClaw version unless you update the ARG.

### Image Rebuilds

Rebuild the image periodically to incorporate:

- Updated OpenClaw installer/runtime behavior (for the pinned version)
- Updated base Ubuntu packages
- New Homebrew/Bun package versions

### Tagging Recommendations

```bash
docker build -t openclaw-docker:latest .
docker build -t openclaw-docker:$(date +%Y%m%d) .  # Date-based tags for rollback capability
```

## Developer Workflows

### Building the Image

```bash
docker build -t openclaw-docker .
```

### Running Container

```bash
docker run openclaw-docker
```

The default CMD starts the OpenClaw gateway:

```bash
openclaw gateway run --allow-unconfigured
```

For an interactive shell:

```bash
docker run -it openclaw-docker /bin/bash
```

### Testing Installations

Use one-off commands to verify key tools:

```bash
docker run --rm openclaw-docker openclaw --version
docker run --rm openclaw-docker bash -lc 'which brew && brew --version'
docker run --rm openclaw-docker bash -lc 'which bun && bun --version'
```

## Modifying the Image

### Adding System Packages

Add to the apt-get package list before the `rm -rf /var/lib/apt/lists/*` cleanup.

### Adding Homebrew Packages

Add in the Homebrew install RUN block using `brew install --quiet <package>` to suppress output.

### Adding Global npm/Bun Packages

Use `npm install -g <package>` or `bun install -g <package>` in the tool install RUN block.

## Conventions

- **Use pinned OpenClaw versions** via `OPENCLAW_VERSION` for reproducible builds
- **Use `bash -lc`** when you need shell-expanded environment in verification commands
- **Clean apt cache** with `rm -rf /var/lib/apt/lists/*` after apt operations
- **Verify installations** after major tool installations to catch issues early
- **Use --quiet flag** with Homebrew to reduce build log noise
