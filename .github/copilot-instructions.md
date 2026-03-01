# OpenClaw Docker Environment

## Project Overview

This project provides a production-ready containerized environment for OpenClaw, an AI coding assistant. The Dockerfile creates an Ubuntu 26.04-based image with multiple package managers (apt, Homebrew, Bun) and development tools pre-installed. **The image tracks the latest stable version of OpenClaw** for production deployments.

## Architecture

**User Setup Pattern**: The container uses a two-phase user configuration:

1. Root user installs system packages and creates `ubuntu` user with passwordless sudo
2. All subsequent tools (Homebrew, Bun, OpenClaw) install as `ubuntu` user to avoid permission issues

**Why this matters**: Never install user-level tools as root. Always maintain the ubuntu user context for Homebrew/Bun operations.

## Package Manager Orchestration

Three package managers work together:

- **apt**: System-level dependencies (sudo, curl, git, build-essential)
- **Homebrew** (`/home/linuxbrew/.linuxbrew`): C/C++ toolchain (gcc, cmake), Python runtime
- **Bun** (`~/.bun`): JavaScript runtime and package manager, used for global npm packages

## Environment Variables & PATH

Critical PATH order (earlier = higher priority):

```dockerfile
/home/ubuntu/.bun/bin           # Bun binaries
/home/linuxbrew/.linuxbrew/bin  # Homebrew binaries
/home/ubuntu/.npm-global/bin    # npm global packages
```

**Shell environment**: Both `.bashrc` and `.profile` are configured to ensure tools work in interactive AND non-interactive shells.

## OpenClaw Installation

OpenClaw installs via custom script with flags:

```dockerfile
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard --no-prompt
```

The `--no-onboard --no-prompt` flags are essential for non-interactive Docker builds.

## Production Deployment

### Version Strategy

This image is designed for **production use** and tracks the **latest stable OpenClaw release**. Each build fetches the current version from `https://openclaw.ai/install.sh`, so rebuilding the image will update OpenClaw.

### Image Rebuilds

Rebuild the image periodically to incorporate:

- Latest OpenClaw features and security patches
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

### Running Interactive Container

```bash
docker run -it openclaw-docker
```

The default CMD starts a login bash shell (`/bin/bash -l`) to activate all environment variables.

### Testing Installations

The Dockerfile includes verification commands at line 50:

```bash
bash -lc 'which openclaw && openclaw --version'
bash -lc 'which bun && bun --version'
bash -lc 'which brew && brew --version'
```

Use login shell (`-l`) to ensure PATH is properly loaded.

## Modifying the Image

### Adding System Packages

Add to the apt-get line (line 6-13) before the `rm -rf /var/lib/apt/lists/*` cleanup.

### Adding Homebrew Packages

Add after line 54 using `brew install --quiet <package>` to suppress output.

### Adding Global npm/Bun Packages

Use `bun install -g <package>` (see line 58 for example with `@tobilu/qmd`).

## Conventions

- **Always use `bash -lc`** for RUN commands that need environment variables
- **Clean apt cache** with `rm -rf /var/lib/apt/lists/*` after apt operations
- **Verify installations** after major tool installations to catch issues early
- **Use --quiet flag** with Homebrew to reduce build log noise
