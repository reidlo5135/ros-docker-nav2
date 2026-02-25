#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${TARGETPLATFORM:-}" ]]; then
  docker build --progress=plain --platform "${TARGETPLATFORM}" -t ros:humble-nav2-turtlebot3 .
else
  docker build --progress=plain -t ros:humble-nav2-turtlebot3 .
fi
