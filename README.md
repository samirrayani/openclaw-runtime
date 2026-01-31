# OpenClaw Runtime

Minimal Docker wrapper for deploying OpenClaw on Railway (and other platforms).

This repo contains a Dockerfile that:
1. Extends the official OpenClaw image (`ghcr.io/openclaw/openclaw:latest`)
2. Adds a wrapper script for headless deployment
3. Handles config generation from environment variables

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_API_KEY` | Yes | Your Anthropic API key |
| `TELEGRAM_BOT_TOKEN` | No | Telegram bot token (if using Telegram) |
| `OPENCLAW_GATEWAY_TOKEN` | No | Gateway auth token (auto-generated if not set) |
| `PORT` | No | Port to bind (default: 3000) |

## Usage

This repo is designed to be deployed via Railway or similar platforms for automated deployments.

## Manual Docker Build

```bash
docker build -t openclaw-runtime .
docker run -e ANTHROPIC_API_KEY=your-key -p 3000:3000 openclaw-runtime
```
# Trigger rebuild 1769900765
