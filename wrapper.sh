#!/bin/sh
set -e

# OpenClaw Cloud Wrapper
# Builds config directly and starts gateway (like Railway approach)

CONFIG_DIR="${OPENCLAW_STATE_DIR:-/data/.openclaw}"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"

echo "[wrapper] Starting OpenClaw Cloud wrapper..."
echo "[wrapper] Config dir: $CONFIG_DIR"

# Create directories
mkdir -p "$CONFIG_DIR" "${OPENCLAW_WORKSPACE_DIR:-/data/workspace}" 2>/dev/null || true

# Check required env vars
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "[wrapper] ERROR: ANTHROPIC_API_KEY not set"
    exit 1
fi

# Generate gateway token if not provided
if [ -z "$OPENCLAW_GATEWAY_TOKEN" ]; then
    OPENCLAW_GATEWAY_TOKEN=$(cat /proc/sys/kernel/random/uuid | tr -d '-')
    export OPENCLAW_GATEWAY_TOKEN
    echo "[wrapper] Generated gateway token"
fi

# Build config file directly (if not exists or force rebuild)
if [ ! -f "$CONFIG_FILE" ] || [ "$FORCE_REBUILD_CONFIG" = "true" ]; then
    echo "[wrapper] Building config..."
    
    # Build Telegram channel config if token provided
    if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
        TELEGRAM_CONFIG=$(cat <<EOF
    "telegram": {
      "enabled": true,
      "dmPolicy": "open",
      "allowFrom": ["*"],
      "botToken": "$TELEGRAM_BOT_TOKEN",
      "groupPolicy": "allowlist",
      "streamMode": "off"
    }
EOF
)
    else
        TELEGRAM_CONFIG=""
    fi

    # Build full config
    cat > "$CONFIG_FILE" <<EOF
{
  "gateway": {
    "mode": "local",
    "bind": "0.0.0.0",
    "port": 3000,
    "auth": {
      "mode": "token",
      "token": "$OPENCLAW_GATEWAY_TOKEN"
    }
  },
  "auth": {
    "profiles": {
      "anthropic:default": {
        "provider": "anthropic",
        "mode": "token"
      }
    },
    "order": {
      "anthropic": ["anthropic:default"]
    }
  },
  "channels": {
$TELEGRAM_CONFIG
  }
}
EOF
    
    echo "[wrapper] Config written to $CONFIG_FILE"
else
    echo "[wrapper] Using existing config"
fi

echo "[wrapper] Starting OpenClaw gateway..."
cd /app
exec node dist/index.js gateway
