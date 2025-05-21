#!/bin/bash

# === CONFIG ===
USER="cmsc180"
PASSWORD="useruser"
FOLDER="lab_folder"      # Folder to copy
REMOTE_PATH="~"          # Or change to a full path
DRONE_LIST="drone_ips.txt"

# === COPY LOOP ===
while read -r ip host alias computeling; do
    echo "Copying to $alias ($ip)..."
    sshpass -p "$PASSWORD" scp -r "$FOLDER/" "$USER@$ip:$REMOTE_PATH"
done < <(grep -vE '^#' "$DRONE_LIST")

echo "✅ All files copied."
