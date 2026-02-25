#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${TARGETPLATFORM:-}" ]]; then
  docker build --progress=plain --platform "${TARGETPLATFORM}" -t ros-docker-tb3-pc .
else
  docker build --progress=plain -t ros-docker-tb3-pc .
fi
