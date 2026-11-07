#!/bin/sh
set -eu

CONFIG_FILE=/opt/scripts/config.json
CRON_FILE=/etc/crontabs/root

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file is required at $CONFIG_FILE. Mount a directory containing config.json to /opt/scripts." >&2
    exit 1
fi

chmod 600 "$CONFIG_FILE" 2>/dev/null || true
mkdir -p /opt/scripts

cat > "$CRON_FILE" <<'EOF'
*/5 * * * * cd /app && /usr/local/bin/python monitor.py >> /opt/scripts/monitor.log 2>&1
0 9 * * * cd /app && /usr/local/bin/python report.py >> /opt/scripts/report.log 2>&1
EOF

if [ "${ENABLE_BOT:-false}" = "true" ]; then
    echo "Starting Telegram bot..."
    python /app/ecs_bot.py >> /opt/scripts/bot.log 2>&1 &
fi

echo "Starting scheduler (TZ=${TZ:-UTC}); monitoring runs every five minutes and reports run daily at 09:00."
exec crond -f -l 2
