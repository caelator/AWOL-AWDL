#!/usr/bin/env bash
set -e

# Establish the Launchd Plist for AWOL AWDL
PLIST_FILE="$HOME/Library/LaunchAgents/com.user.awol-awdl.plist"
SCRIPT_PATH="/usr/local/bin/awol_daemon.sh"

# Install script to /usr/local/bin which is free from macOS TCC Documents protection
sudo mkdir -p /usr/local/bin
sudo cp /Users/xx/Documents/Workspaces/251/AWOL_AWDL/awol_daemon.sh /usr/local/bin/awol_daemon.sh
sudo chmod +x /usr/local/bin/awol_daemon.sh

cat << PLIST > "$PLIST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.awol-awdl</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/awol_awdl.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/awol_awdl_err.log</string>
</dict>
</plist>
PLIST

launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"

echo "AWOL AWDL Daemon successfully installed and launched in the background!"
