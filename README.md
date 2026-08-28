# Lemmings - Deployed by Harness

<p align="center">
  <img src="screenshots/lemmings.png" width="800" alt="Lemmings">
</p>

> "Oh no!" — Every Lemming, right before exploding, since 1991.

This repo deploys a fully playable version of the original Lemmings (1991) to a Kubernetes cluster using a [Harness](https://harness.io) CI/CD pipeline.

The container packages the original Lemmings shareware in a browser-playable format (via [js-dos](https://js-dos.com)) served by nginx. The Harness pipeline builds the container, pushes it to a registry, deploys to dev, runs a smoke test, gates on manual approval, and promotes to prod.

```
commit → build container → push to registry → deploy to dev → smoke test → approval gate → deploy to prod
                                                                                    ↑
                                                                          (you approve Lemmings for prod)
```

## Prerequisites

- A Kubernetes cluster (any: k3s, EKS, GKE, AKS, kind, minikube...)
- A [Harness](https://app.harness.io) account (free tier works)
- A Harness Delegate running in your cluster
- `kubectl`, `helm`, and `docker` (or equivalent) installed locally
- A container registry (Harness Artifact Registry, Docker Hub, ECR, etc.)

## Quick Start (Local)

If you just want to see Lemmings running locally without a pipeline:

```bash
# Build and deploy to your local cluster
./scripts/setup.sh

# Open in browser
open http://localhost:30666

# Tear it down when you're done
./scripts/teardown.sh
```

## Deploy via Harness Pipeline

### 1. Set up your Harness project

Create a project in Harness (or use an existing one). You'll need:
- A **Kubernetes connector** pointing to your cluster
- A **Docker Registry connector** pointing to your container registry
- A **code repo connector** pointing to this repo (GitHub, Harness Code, etc.)

### 2. Create the service

In your Harness project, create a Service with:
- **Deployment type:** Native Helm
- **Manifest source:** this repo, path `helm/harness-lemmings`
- **Artifact source:** your container registry, image path for `harness-lemmings`

### 3. Create environments and infrastructure

- **dev** environment → infrastructure definition pointing to your cluster + a `lemmings` namespace
- **prod** environment → infrastructure definition (same cluster, or a different one for realism)

### 4. Import the pipeline

Import `.harness/pipeline.yaml` into your project. Fill in the `<+input>` runtime inputs:
- Code repo connector
- Kubernetes infrastructure connector
- Docker registry connector
- Image repo path (e.g., `your-registry.io/harness-lemmings`)
- Infrastructure definition identifiers

### 5. Run it

Execute the pipeline. Watch it:
1. Clone this repo
2. Build the Lemmings container (first build ~5 min due to downloading shareware assets)
3. Push to your registry
4. Deploy to dev namespace
5. Smoke test (curls the health endpoint + verifies "Lemmings" in page)
6. Wait for your approval (the governance demo moment)
7. Deploy to prod

Then open `http://<node-ip>:30666` and play Lemmings.

## How It Works

```
app/
├── index.html      # Browser UI - loads js-dos, renders Lemmings
├── nginx.conf      # Web server config with /healthz endpoint
├── Dockerfile      # Multi-stage: downloads shareware → bundles → serves
└── .dockerignore

helm/harness-lemmings/  # Helm chart for k8s deployment
├── Chart.yaml
├── values.yaml
└── templates/

.harness/
└── pipeline.yaml   # Harness pipeline definition (parameterized)

scripts/
├── setup.sh        # Local deploy (no pipeline needed)
├── teardown.sh     # Clean removal
└── smoke-test.sh   # Validates the deployment works
```

The Dockerfile does the heavy lifting:
1. Downloads Lemmings DosBox image
2. Creates a `.jsdos` bundle (DOSBox-in-WebAssembly game package)
3. Packages everything in an nginx container

At runtime, the browser loads js-dos from CDN, which emulates DOSBox in WebAssembly, and runs the original Lemmings.EXE. Full game, in a browser, deployed by a CI/CD pipeline.

## Customization

| Variable | Default | Description |
|----------|---------|-------------|
| `Lemmings_NAMESPACE` | `lemmings` | Kubernetes namespace |
| `Lemmings_RELEASE` | `harness-lemmings` | Helm release name |
| `Lemmings_IMAGE` | `harness-lemmings` | Container image name |
| `Lemmings_TAG` | `latest` | Image tag |

Override in your pipeline or local env:
```bash
Lemmings_NAMESPACE=lemmings-prod Lemmings_TAG=build-42 ./scripts/setup.sh
```

## Why?

Because Lemmings is more fun than the Hello World container.

- Container builds (multi-stage, external asset download)
- Artifact management (push/pull from registry)
- Helm-based deployment
- Health checks and smoke tests
- Approval gates (human-in-the-loop governance)
- Progressive delivery (dev → approval → prod)
- GitOps trigger (push to main → pipeline fires)

All for a 35-year-old game that runs in DOSBox emulated in WebAssembly served by nginx deployed by Helm orchestrated by Harness triggered by a git push.

## License

This repo's code is MIT licensed. Lemmings is abandonware - please don't sue us!

---

*Let's go!* 🐁
