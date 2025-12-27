#!/usr/bin/env python3
"""
Simple test script for Port Killer app.
Opens a few ports on common development port numbers.
"""
import socket
import time

PORTS = [3000, 8080, 5173]  # Common dev ports

sockets = []

print("🚀 Opening test servers on ports:", PORTS)
print()

for port in PORTS:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind(("0.0.0.0", port))
        s.listen(1)
        sockets.append(s)
        print(f"  ✅ Listening on port {port}")
    except OSError as e:
        print(f"  ❌ Port {port} already in use: {e}")

print()
print("📋 Now check Port Killer - you should see these ports listed!")
print("Press Ctrl+C to close all ports and exit.")
print()

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("\n🛑 Closing ports...")
    for s in sockets:
        s.close()
    print("Done!")
