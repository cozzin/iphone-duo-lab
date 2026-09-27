#!/bin/zsh
# Captures DuoLab experiments on the iPhone Duo simulator at the CURRENT pose.
#
# Semi-automatic flow (docs/research/08-screenshot-automation.md):
#   1. Set a pose in Xcode Device Hub (buttons, or hold ⌥ for the hinge slider).
#   2. Run this script. It reads the hinge angle, labels the pose, and captures
#      each experiment (deep link) on both displays.
#   3. Change the pose and run again.
#
# Usage:
#   tools/duo-capture/capture.sh [-a app] [-l label] [experiment[:variant] ...]
#     -a  bundle id to launch (default dev.duolab.app; dev.duolab.portraitonly for exp 05)
#     -l  extra label appended to file names (e.g. "split-left", "pip-pinned")
#   Experiments default to: 01 01b:A 01b:B 02:overlay 02:split 03 04 05 07
#
# Output: docs/images/<exp>/<pose>-<orientation?>-<display>[-<label>].png
set -euo pipefail

ROOT="${0:A:h:h:h}"
APP_ID="dev.duolab.app"
LABEL=""
while getopts "a:l:" opt; do
  case $opt in
    a) APP_ID="$OPTARG" ;;
    l) LABEL="-$OPTARG" ;;
    *) exit 64 ;;
  esac
done
shift $((OPTIND - 1))
if (( $# )); then EXPERIMENTS=("$@"); else EXPERIMENTS=(01 01b:A 01b:B 02:overlay 02:split 03 04 05 07); fi

UDID=$(xcrun simctl list devices booted -j | python3 -c '
import json,sys
for rt in json.load(sys.stdin)["devices"].values():
    for d in rt:
        if "Duo" in d["name"] and d["state"] == "Booted": print(d["udid"]); raise SystemExit
')
[[ -z "$UDID" ]] && { echo "No booted iPhone Duo simulator"; exit 1; }

# Integrated displays: pick the two "Display class: 0" ports; the smaller one is the outer display.
typeset -A DISPLAYS
eval "$(xcrun simctl io "$UDID" enumerate | python3 -c '
import sys,re
ports=[]; cur={}
for line in sys.stdin:
    line=line.strip()
    if line.startswith("UUID:"): cur={"uuid":line.split()[1]}; ports.append(cur)
    elif line.startswith("Display class:"): cur["cls"]=line.split()[-1]
    elif line.startswith("Default width:"): cur["w"]=int(line.split()[-1])
d=sorted([p for p in ports if p.get("cls")=="0"], key=lambda p:p["w"])
print("DISPLAYS[outer]=%s; DISPLAYS[inner]=%s" % (d[0]["uuid"], d[1]["uuid"]))
')"

# Hinge angle: devicectl ignores --session-timeout, so read the first sample and kill it.
read_angle() {
  local tmp=$(mktemp)
  xcrun devicectl device motion hinge-angle -d "$UDID" --timeout 30 >"$tmp" 2>&1 &
  local pid=$!
  for _ in {1..40}; do
    grep -q "Angle:" "$tmp" && break
    sleep 0.25
  done
  kill $pid 2>/dev/null || true
  wait $pid 2>/dev/null || true
  grep -m1 -o "Angle: *[0-9.]*" "$tmp" | grep -o "[0-9.]*$" || echo "nan"
  rm -f "$tmp"
}

# Wait until two consecutive reads are within 0.5° (the hinge sweeps during a pose change).
stable_angle() {
  local prev=$(read_angle) cur
  for _ in {1..10}; do
    cur=$(read_angle)
    python3 -c "import sys; a,b=float('$prev'),float('$cur'); sys.exit(0 if abs(a-b)<=0.5 else 1)" 2>/dev/null && { echo "$cur"; return; }
    prev=$cur
  done
  echo "$cur"
}

ANGLE=$(stable_angle)
POSE=$(python3 -c "
a=float('$ANGLE') if '$ANGLE'!='nan' else -1
print('unknown' if a<0 else 'closed' if a<5 else 'open' if a>175 else f'half{int(round(a))}')
")
echo "hinge ${ANGLE}° → pose '$POSE'  (outer=${DISPLAYS[outer]}, inner=${DISPLAYS[inner]})"

for spec in $EXPERIMENTS; do
  exp=${spec%%:*}
  variant=""
  [[ "$spec" == *:* ]] && variant=${spec#*:}
  url="duolab://experiment/$exp?overlay=1"
  [[ -n "$variant" ]] && url="$url&variant=$variant"
  xcrun simctl terminate "$UDID" "$APP_ID" 2>/dev/null || true
  xcrun simctl launch "$UDID" "$APP_ID" -openURL "$url" >/dev/null
  sleep 4
  dir="$ROOT/docs/images/$exp"
  mkdir -p "$dir"
  name="${POSE}${variant:+-$variant}${LABEL}"
  for display in outer inner; do
    out="$dir/$name-$display.png"
    xcrun simctl io "$UDID" screenshot --display="${DISPLAYS[$display]}" --mask=black "$out" >/dev/null 2>&1
    sips -Z 900 "$out" >/dev/null
    # Skip all-black captures (display off in this pose): a downscaled black frame is only a few KB
    if [[ $(stat -f%z "$out") -lt 20000 ]]; then
      rm -f "$out"
    else
      echo "  $out"
    fi
  done
done
