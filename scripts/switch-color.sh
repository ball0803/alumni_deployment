#!/bin/bash
CONFIG_DIR="/etc/nginx"
CONFIG_FILE="$CONFIG_DIR/nginx.conf"
TEMP_FILE="/tmp/nginx-new.conf"

# Determine current active color
if grep -q "alumni-api-blue" "$CONFIG_FILE"; then
  NEW_COLOR="green"
  OLD_COLOR="blue"
else
  NEW_COLOR="blue"
  OLD_COLOR="green"
fi

# Create new config
sed "s/alumni-api-$OLD_COLOR/alumni-api-$NEW_COLOR/" "$CONFIG_FILE" > "$TEMP_FILE"

# Verify and apply
if nginx -t -c "$TEMP_FILE"; then
  # Atomic replacement
  cat "$TEMP_FILE" > "$CONFIG_FILE"
  rm -f "$TEMP_FILE"
  
  # Reload
  if ! nginx -s reload; then
    echo "Reload failed! Rolling back..."
    sed "s/alumni-api-$NEW_COLOR/alumni-api-$OLD_COLOR/" "$CONFIG_FILE" > "$TEMP_FILE"
    cat "$TEMP_FILE" > "$CONFIG_FILE"
    nginx -s reload
    exit 1
  fi
else
  echo "Config test failed"
  exit 1
fi
