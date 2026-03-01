# OpenClaw Docker

Production-ready Docker image for [OpenClaw](https://openclaw.ai), an AI coding assistant, with a complete development toolchain.

## Features

- **Ubuntu 26.04** base image
- **OpenClaw** latest stable release
- **Multiple package managers**: apt, Homebrew, Bun
- **Pre-installed toolchain**: GCC, CMake, Python 3.12, UV
- **Development tools**: Git, build-essential, curl, wget
- **Optimized PATH** configuration for seamless tool integration

## Quick Start

```bash
# Pull and run (when published)
docker pull stolyarchuk/openclaw-docker:latest
docker run -it stolyarchuk/openclaw-docker

# Or build locally
docker build -t openclaw-docker .
docker run -it openclaw-docker
```

## What's Inside

### Package Managers

- **apt**: System-level package manager
- **Homebrew**: `/home/linuxbrew/.linuxbrew` - C/C++ toolchain and applications
- **Bun**: `~/.bun` - Fast JavaScript runtime and package manager

### Pre-installed Tools

- **OpenClaw** - AI coding assistant (latest stable)
- **GCC** - GNU Compiler Collection
- **CMake** - Cross-platform build system
- **Python 3.12** - With UV package installer
- **@tobilu/qmd** - Quarto markdown tools
- **Git, curl, wget** - Essential utilities

### User Configuration

- Non-root `ubuntu` user with passwordless sudo
- Shell environment configured in both `.bashrc` and `.profile`
- Optimized PATH for all installed tools

## Usage Examples

### Interactive Development

```bash
docker run -it openclaw-docker
# Inside container:
openclaw --version
python3 --version
bun --version
```

### Mount Local Project

```bash
docker run -it -v $(pwd):/workspace -w /workspace openclaw-docker
```

### Run Specific Command

```bash
docker run --rm openclaw-docker openclaw --help
```

## Building the Image

### Standard Build

```bash
docker build -t openclaw-docker:latest .
```

### Production Build with Date Tag

```bash
docker build -t openclaw-docker:$(date +%Y%m%d) .
```

### Build with Custom Tag

```bash
docker build -t myregistry/openclaw-docker:v1.0 .
```

## Version Management

This image tracks the **latest stable OpenClaw release**. Each build fetches the current version from the official installer.

**Recommended tagging strategy**:

- `latest` - Most recent build
- `YYYYMMDD` - Date-based tags for version control and rollbacks

Rebuild periodically to incorporate:

- Latest OpenClaw features and security patches
- Updated system packages
- New tool versions

## Architecture Notes

The image uses a two-phase user setup:

1. Root installs system packages and creates `ubuntu` user
2. All development tools install as `ubuntu` user to avoid permission issues

This ensures clean separation between system and user-level tools.

## Contributing

Contributions welcome! Please ensure:

- Docker builds complete successfully
- All verification checks pass
- Documentation is updated for new tools

## License

MIT

## Resources

- [OpenClaw](https://openclaw.ai)
- [Dockerfile](Dockerfile)
- [GitHub Repository](https://github.com/stolyarchuk/openclaw-docker)
