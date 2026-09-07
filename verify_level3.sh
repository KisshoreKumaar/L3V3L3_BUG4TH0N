#!/bin/bash
set -euo pipefail

# Level 3 Verification Script
# This script ensures the deployment is successful and flags are present.

APP_ROOT="/var/www/level3-logistics"
PORT=5000

echo "Starting Level 3 verification..."

if ! systemctl is-active --quiet level3-logistics.service; then
    echo "ERROR: level3-logistics.service is not running."
    exit 1
fi

echo "[PASS] Service is active."

# Check if port is listening (using curl to /)
if ! curl -s -f "http://127.0.0.1:${PORT}/" > /dev/null; then
    echo "ERROR: Could not connect to the portal on port ${PORT}."
    exit 1
fi

echo "[PASS] Portal is accessible on port ${PORT}."

# Check FLAG3_01 in headers
HEADER_FLAG=$(curl -s -I "http://127.0.0.1:${PORT}/" | grep 'X-LPH-Logistics-ID' || true)
if [[ ! "$HEADER_FLAG" == *"FLAG3_01"* ]]; then
    echo "ERROR: FLAG3_01 not found in HTTP headers."
    exit 1
fi

echo "[PASS] FLAG3_01 (Headers) verified."

# Check FLAG3_02 (Verbose Error)
ERR_RESPONSE=$(curl -s "http://127.0.0.1:${PORT}/download?document=nonexistent.file" || true)
if [[ ! "$ERR_RESPONSE" == *"FLAG3_02"* ]]; then
    echo "ERROR: FLAG3_02 not found in error message."
    exit 1
fi

echo "[PASS] FLAG3_02 (Verbose Error) verified."

# Check FLAG3_03 (Config read via LFI)
LFI_RESPONSE=$(curl -s "http://127.0.0.1:${PORT}/download?document=config.json" || true)
if [[ ! "$LFI_RESPONSE" == *"FLAG3_03"* ]]; then
    echo "ERROR: FLAG3_03 not found or LFI failed for config.json."
    exit 1
fi

echo "[PASS] FLAG3_03 (Config LFI) verified."

# Check FLAG3_04 (Source code read via LFI)
SRC_RESPONSE=$(curl -s "http://127.0.0.1:${PORT}/download?document=app.py" || true)
if [[ ! "$SRC_RESPONSE" == *"FLAG3_04"* ]]; then
    echo "ERROR: FLAG3_04 not found or LFI failed for app.py."
    exit 1
fi

echo "[PASS] FLAG3_04 (Source LFI) verified."

# Check FLAG3_08
if [ ! -f "/home/l3app/flag.txt" ] || ! grep -q "FLAG3_08" "/home/l3app/flag.txt"; then
    echo "ERROR: FLAG3_08 is missing or incorrect in /home/l3app/flag.txt"
    exit 1
fi

echo "[PASS] FLAG3_08 (Final shell flag) verified."

# Check permissions for template overwrite
if [ "$(stat -c '%U' ${APP_ROOT}/templates)" != "l3app" ]; then
    echo "ERROR: ${APP_ROOT}/templates is not owned by l3app. Overwrite will fail."
    exit 1
fi

echo "[PASS] Directory permissions for arbitrary file write verified."

echo "Level 3 verification: PASS."
exit 0
