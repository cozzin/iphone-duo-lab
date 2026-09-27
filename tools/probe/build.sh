#!/bin/zsh
# Builds and runs the single-file probe app on the booted iPhone Duo simulator without Tuist/Xcode project.
# Usage: tools/probe/build.sh [simulator-udid|booted] [launch args: -withToolbar | -noVerticalBar]
set -euo pipefail
cd "${0:A:h}"
UDID="${1:-booted}"
OUT="${TMPDIR:-/tmp}/duolab-probe"
rm -rf "$OUT" && mkdir -p "$OUT/Probe.app"
# Use `xcrun --sdk iphonesimulator` so the linker also uses the iOS SDK.
# Linking against the macOS sysroot records an older SDK version, and the system then runs the app in compatibility mode.
xcrun --sdk iphonesimulator swiftc -parse-as-library -target arm64-apple-ios27.1-simulator -O Probe.swift -o "$OUT/Probe.app/Probe"
cp Info.plist "$OUT/Probe.app/Info.plist"
codesign -s - --force "$OUT/Probe.app"
xcrun simctl install "$UDID" "$OUT/Probe.app"
xcrun simctl terminate "$UDID" dev.duolab.probe 2>/dev/null || true
xcrun simctl launch "$UDID" dev.duolab.probe "${@:2}"
sleep 3
xcrun simctl spawn "$UDID" log show --predicate 'subsystem == "dev.duolab.probe"' --last 30s --style compact | grep PROBE || true
