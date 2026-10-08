#!/usr/bin/env bash
# Automatically connect NVIDIA output sinks (HDMI / DisplayPort) to AMD primary display
sleep 1
xrandr --setprovideroutputsource 1 0 2>/dev/null || true
xrandr --auto 2>/dev/null || true
