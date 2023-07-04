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
start=$(date +%s)
tar -Jcf $BACKUP_LOCATION $BACKUP_DB $BACKUP_DATA $BACKUP_MEDIA 2>/dev/null
end=$(date +%s)
OUTPUT="${OUTPUT}New backup created"
ELAPSETIME="Elapsed Time: $(($end-$start)) seconds"

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

# ------------------ [ Slack Notifications ] ------------------
echo "[$(date +"%F %r")] Sending notification to Slack."
apprise -vv -t "💾 Backup Vaultwarden" -b "☑️ ${OUTPUT}" \
   "${SLACK_WEBHOOK}"

# ------------------ [ Discord Notifications ] ------------------
# Assuming our {WebhookID} is 4174216298
# Assuming our {WebhookToken} is JHMHI8qBe7bk2ZwO5U711o3dV_js
echo "[$(date +"%F %r")] Sending notification to Discord."
apprise -vv -t "Info Status Backup - ${ELAPSETIME}" -b "💾 ${OUTPUT}" \
   "discord://${DISCORD_WEBHOOK_ID}/${DISCORD_WEBHOOK_TOKEN}/?avatar=No"