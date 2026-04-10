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
    
    # TIER 2: ORGANIC DROPOUTS (Requires Instant SIGHUP Reconnect to prevent "long pauses")
    if echo "$line" | grep -qiE "P2PStream Canceled|P2PDirectLink Canceled|Device Lost"; then
        CURRENT_TIME=$(date +%s)
        
        # 30-second debounce to prevent loops on organic drops
        if (( CURRENT_TIME - LAST_SOFT_TIME < 30 )); then
            continue
        fi
        LAST_SOFT_TIME=$CURRENT_TIME
        
        echo "$(date) - [WARNING] Organic Mesh Dropout Detected. Instant Soft-Reconnecting..."
        
        # Soft SIGHUP instantly clears the hanging TCP buffer so it snaps back in 2s instead of 30s
        pkill -HUP UniversalControl 2>/dev/null
        
        # Do NOT hard bounce awdl0 here to protect working connections!
    fi
    
done
