#!/bin/bash

PID_FILE="/home/hoangkhang/hkerp/shared/pids/unicorn.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "Stopping Unicorn (PID: $PID)..."
    kill -QUIT "$PID"
    echo "Unicorn stopped."
else
    echo "Unicorn PID file not found at $PID_FILE"
fi


# sleep 5 seconds
echo "Wait 15 seconds"
sleep 15

# 
echo "Restarting application #1"
sudo service hkerp-unicorn restart

echo "Wait 15 seconds"
sleep 15

# sleep 5 seconds
echo "Wait 15 seconds"
sleep 15

# 
echo "Restarting application #2"
sudo service hkerp-unicorn restart


