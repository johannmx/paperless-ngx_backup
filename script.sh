#!/bin/sh

# --------------- [ PREREQUISITES ] ---------------

EXTENSION="tar.xz"


# ------------------ [ BACKUP ] ------------------

cd /data

BACKUP_LOCATION="/backups/$(date +"%F_%H-%M-%S").${EXTENSION}"

BACKUP_DB="pgdata" # directory
BACKUP_DATA="data" # directory
BACKUP_MEDIA="media" # directory

# Back up files and folders.
tar -Jcf $BACKUP_LOCATION $BACKUP_DB $BACKUP_DATA $BACKUP_MEDIA 2>/dev/null

OUTPUT="${OUTPUT}New backup created"


# ------------------ [ DELETE ] ------------------

if [ -n "$DELETE_AFTER" ] && [ "$DELETE_AFTER" -gt 0 ]; then
    cd /backups

    # Find all archives older than x days, store them in a variable, delete them.
    TO_DELETE=$(find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER)
    find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER -exec rm -f {} \;

    OUTPUT="${OUTPUT}, $([ ! -z "$TO_DELETE" ] \
                       && echo "deleted $(echo "$TO_DELETE" | wc -l) archives older than ${DELETE_AFTER} days" \
                       || echo "no archives older than ${DELETE_AFTER} days to delete")"
fi


# ------------------ [ EXIT ] ------------------

echo "[$(date +"%F %r")] ${OUTPUT}."

# ------------------ [ Gotify Notifications ] ------------------
echo "[$(date +"%F %r")] Sending notification to Gotify Server."
apprise -vv -t "Backup Paperless-ngx" -b "☑️ 💾 ${OUTPUT}" \
   "gotifys://${GOTIFY_SERVER}/${GOTIFY_TOKEN}/?priority=high"