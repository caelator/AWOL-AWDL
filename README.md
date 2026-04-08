# AWOL AWDL (Apple Wireless Overseer Layer)

**The Ultimate macOS Universal Control & AWDL Stabilizer Watchdog**

If you've ever used Apple's **Universal Control** feature between multiple Macs or iPads, you likely know the excruciating pain of sudden, random disconnections. The connection often snaps because of deep underlying bugs with macOS's internal `CoreWiFi` location scanning and Apple Wireless Direct Link (AWDL) channel synchronization.

**AWOL AWDL** is an automated, high-speed macOS watchdog daemon that prevents and repairs these crashes instantly.

## How It Works

AWOL AWDL consolidates the best open-source Universal Control fixes into a single, unified background service:
1. **Aggressive XPC Log Watchdog:** It constantly sniffs the macOS kernel `syslog` for `CWFInterface XPC connection invalidated` and `WiFi monitoring stopped` errors. 
2. **Graceful Soft-Recouple:** The literal millisecond Universal Control drops the AWDL link, AWOL catches it and sends a soft SIGHUP connection refresh to explicitly force the `UniversalControl` daemon to renegotiate the TCP pipeline seamlessly.
3. **Hard AWDL Recovery:** If the software pipeline fails to bridge within 2 seconds, AWOL escalates to a physical `ifconfig awdl0 down && up` override coupled with an aggressive purge of the continuity cache to instantly resnap the mesh.

## Installation

Run this single command in terminal to automatically install the daemon to your `launchd` system processes:
```bash
./install.sh
```

Once installed, it will silently monitor your Universal Control network in the background and survive reboots!

## Viewing Logs

If you want to watch the daemon catch Apple's bugs in real-time, you can tail the launchd output log:
```bash
tail -f /tmp/awol_awdl.log
```

## Configuration

Because the daemon runs invisibly in the background, it needs root privileges to forcefully bounce the `awdl0` network interface if there is a deep Wi-Fi failure.

Before you run `./install.sh`, you must edit `awol_daemon.sh` and replace `YOUR_MAC_PASSWORD` with your actual Mac login password. This allows the script to automatically bypass the `sudo` prompt behind the scenes:
```bash
echo "YOUR_MAC_PASSWORD" | sudo -S ifconfig awdl0 down
sleep 0.5
echo "YOUR_MAC_PASSWORD" | sudo -S ifconfig awdl0 up
```
