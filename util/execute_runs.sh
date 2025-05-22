#!/bin/bash

# === CONFIG ===
N=15           # Matrix size
T=4               # Number of threads/slaves
C=0               # Core-affined? 0 = no, 1 = yes
BASE_PORT=28030   # Starting port
EXEC=./a.out      # Compiled binary
CONFIG="../localconfig/config_${T}.cfg"
IP_FILE="util/ip_list.txt"

# === Read IPs from file ===
mapfile -t IPS < "$IP_FILE"
PC_IP="${IPS[0]}"
LAPTOP_IP="${IPS[1]}"

# === Get local machine's IP ===
LOCAL_IP=$(hostname -I | awk '{print $1}')

echo "📍 Local IP: $LOCAL_IP"
echo "🔍 PC IP: $PC_IP"
echo "🔍 Laptop IP: $LAPTOP_IP"

# === Determine role and thread range ===
if [[ "$LOCAL_IP" == "$PC_IP" ]]; then
  START=1
  END=$((T / 2))
  echo "🖥️ Running PC-assigned slave threads: $START to $END"
elif [[ "$LOCAL_IP" == "$LAPTOP_IP" ]]; then
  START=$((T / 2 + 1))
  END=$T
  echo "💻 Running Laptop-assigned slave threads: $START to $END"
else
  echo "❌ Unknown machine IP: $LOCAL_IP not in ip_list.txt"
  exit 1
fi

# === Launch slave processes ===
for ((i=START; i<=END; i++)); do
  PORT=$((BASE_PORT + i))
  echo "Launching slave $i on port $PORT..."
  tmux new-session -d -s "slave_$PORT" "$EXEC $N $PORT 1 $T $C"
  sleep 0.5
done
