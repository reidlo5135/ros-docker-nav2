#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${TARGETPLATFORM:-}" ]]; then
  docker build --platform "${TARGETPLATFORM}" -t ros:humble-turtlebot3 .
else
  docker build -t ros:humble-turtlebot3 .
fi
