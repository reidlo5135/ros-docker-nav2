#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-ros-docker-tb3-sbc}"
CONTAINER_NAME="${CONTAINER_NAME:-ros-docker-tb3-sbc}"
TURTLEBOT3_MODEL="${TURTLEBOT3_MODEL:-burger}"
DOCKER_ARGS=()

if [[ -n "${ROS_DOMAIN_ID:-}" ]]; then
  DOCKER_ARGS+=( -e "ROS_DOMAIN_ID=${ROS_DOMAIN_ID}" )
fi

if [[ -n "${LDS_MODEL:-}" ]]; then
  DOCKER_ARGS+=( -e "LDS_MODEL=${LDS_MODEL}" )
fi

if [[ -e /dev/ttyACM0 ]]; then
  DOCKER_ARGS+=( --device=/dev/ttyACM0 )
fi

docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

docker run -it \
  --name "${CONTAINER_NAME}" \
  --ipc=host \
  --privileged \
  -e TURTLEBOT3_MODEL="${TURTLEBOT3_MODEL}" \
  "${DOCKER_ARGS[@]}" \
  "${IMAGE_NAME}"
