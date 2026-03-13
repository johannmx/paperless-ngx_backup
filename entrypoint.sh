#!/bin/sh

# Handle SIGTERM
terminate() {
    echo "[$(date +"%F %T")] INFO: SIGTERM received, shutting down..."
    kill -TERM "$CROND_PID" 2>/dev/null
    exit 0
}

trap terminate TERM INT

SCRIPT_CMD="/sbin/su-exec ${UID}:${GID} /app/script.sh"
LOGS_FILE="/app/log/log.log"

# Ensure log file exists and is writable
touch "$LOGS_FILE"
chown "${UID}:${GID}" "$LOGS_FILE"

# If passed "manual", run script once
if [ "$1" = "manual" ]; then
    echo "[$(date +"%F %T")] INFO: Manual run triggered."
    exec $SCRIPT_CMD
fi

# Set up crontab for root (it runs the su-exec command)
echo "[$(date +"%F %T")] INFO: Configuring cron jobs..."
echo "$CRON_TIME $SCRIPT_CMD >> $LOGS_FILE 2>&1" | crontab -

# Start crond in foreground (blocking)
echo "[$(date +"%F %T")] INFO: Starting crond with schedule: ${CRON_TIME}"
/usr/sbin/crond -f -L /app/log/cron.log &
CROND_PID=$!

# Log startup message
echo "[$(date +"%F %T")] INFO: Backup scheduler is active." >> "$LOGS_FILE"

# Follow logs and wait for crond
tail -f "$LOGS_FILE" &
TAIL_PID=$!

# Wait for crond to exit
wait "$CROND_PID"
kill "$TAIL_PID" 2>/dev/null
