# OpenClaw Cloud Wrapper
# Extends the official OpenClaw image with startup logic for headless deployment

FROM ghcr.io/openclaw/openclaw:latest

# Switch to root to install wrapper
USER root

# Create wrapper script
COPY wrapper.sh /wrapper.sh
RUN chmod +x /wrapper.sh

# Set working directory
WORKDIR /app

# Set environment
ENV OPENCLAW_STATE_DIR=/data/.openclaw
ENV OPENCLAW_WORKSPACE_DIR=/data/workspace
ENV NODE_ENV=production

# Run as root so we can fix volume permissions at runtime
# wrapper.sh will handle permissions and drop to node user

ENTRYPOINT ["/wrapper.sh"]
