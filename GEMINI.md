# Gemini CLI Project Instructions: Harness Lemmings

This document outlines the architectural patterns, team conventions, and workflows established for this repository. These guidelines take absolute precedence over general defaults.

## 1. Kubernetes & Helm Deployment Conventions

### ✦ Dynamic NodePort Allocation (Collision Prevention)
To allow multiple environments (Dev, Prod, Staging) or multiple applications (Doom, Lemmings) to coexist on a single-node local cluster (such as Docker Desktop, Rancher Desktop, or k3s) without port collisions:
* **Never Hardcode NodePorts**: Always default `service.nodePort` to `null` in `values.yaml`:
  ```yaml
  service:
    type: NodePort
    port: 80
    targetPort: 8080
    nodePort: null
  ```
* **Guard Service Templates**: Always wrap the `nodePort` field in `service.yaml` with a conditional template guard so that the field is only included when explicitly overridden:
  ```yaml
  spec:
    type: {{ .Values.service.type }}
    ports:
      - port: {{ .Values.service.port }}
        targetPort: {{ .Values.service.targetPort }}
        {{- if .Values.service.nodePort }}
        nodePort: {{ .Values.service.nodePort }}
        {{- end }}
        protocol: TCP
        name: http
  ```

---

## 2. Harness CD Configuration Best Practices

### ✦ Infrastructure Definition Isolation
* **One App, One Infrastructure**: Never share a single Harness Infrastructure definition identifier (e.g., `demo_scarolan`) between two different applications/pipelines (e.g., Doom and Lemmings) unless they are intended to reside in the exact same namespace.
* **Dedicated Infrastructures**: Map each pipeline to dedicated, isolated infrastructures:
  * Dev Stage: `lemmings_dev_infra` pointing to `lemmings-dev` namespace.
  * Prod Stage: `lemmings_prod_infra` pointing to `lemmings-prod` namespace.

### ✦ Dynamic Environment Smoke Testing
* Always construct smoke-test endpoints dynamically using Harness-native stage/infra context variables. Avoid hardcoding service URLs or custom shell fallback logic:
  ```bash
  SVC_URL="http://<+infra.releaseName>.<+infra.namespace>.svc.cluster.local"
  ```

---

## 3. Harness CLI Usage Guidelines

When executing Harness CLI commands inside this workspace, always adhere to the following principles and syntax to ensure reliable operations:

### ✦ Authentication & Preloaded Context
* The system has Harness CLI 3.0 installed and authenticated. You do not need to provide API keys, tokens, or account IDs manually. The CLI automatically uses the active session.

### ✦ Command Grammar: Verb-Noun Syntax
* **Strict Order**: Commands must always follow the format `harness <verb> <noun> [id] [flags]`.
* **Never use Noun-Verb Order**:
  * **CORRECT**: `harness list pipeline`, `harness get execution`, `harness execute pipeline`
  * **INCORRECT**: `harness pipeline list`, `harness execution get`, `harness pipeline execute`

### ✦ Syntax & Resource Discovery
If unsure about the exact syntax, fields, or flags for any command, query the CLI's self-documenting features directly:
* Use `--help` on any command: `harness list execution --help`
* Discover modules, nouns, and fields:
  * `harness get module pipeline` (module definitions, nouns, guides)
  * `harness get noun execution` (fields and commands for a specific noun)

### ✦ Core Commands & Quick Reference
* **Common Verbs**:
  * `list`: Retrieves resources. An optional `[scope]` narrows results (e.g. pipeline ID for its executions).
  * `get`: Retrieves details for a single resource by ID.
  * `create`: Creates a resource (use `-f <file.yaml>` or `--set key=value`).
  * `update`: Updates a resource by ID.
  * `delete`: Deletes a resource by ID.
  * `execute`: Runs/triggers a resource by ID (e.g., executing a pipeline).
* **Common Scoping Flags**:
  * Use `--org` or `--project` to override the default resolved scope.
  * Use `--profile <name>` to run commands under a preconfigured profile.
  * Use `--level project|org|account` for multi-level nouns (like secrets, users).

### ✦ Processing & Output Formats
* **Formatted Outputs**:
  * `--format json` or `--json`: Returns the raw, full API response. Useful for examining specific fields or automation.
  * `--format yaml` or `--yaml`: Returns full data object with envelope stripped, perfect for round-trip configuration.
  * `--format table / csv / tsv`: Good for human-readable summaries or text processing.
* **Paging (Defaults to 20 items)**:
  * Use `--all` to fetch all items.
  * Use `--limit <n>` to control page size.

