# 🤖 Automation and DevOps (Docs-as-Code)

This document describes the automation pipelines that keep the project's documentation and code synchronized.

## 1. Documentation Synchronization Pipeline (Docs Sync)

The goal is to maintain a "Single Source of Truth" in the Git repository, but automatically publish the content in Notion to facilitate reading and knowledge management.

### Flow Architecture
* **Source:** GitHub Repository (`main` / `develop`).
* **Orchestrator:** n8n (Self-hosted in HomeLab via CasaOS).
* **Destination:** Notion Database ("SoftArchitect Knowledge Base").

### Workflow Logic (n8n)
The flow is activated via Webhooks and follows an "Upsert" pattern (Update or Insert):

1.  **Trigger:** `GitHub Webhook` detects a `push` that modifies Markdown files (`.md`).
2.  **Extraction:** Downloads the "raw" content of the modified file.
3.  **Lookup:** n8n queries the Notion Database filtering by the custom property **`Local Path`** (e.g., `packages/docs/README.md`).
4.  **Decision:**
    * **If exists:** Gets the `PageID` and updates the content (blocks).
    * **If not exists:** Creates a new page in the Database, assigning the title and the `Local Path` property.

### Required Configuration
* **Notion Integration Token:** Internal token with read/write permissions.
* **Database ID:** ID of the destination database (Configured in n8n as fixed "Expression").
* **Notion Properties:** The database must have a text property called `Local Path`.

---

## 2. Hybrid Development Infrastructure

### Remote Access (SSH Tunneling)
To allow local development using the power of the HomeLab without exposing insecure ports:

* **Tool:** VS Code Remote - SSH.
* **Network:** Tailscale (Mesh VPN).
* **Docker:** Remote execution of heavy containers (Ollama, ChromaDB).