#!/bin/sh

# Set compression options
case "$COMPRESSION" in
    xz)  EXTENSION="tar.xz";  TAR_OPT="-Jcf" ;;
    gz)  EXTENSION="tar.gz";  TAR_OPT="-zcf" ;;
    zstd) EXTENSION="tar.zst"; TAR_OPT="--zstd -cf" ;;
    *)    EXTENSION="tar.zst"; TAR_OPT="--zstd -cf"; COMPRESSION="zstd" ;;
esac

echo "[$(date +"%F %T")] INFO: Using ${COMPRESSION} compression."

# Define directories to backup
BACKUP_DIRS="pgdata data media"
BACKUP_FILE="$(date +"%F_%H-%M-%S").${EXTENSION}"
BACKUP_LOCATION="/backups/${BACKUP_FILE}"

# ------------------ [ BACKUP ] ------------------

cd /data || { echo "ERROR: Could not change directory to /data"; exit 1; }

echo "[$(date +"%F %T")] INFO: Starting backup to ${BACKUP_FILE}..."
start=$(date +%s)

# Capture tar output and errors
TAR_OUTPUT=$(tar $TAR_OPT "$BACKUP_LOCATION" $BACKUP_DIRS 2>&1)
TAR_EXIT_CODE=$?

end=$(date +%s)
ELAPSED=$((end-start))

if [ $TAR_EXIT_CODE -eq 0 ]; then
    echo "[$(date +"%F %T")] INFO: Backup finished successfully in ${ELAPSED} seconds."
    OUTPUT="New backup created: ${BACKUP_FILE} (${ELAPSED}s)"
    STATUS="SUCCESS"
else
    echo "[$(date +"%F %T")] ERROR: Backup failed with exit code ${TAR_EXIT_CODE}."
    echo "$TAR_OUTPUT"
    OUTPUT="Backup FAILED for ${BACKUP_FILE}. Error: ${TAR_OUTPUT}"
    STATUS="FAILED"
fi

# ------------------ [ DELETE ] ------------------

if [ -n "$DELETE_AFTER" ] && [ "$DELETE_AFTER" -gt 0 ] && [ "$STATUS" = "SUCCESS" ]; then
    echo "[$(date +"%F %T")] INFO: Checking for archives older than ${DELETE_AFTER} days..."
    
    # List files to delete
    TO_DELETE=$(find /backups -maxdepth 1 -name "*.tar.*" -type f -mtime +$DELETE_AFTER)
    DELETE_COUNT=$(echo "$TO_DELETE" | grep -c "tar")
    
    if [ "$DELETE_COUNT" -gt 0 ]; then
        echo "$TO_DELETE" | xargs rm -f
        echo "[$(date +"%F %T")] INFO: Deleted ${DELETE_COUNT} old archives."
        OUTPUT="${OUTPUT}. Deleted ${DELETE_COUNT} old archives."
    else
        echo "[$(date +"%F %T")] INFO: No old archives to delete."
    fi
fi

# ------------------ [ NOTIFICATIONS ] ------------------

if [ -n "$APPRISE_URLS" ]; then
    TITLE="Paperless-ngx Backup: ${STATUS}"
    ICON=$([ "$STATUS" = "SUCCESS" ] && echo "☑️" || echo "❌")
    
    echo "[$(date +"%F %T")] INFO: Sending notifications via Apprise..."
    apprise -t "${TITLE}" -b "${ICON} ${OUTPUT}" "${APPRISE_URLS}"
else
    echo "[$(date +"%F %T")] INFO: No APPRISE_URLS defined. Skipping notifications."
fi

exit $TAR_EXIT_CODE
