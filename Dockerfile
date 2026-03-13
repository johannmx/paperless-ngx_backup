FROM alpine:3.19

# Install dependencies
RUN apk add --no-cache \
    busybox-suid \
    su-exec \
    xz \
    zstd \
    tar \
    tzdata \
    python3 \
    py3-pip

# Install apprise
RUN pip3 install --no-cache-dir --break-system-packages apprise

# Create app user
RUN addgroup -S app && adduser -S -G app app

# Set environment variables
ENV CRON_TIME="0 3 * * *" \
    UID=1000 \
    GID=1000 \
    DELETE_AFTER=0 \
    COMPRESSION="zstd" \
    APPRISE_URLS=""

# Copy scripts
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY script.sh /app/script.sh

# Setup directories and permissions
RUN mkdir -p /app/log /backups /data \
    && chown -R app:app /app /backups \
    && chmod +x /usr/local/bin/entrypoint.sh /app/script.sh

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep crond || exit 1

ENTRYPOINT ["entrypoint.sh"]
