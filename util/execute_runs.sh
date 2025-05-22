#!/bin/bash

# === CONFIG ===
N=15                 # Matrix size
T=4                  # Total number of threads/slaves
C=0                  # Core-affined? 0 = no, 1 = yes
BASE_PORT=28030      # Starting port
EXEC=./a.out         # Compiled binary
SESSION_NAME="lab_slaves"
CONFIG="../localconfig/config_${T}.cfg"
IP_FILE="util/ip_list.txt"

# === Read IPs from file ===
mapfile -t IPS < "$IP_FILE"
PC_IP="${IPS[0]}"
LAPTOP_IP="${IPS[1]}"

# === Get local machine's IP ===
LOCAL_IP=$(hostname -I | awk '{print $0}')
LOCAL_IP2=$(hostname -I | awk '{print $2}')

echo "📍 Local IP: $LOCAL_IP"
echo "🔍 PC IP: $PC_IP"
echo "🔍 Laptop IP: $LAPTOP_IP"

# === Determine role and thread range ===
if [[ "$LOCAL_IP" == "$PC_IP" || "$LOCAL_IP2" == "$PC_IP" ]]; then
  START=1
  END=$((T / 2))
  echo "🖥️ Running PC-assigned slave threads: $START to $END"
elif [[ "$LOCAL_IP" == "$LAPTOP_IP" || "$LOCAL_IP2" == "$LAPTOP_IP" ]]; then
  START=$((T / 2 + 1))
  END=$T
  echo "💻 Running Laptop-assigned slave threads: $START to $END"
else
  echo "❌ Unknown machine IP: $LOCAL_IP not in ip_list.txt"
  exit 1
fi

# === Kill old tmux session if it exists ===
tmux kill-session -t $SESSION_NAME 2>/dev/null

# === Start a new tmux session ===
tmux new-session -d -s $SESSION_NAME

# === Launch first slave in first pane ===
PORT=$((BASE_PORT + START))
CMD="$EXEC $N $PORT 1 $T $C"
tmux send-keys -t $SESSION_NAME "$CMD" C-m

# === Launch remaining slaves in split panes ===
for ((i=START+1; i<=END; i++)); do
  PORT=$((BASE_PORT + i))
  CMD="$EXEC $N $PORT 1 $T $C"
  tmux split-window -t $SESSION_NAME -v "$CMD"
  tmux select-layout -t $SESSION_NAME tiled
done

# === Attach to tmux session ===
tmux attach -t $SESSION_NAME