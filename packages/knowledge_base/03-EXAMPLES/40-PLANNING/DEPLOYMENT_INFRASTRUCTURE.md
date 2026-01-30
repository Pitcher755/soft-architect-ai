# ☁️ Deployment Infrastructure: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Diseñado
> **Options:** Docker Compose (Local), AWS, Azure
> **Primary:** Docker Compose (Self-hosted)

---

## 📖 Tabla de Contenidos

1. [Deployment Architecture](#deployment-architecture)
2. [Local Deployment (Docker Compose)](#local-deployment-docker-compose)
3. [Cloud Deployment Options](#cloud-deployment-options)
4. [Infrastructure as Code](#infrastructure-as-code)
5. [Monitoring & Observability](#monitoring--observability)

---

## Deployment Architecture

### Multi-Tier Architecture

```
┌────────────────────────────────────────────────────┐
│  Client Layer                                      │
├────────────────────────────────────────────────────┤
│  Flutter Desktop App (Win/Mac/Linux)               │
│  └─ Installed locally on user machine              │
└──────────────┬───────────────────────────────────┘
               │ HTTP/REST (TLS 1.3+)
               ▼
┌────────────────────────────────────────────────────┐
│  Application Layer                                 │
├────────────────────────────────────────────────────┤
│  FastAPI Backend (Python 3.12)                     │
│  └─ /api/v1/llm, /api/v1/rag, /api/v1/knowledge  │
└──────────────┬───────────────────────────────────┘
               │
      ┌────────┴────────┐
      ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ LLM Engine   │  │ Vector Store │
│              │  │              │
│ Ollama       │  │ ChromaDB     │
│ (Container)  │  │ (Local)      │
└──────────────┘  └──────────────┘

┌────────────────────────────────────────────────────┐
│  Data Layer                                        │
├────────────────────────────────────────────────────┤
│  SQLite Database (.softarchitect/data/app.db)     │
│  ChromaDB Embeddings (.softarchitect/data/chroma) │
└────────────────────────────────────────────────────┘
```

### Network Topology

```
Internet (User's Network)
  ↓
┌─────────────────────────────────────┐
│ User's Machine                      │
│ ├─ Flutter App (port random)        │
│ ├─ FastAPI (port 8000)              │
│ ├─ Ollama (port 11434)              │
│ ├─ SQLite (filesystem)              │
│ └─ ChromaDB (filesystem)            │
│                                     │
│ 100% Local (no external calls)      │
└─────────────────────────────────────┘

Optional External (User-initiated):
  ↓ (only if user enables)
┌─────────────────────────────────────┐
│ Groq Cloud API (LLM acceleration)   │
│ AWS S3 / Azure Blob (backup)        │
└─────────────────────────────────────┘
```

---

## Local Deployment (Docker Compose)

### Prerequisites

```bash
# System requirements
- OS: Windows 10/11, macOS 10.15+, Ubuntu 20.04+
- CPU: 2+ cores
- RAM: 8GB minimum (16GB recommended)
- Disk: 10GB free (50GB for large knowledge bases)

# Software
- Docker Desktop: https://www.docker.com/products/docker-desktop
- Python 3.12+ (if running without Docker)
```

### Docker Compose Configuration

```yaml
# infrastructure/docker-compose.yml
version: '3.9'

services:
  # Backend API
  backend:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: softarchitect-backend
    ports:
      - "8000:8000"
    environment:
      - PYTHONUNBUFFERED=1
      - DATABASE_URL=sqlite:///./data/app.db
      - OLLAMA_API_URL=http://ollama:11434
      - CHROMA_PERSIST_DIR=/data/chroma
    volumes:
      - ~/.softarchitect/data:/app/data
      - ~/.softarchitect/config:/app/config
    depends_on:
      - ollama
    networks:
      - softarchitect-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/v1/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Local LLM (Ollama)
  ollama:
    image: ollama/ollama:latest
    container_name: softarchitect-ollama
    ports:
      - "11434:11434"
    volumes:
      - ~/.ollama/models:/root/.ollama/models
      - ~/.ollama/config:/root/.ollama/config
    networks:
      - softarchitect-net
    environment:
      - OLLAMA_MODELS=/root/.ollama/models
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Optional: pgAdmin (database management)
  db-admin:
    image: dpage/pgadmin4:latest
    container_name: softarchitect-dbadmin
    ports:
      - "5050:80"
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@example.com
      PGADMIN_DEFAULT_PASSWORD: admin
    networks:
      - softarchitect-net
    profiles:
      - debug

networks:
  softarchitect-net:
    driver: bridge

volumes:
  softarchitect-data:
    driver: local
```

### Startup Scripts

```bash
#!/bin/bash
# start_stack.sh

set -e

echo "🚀 Starting SoftArchitect AI Stack..."

# Check Docker
if ! command -v docker &> /dev/null; then
  echo "❌ Docker not installed. Install from https://www.docker.com/"
  exit 1
fi

# Create directories
mkdir -p ~/.softarchitect/data
mkdir -p ~/.softarchitect/config
mkdir -p ~/.ollama/models

# Pull latest images
echo "📥 Pulling Docker images..."
docker-compose -f infrastructure/docker-compose.yml pull

# Start services
echo "🔨 Starting services..."
docker-compose -f infrastructure/docker-compose.yml up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 10

# Verify health
echo "🔍 Verifying services..."
if curl -f http://localhost:8000/api/v1/health; then
  echo "✅ Backend ready"
else
  echo "❌ Backend failed to start"
  exit 1
fi

if curl -f http://localhost:11434/api/tags; then
  echo "✅ Ollama ready"
else
  echo "❌ Ollama failed to start"
  exit 1
fi

# Download default model
echo "📦 Downloading default model..."
ollama pull mistral:latest

echo "🎉 All services running!"
echo "   Backend: http://localhost:8000"
echo "   Ollama: http://localhost:11434"
echo ""
echo "Next: Run Flutter app!"
```

### Stop Script

```bash
#!/bin/bash
# stop_stack.sh

echo "🛑 Stopping SoftArchitect AI Stack..."
docker-compose -f infrastructure/docker-compose.yml down

echo "✅ Stack stopped"
echo "Data preserved in ~/.softarchitect/"
```

---

## Cloud Deployment Options

### Option 1: AWS Deployment

#### Architecture

```
┌─ AWS Account ──────────────────────────────┐
│                                            │
│  ┌─ EC2 (Compute) ─────────────────────┐  │
│  │ FastAPI Application                 │  │
│  │ Docker Container                    │  │
│  │ (t3.medium: 2 vCPU, 4GB RAM)       │  │
│  └─────────────────────────────────────┘  │
│           ↓ (connects to)                  │
│  ┌─ RDS (PostgreSQL) ──────────────────┐  │
│  │ Production Database                 │  │
│  │ (db.t3.micro: Multi-AZ)            │  │
│  └─────────────────────────────────────┘  │
│           ↓ (data backup)                  │
│  ┌─ S3 (Storage) ──────────────────────┐  │
│  │ Knowledge Base Backups              │  │
│  │ User Exports                        │  │
│  └─────────────────────────────────────┘  │
│           ↓ (metrics)                      │
│  ┌─ CloudWatch (Monitoring) ───────────┐  │
│  │ Logs, Metrics, Alarms               │  │
│  └─────────────────────────────────────┘  │
└────────────────────────────────────────────┘
```

#### Deployment Steps

```bash
# 1. Create EC2 instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.medium \
  --key-name my-key-pair \
  --security-groups softarchitect-sg

# 2. SSH into instance
ssh -i my-key.pem ec2-user@<instance-ip>

# 3. Install Docker
sudo yum install -y docker
sudo systemctl start docker

# 4. Pull and run container
docker run -d \
  -p 8000:8000 \
  -e DATABASE_URL=postgresql://... \
  ghcr.io/softarchitect-ai/backend:latest

# 5. Setup RDS
aws rds create-db-instance \
  --db-instance-identifier softarchitect-prod \
  --engine postgres \
  --db-instance-class db.t3.micro
```

### Option 2: Azure Deployment

#### Architecture

```
┌─ Azure Subscription ─────────────────────┐
│                                          │
│  ┌─ App Service (Web) ───────────────┐  │
│  │ FastAPI Application               │  │
│  │ (B2 Plan: 1 vCPU, 1.75GB RAM)    │  │
│  └───────────────────────────────────┘  │
│           ↓ (connects to)                │
│  ┌─ Azure Database for PostgreSQL ──┐  │
│  │ Production Database              │  │
│  │ (Basic tier)                     │  │
│  └───────────────────────────────────┘  │
│           ↓ (backup)                    │
│  ┌─ Blob Storage ───────────────────┐  │
│  │ Knowledge Base Backups           │  │
│  └───────────────────────────────────┘  │
│           ↓ (metrics)                    │
│  ┌─ Application Insights ──────────┐  │
│  │ Monitoring & Logging            │  │
│  └───────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

#### Deployment Steps

```bash
# 1. Create resource group
az group create \
  --name softarchitect-prod \
  --location eastus

# 2. Create App Service plan
az appservice plan create \
  --name softarchitect-plan \
  --resource-group softarchitect-prod \
  --sku B2

# 3. Create web app
az webapp create \
  --resource-group softarchitect-prod \
  --plan softarchitect-plan \
  --name softarchitect-app

# 4. Deploy container
az webapp config container set \
  --resource-group softarchitect-prod \
  --name softarchitect-app \
  --docker-custom-image-name ghcr.io/softarchitect-ai/backend:latest

# 5. Create PostgreSQL database
az postgres server create \
  --resource-group softarchitect-prod \
  --name softarchitect-db \
  --location eastus
```

---

## Infrastructure as Code

### Terraform Example (AWS)

```hcl
# infrastructure/terraform/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# EC2 Instance
resource "aws_instance" "backend" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.medium"
  key_name      = aws_key_pair.deployer.key_name

  user_data = base64encode(file("${path.module}/user_data.sh"))

  tags = {
    Name = "softarchitect-backend"
  }
}

# RDS Database
resource "aws_db_instance" "postgres" {
  identifier            = "softarchitect-db"
  engine               = "postgres"
  engine_version       = "14.7"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_encrypted    = true
  password             = random_password.db_password.result
  skip_final_snapshot  = false
  final_snapshot_identifier = "softarchitect-snapshot"
}

# S3 Bucket
resource "aws_s3_bucket" "backups" {
  bucket = "softarchitect-backups-${data.aws_caller_identity.current.account_id}"
}

# Output
output "backend_ip" {
  value = aws_instance.backend.public_ip
}
```

---

## Monitoring & Observability

### Metrics to Monitor

```
Application Metrics:
  - API response time (p50, p95, p99)
  - Request throughput (req/sec)
  - Error rate (5xx, 4xx)
  - Query processing time
  - Token usage
  - Cache hit rate

Infrastructure Metrics:
  - CPU usage
  - Memory usage
  - Disk I/O
  - Network bandwidth
  - Docker container health
  - Database connections

Business Metrics:
  - User session duration
  - Queries per user
  - Decision saved rate
  - Feature adoption
```

### Logging Strategy

```
Level              Example
────────────────────────────────────────────────
DEBUG              API request details
INFO               Service startup, feature usage
WARNING            Deprecated API calls, high latency
ERROR              Query failures, data corruption
CRITICAL           System down, data loss

Format:
timestamp [level] [component] message
2026-01-30T10:30:00Z [INFO] [RAG] Query processed in 1250ms
```

---

**Deployment Infrastructure** permite escalar desde local a cloud sin rediseño. ☁️
