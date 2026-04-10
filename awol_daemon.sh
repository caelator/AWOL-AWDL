#!/usr/bin/env bash
set -u

# AWOL AWDL - The Ultimate Universal Control Guardian

echo "Starting AWOL AWDL Daemon (Root Enabled Fix)..."

LAST_PANIC_TIME=0

log stream --predicate 'subsystem == "com.apple.universalcontrol"' --style syslog | while read -r line; do
    if echo "$line" | grep -qiE "CWFInterface XPC connection invalidated|WiFi monitoring stopped"; then
        CURRENT_TIME=$(date +%s)
        if (( CURRENT_TIME - LAST_PANIC_TIME < 20 )); then
            continue
        fi
        LAST_PANIC_TIME=$CURRENT_TIME
        
        echo "$(date) - [CRITICAL] AWDL/Universal Control Network Panic Detected!"
        
        # Soft SIGHUP Reconnect...
        pkill -HUP UniversalControl 2>/dev/null
        sleep 2
        
        # Check TCP connections to see if soft-fix worked
        if ! lsof -c UniversalControl -a -iTCP -sTCP:ESTABLISHED >/dev/null 2>&1; then
            echo "$(date) - Soft fix failed. Hard bouncing AWDL interface and Universal Control daemon..."
            
            # Root-level deep AWDL purge with auto-sudo
            echo "YOUR_MAC_PASSWORD" | sudo -S ifconfig awdl0 down
            sleep 0.5
            echo "YOUR_MAC_PASSWORD" | sudo -S ifconfig awdl0 up
            
            # Restart Universal Control
            killall -9 UniversalControl 2>/dev/null
        else
            echo "$(date) - Soft fix succeeded! Connection re-established."
        fi
    fi
done
