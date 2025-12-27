# Port Killer

A native macOS menu bar application for developers to quickly find and kill processes running on open ports.

![macOS 13+](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift 5](https://img.shields.io/badge/Swift-5.0-orange)

## Features

- 🔍 **Auto-scan active ports** - Automatically detects all processes listening on TCP ports
- ⚡ **One-click kill** - Terminate any process with a single click
- 🎯 **Custom port lookup** - Check and kill processes on specific ports
- 🔄 **Auto-refresh** - Scans every 5 seconds for real-time updates
- 🎨 **Native macOS UI** - Clean, minimal menu bar interface

## Common Ports Monitored

| Port | Common Use |
|------|------------|
| 3000 | React, Node.js |
| 4200 | Angular |
| 5000 | Flask, ASP.NET |
| 5173 | Vite |
| 8000 | Django |
| 8080 | Tomcat, Spring |

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15+ (for building)

## Installation

### Option 1: Download DMG
Download the latest release from the [Releases](https://github.com/bangalore-boy/port-killer/releases) page.

### Option 2: Build from Source

```bash
# Clone the repository
git clone <repo-url>
cd port-killer

# Build with xcodebuild
cd PortKiller
xcodebuild -scheme PortKiller -configuration Release build

# Or open in Xcode
open PortKiller.xcodeproj
```

## Usage

1. Launch Port Killer - it appears in your menu bar with a network icon
2. Click the icon to see all active port processes
3. Click the ❌ button to kill any process
4. Use "Custom Port" to check/kill a specific port
5. Click "Quit" to exit

## Building the DMG

```bash
# Build the app
xcodebuild -project PortKiller.xcodeproj -scheme PortKiller -configuration Release CONFIGURATION_BUILD_DIR=./build

# Create DMG (requires create-dmg)
brew install create-dmg
create-dmg \
  --volname "Port Killer" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "PortKiller.app" 150 185 \
  --app-drop-link 450 185 \
  "PortKiller.dmg" \
  "./build/PortKiller.app"
```

## License

MIT License - feel free to use and modify!
