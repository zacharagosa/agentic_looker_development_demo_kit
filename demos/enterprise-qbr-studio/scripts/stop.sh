#!/bin/bash
# Stop whatever is listening on the QBR Studio port.
PORT=8092
PIDS=$(lsof -ti :$PORT 2>/dev/null)
if [ -z "$PIDS" ]; then echo "Nothing running on :$PORT"; exit 0; fi
kill $PIDS 2>/dev/null; sleep 2
kill -9 $(lsof -ti :$PORT 2>/dev/null) 2>/dev/null
echo "🛑 Stopped QBR Studio (:$PORT)"
