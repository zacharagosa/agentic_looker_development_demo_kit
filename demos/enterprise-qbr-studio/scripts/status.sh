#!/bin/bash
PORT=8092
PIDS=$(lsof -ti :$PORT 2>/dev/null)
if [ -z "$PIDS" ]; then echo "⚪ QBR Studio is not running (:$PORT)"; exit 1; fi
echo "🟢 QBR Studio running on :$PORT (pid $PIDS)"
curl -s -m 20 "http://localhost:$PORT/api/health"; echo
