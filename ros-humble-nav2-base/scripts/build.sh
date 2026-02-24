#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${TARGETPLATFORM:-}" ]]; then
  docker build --platform "${TARGETPLATFORM}" -t ros:humble-nav2-base .
else
  docker build -t ros:humble-nav2-base .
fi
