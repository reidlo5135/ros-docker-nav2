#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${TARGETPLATFORM:-}" ]]; then
  docker build --progress=plain --platform "${TARGETPLATFORM}" -f Dockerfile -t ros-docker-tb3-sbc .
else
  docker build --progress=plain -f Dockerfile -t ros-docker-tb3-sbc .
fi
