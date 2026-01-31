#!/bin/sh
set -e

# OpenClaw Cloud Wrapper
# One-click deploy: works immediately with web chat, channels optional

CONFIG_DIR="${OPENCLAW_STATE_DIR:-/data/.openclaw}"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"

echo "[wrapper] Starting OpenClaw Cloud wrapper..."
echo "[wrapper] Config dir: $CONFIG_DIR"

# Create directories (critical - must succeed)
echo "[wrapper] Creating directories..."
if ! mkdir -p "$CONFIG_DIR" "${OPENCLAW_WORKSPACE_DIR:-/data/workspace}"; then
    echo "[wrapper] Failed to create dirs, trying with different approach..."
    # Sometimes /data mount needs a moment
    sleep 1
    mkdir -p "$CONFIG_DIR" "${OPENCLAW_WORKSPACE_DIR:-/data/workspace}" || {
        echo "[wrapper] ERROR: Cannot create $CONFIG_DIR"
        echo "[wrapper] Checking /data permissions..."
        ls -la /data 2>&1 || echo "/data does not exist"
        exit 1
    }
fi
echo "[wrapper] Directories created successfully"

# Check required env vars
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "[wrapper] ERROR: ANTHROPIC_API_KEY not set"
    exit 1
fi

# Generate gateway token if not provided (used for API access)
if [ -z "$OPENCLAW_GATEWAY_TOKEN" ]; then
    OPENCLAW_GATEWAY_TOKEN=$(cat /proc/sys/kernel/random/uuid | tr -d '-')
    export OPENCLAW_GATEWAY_TOKEN
    echo "[wrapper] Generated gateway token: $OPENCLAW_GATEWAY_TOKEN"
fi

# Build config file (if not exists or force rebuild)
if [ ! -f "$CONFIG_FILE" ] || [ "$FORCE_REBUILD_CONFIG" = "true" ]; then
    echo "[wrapper] Building config..."
    
    # Start channels object
    CHANNELS_CONFIG=""
    
    # Add Telegram if token provided
    if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
        CHANNELS_CONFIG=$(cat <<EOF
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
        echo "[wrapper] Telegram channel configured"
    fi

    # Build full config - web dashboard enabled by default
    cat > "$CONFIG_FILE" <<EOF
{
  "gateway": {
    "mode": "local",
    "bind": "custom",
    "customBind": "0.0.0.0",
    "port": ${PORT:-3000},
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
$CHANNELS_CONFIG
  }
}
EOF
    
    echo "[wrapper] Config written to $CONFIG_FILE"
    echo "[wrapper] Gateway token for API access: $OPENCLAW_GATEWAY_TOKEN"
else
    echo "[wrapper] Using existing config"
fi

echo "[wrapper] Starting OpenClaw gateway on port ${PORT:-3000}..."
cd /app
exec node dist/index.js gateway
