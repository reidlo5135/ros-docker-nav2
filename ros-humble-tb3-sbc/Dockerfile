FROM ros:humble-ros-base

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV TURTLEBOT3_MODEL=burger
ENV COLCON_WS=/ws

# SBC image: TurtleBot3 core packages from source (RPi4/OpenCR/LDS bringup side)
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        vim \
        curl \
        gnupg \
        lsb-release \
        ca-certificates \
        git \
        python3-colcon-common-extensions \
        python3-rosdep \
        libudev-dev \
        udev \
        ros-humble-dynamixel-sdk \
        ros-humble-hls-lfcd-lds-driver \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then \
      rosdep init; \
    fi; \
    rosdep update --rosdistro "${ROS_DISTRO}"

WORKDIR ${COLCON_WS}
RUN mkdir -p src

RUN cd src && \
    git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3.git && \
    rm -rf turtlebot3/turtlebot3_cartographer \
           turtlebot3/turtlebot3_navigation2 \
           turtlebot3/turtlebot3_example \
           turtlebot3/turtlebot3_teleop \
           turtlebot3/turtlebot3_simulations

RUN set -eux; \
    apt-get update; \
    rosdep install --from-paths src --ignore-src --rosdistro "${ROS_DISTRO}" -r -y; \
    rm -rf /var/lib/apt/lists/*

RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
    cd ${COLCON_WS} && \
    colcon build --symlink-install --packages-up-to turtlebot3_bringup

RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc && \
    echo "export TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL}" >> /root/.bashrc && \
    echo "alias humble='source /opt/ros/humble/setup.bash && [ -f ${COLCON_WS}/install/setup.bash ] && source ${COLCON_WS}/install/setup.bash || true'" >> /root/.bashrc

CMD ["bash"]
