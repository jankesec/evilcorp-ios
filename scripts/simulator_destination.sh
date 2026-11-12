#!/bin/sh
# Prints an xcodebuild destination for the first available iPhone simulator, so `make test`
# works on any machine or CI image without hard-coding a device model.
set -eu

udid=$(xcrun simctl list devices available --json | /usr/bin/python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"]
for runtime in sorted(devices, reverse=True):
    if "iOS" not in runtime:
        continue
    for device in devices[runtime]:
        if device.get("isAvailable") and device["name"].startswith("iPhone"):
            print(device["udid"])
            raise SystemExit
')

if [ -z "$udid" ]; then
  echo "No available iPhone simulator. Install one with: xcodebuild -downloadPlatform iOS" >&2
  exit 1
fi

echo "platform=iOS Simulator,id=$udid"
