# OpenClaw Cloud Wrapper
# Extends the official OpenClaw image with startup logic for headless deployment

FROM ghcr.io/openclaw/openclaw:latest

# Switch to root to install wrapper
USER root

# Create wrapper script
COPY wrapper.sh /wrapper.sh
RUN chmod +x /wrapper.sh

# Create data directories
RUN mkdir -p /data/.openclaw /data/workspace && \
    chown -R node:node /data

# Switch back to node user
USER node

# Set working directory
WORKDIR /app

# Set environment
ENV OPENCLAW_STATE_DIR=/data/.openclaw
ENV OPENCLAW_WORKSPACE_DIR=/data/workspace
ENV NODE_ENV=production

# Use wrapper as entrypoint
ENTRYPOINT ["/wrapper.sh"]
