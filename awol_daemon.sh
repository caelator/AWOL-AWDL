#!/usr/bin/env bash
set -u

# AWOL AWDL - The Ultimate Universal Control Guardian

echo "Starting AWOL AWDL Daemon (2-Tier Root Enabled Fix)..."

LAST_SOFT_TIME=0

log stream --predicate 'subsystem == "com.apple.universalcontrol"' --style syslog | while read -r line; do
    
    # TIER 1: FATAL KERNEL PANICS (Requires Wi-Fi Hard Bounce)
    if echo "$line" | grep -qiE "CWFInterface XPC connection invalidated|WiFi monitoring stopped"; then
        echo "$(date) - [FATAL] Kernel AWDL Panic Detected!"
        
        # SIGHUP First...
        pkill -HUP UniversalControl 2>/dev/null
        sleep 2
        
        if ! lsof -c UniversalControl -a -iTCP -sTCP:ESTABLISHED >/dev/null 2>&1; then
            echo "$(date) - Soft fix failed. Hard bouncing AWDL interface..."
            echo "2643" | sudo -S ifconfig awdl0 down
            sleep 0.5
            echo "2643" | sudo -S ifconfig awdl0 up
            killall -9 UniversalControl 2>/dev/null
        else
            echo "$(date) - Fatal soft fix succeeded!"
        fi
        continue
    fi
    

    
done
