#!/bin/bash
# Start QBR Studio on port 8092.
cd "$(dirname "$0")/.." || exit 1
PORT=8092
if lsof -ti :$PORT >/dev/null 2>&1; then
  echo "Port $PORT is already in use. Run scripts/stop.sh first."
  exit 1
fi
mkdir -p logs
setsid nohup ./venv/bin/python server.py > logs/server.log 2>&1 < /dev/null &
echo $! > logs/server.pid
sleep 4
if lsof -ti :$PORT >/dev/null 2>&1; then
  echo "✅ QBR Studio running on http://$(hostname):$PORT  (pid $(cat logs/server.pid))"
else
  echo "❌ Failed to start. Last 30 lines:"; tail -30 logs/server.log; exit 1
fi
