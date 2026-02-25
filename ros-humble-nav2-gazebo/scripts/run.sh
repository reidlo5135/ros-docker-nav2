#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-ros:humble-nav2-gazebo}"
CONTAINER_NAME="${CONTAINER_NAME:-ros-humble-nav2-gazebo}"
TURTLEBOT3_MODEL="${TURTLEBOT3_MODEL:-burger}"
DISPLAY_VALUE="${DISPLAY:-:0}"

XSOCK="/tmp/.X11-unix"
XAUTH="${XAUTHORITY:-$HOME/.Xauthority}"
DOCKER_ARGS=()

if [[ ! -n "${DISPLAY:-}" ]]; then
  echo "DISPLAY is not set. Falling back to ${DISPLAY_VALUE}." >&2
fi

if [[ -d "${XSOCK}" ]]; then
  DOCKER_ARGS+=( -v "${XSOCK}:${XSOCK}:rw" )
else
  echo "${XSOCK} not found. Gazebo GUI may not connect to host X server." >&2
fi

if [[ -f "${XAUTH}" ]]; then
  DOCKER_ARGS+=( -v "${XAUTH}:${XAUTH}:ro" -e "XAUTHORITY=${XAUTH}" )
fi

if command -v xhost >/dev/null 2>&1; then
  xhost +local:root >/dev/null 2>&1 || true
fi

docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

docker run -it \
  --name "${CONTAINER_NAME}" \
  --privileged \
  --shm-size=4g \
  -e DISPLAY="${DISPLAY_VALUE}" \
  -e QT_X11_NO_MITSHM=1 \
  -e LIBGL_ALWAYS_INDIRECT=0 \
  -e TURTLEBOT3_MODEL="${TURTLEBOT3_MODEL}" \
  -p 2222:22 \
  -p 1883:1883 \
  "${DOCKER_ARGS[@]}" \
  "${IMAGE_NAME}"
