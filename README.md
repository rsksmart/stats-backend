Rootstock Network Stats | Backend
================================

This component exposes a WebSocket interface that receives and aggregates information from Rootstock (RSK) network nodes. The aggregated data is then published over WebSockets and consumed by the Rootstock Network Stats frontend, which lives in its own repository.

Information received from network nodes is provided by a service called `stats agent`, which is responsible for interacting with an RSK node via web3 to extract the relevant information.

See [Metrics.md](Metrics.md) for details on how block history and the derived metrics are computed.

## WebSocket endpoints

| Path | Consumer | Purpose |
|------|----------|---------|
| `/api` | `stats agent` | Nodes authenticate with `WS_SECRET` and push blocks, stats, pending txs, latency and history |
| `/primus` | Stats frontend | Receives aggregated node list, blocks, stats and charts |
| `/external` | External consumers | Read-only feed of collection events |

## Prerequisites

* Node.js 18
* npm

## Installation

```bash
git clone https://github.com/rsksmart/stats-backend.git
cd stats-backend
npm install
```

## Configuration

The service is configured entirely through environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Port the HTTP/WebSocket server listens on |
| `WS_SECRET` | — | Secret(s) the `stats agent` must present on the `/api` endpoint. Multiple secrets can be separated with `\|` |
| `NODE_ENV` | — | When set to `production`, the bundled legacy web UI is not served and only the WebSocket endpoints are exposed |
| `LITE` | `false` | Serve the lite build (`src-lite`/`dist-lite`) instead of the full one |
| `VERBOSITY` | `2` | Log verbosity (0 = silent, 3 = most verbose) |

If `WS_SECRET` is not set, the server falls back to reading `ws_secret.json` from the repository root. That file is gitignored and is only intended for local development.

## Build the bundled web UI

The repository still contains a legacy web interface (Jade + AngularJS) that the server renders when `NODE_ENV` is not `production`. It is not the frontend used in production, but it is useful for local inspection. Building it produces the `dist` (full) or `dist-lite` (lite) directories with the js, css, fonts and images.

```bash
npx grunt        # full version -> dist/
npx grunt lite   # lite version  -> dist-lite/
npx grunt all    # both
```

## Run

```bash
npm start
```

The server listens on http://localhost:3000. With `NODE_ENV` unset, the bundled UI is available at that address; in production only the WebSocket endpoints are served.

## Docker

```bash
docker build -t stats-backend .
docker run -p 3000:3000 -e WS_SECRET=your-secret stats-backend
```

The image builds the full web UI at image build time and starts the server with `npm start`.

## Kubernetes / Helm

A Helm chart for deploying this service is included under [`helm/`](helm/), with per-network value files (`values-mainnet.yaml`, `values-testnet.yaml`). It supports External Secrets (AWS Parameter Store) for `WS_SECRET` and TargetGroupBinding for attaching to an externally managed AWS ALB. See [helm/README.md](helm/README.md) for the full parameter reference.

## Maintenance

To update the geoip-lite database:

```bash
npm explore geoip-lite -- npm run updatedb
```
