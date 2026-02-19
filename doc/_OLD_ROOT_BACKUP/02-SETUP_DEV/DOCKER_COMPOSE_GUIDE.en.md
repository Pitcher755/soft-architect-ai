# 🐋 Docker Compose Setup Guide - SoftArchitect AI

> **Last Updated:** January 31, 2026
> **Status:** ✅ Production Ready
> **Tested On:** Linux (Ubuntu 22.04), Windows (WSL2), macOS (M1/Intel)

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Installation](#quick-installation)
3. [Execution Modes](#execution-modes)
4. [Service Verification](#service-verification)
5. [Troubleshooting](#troubleshooting)
6. [Performance Tuning](#performance-tuning)
7. [Detailed Architecture](#detailed-architecture)

---

## ✅ Prerequisites

### Minimum Hardware

```yaml
CPU: 2 cores (4 cores recommended)
RAM: 8GB (4GB Ollama + 2GB ChromaDB + 2GB System)
Disk: 20GB free (10GB Ollama + 5GB Docker overhead + 5GB cache)
GPU: Optional (NVIDIA CUDA 11.8+ to accelerate Ollama)
```

### Required Software

```bash
# Docker Desktop or Docker Engine + Docker Compose
docker --version
# Expected: Docker version 24.0.0 or higher

docker compose version
# Expected: Docker Compose version 2.20.0 or higher
```

**Installation:**

- **Linux:** `curl -fsSL https://get.docker.com | sh`
- **macOS/Windows:** [Docker Desktop](https://www.docker.com/products/docker-desktop/)

### NVIDIA GPU (Optional but Recommended)

If you have an NVIDIA GPU, uncomment in `docker-compose.yml`:
