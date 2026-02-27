FROM ros:humble-ros-base

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV TURTLEBOT3_MODEL=burger
ENV COLCON_WS=/ws

RUN set -eux; \
    sed -i '/^deb-src .*packages\.ros\.org\/ros2\/ubuntu/d' /etc/apt/sources.list.d/ros2.list 2>/dev/null || true; \
    sed -i '/^deb-src /d' /etc/apt/sources.list 2>/dev/null || true

# SBC image: TurtleBot3 core packages from source (RPi4/OpenCR/LDS bringup side)
RUN set -eux; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get clean; \
    ok=0; \
    for i in 1 2 3 4 5; do \
      if apt-get update; then ok=1; break; fi; \
      echo "apt-get update failed (attempt ${i}/5), retrying..." >&2; \
      sleep 5; \
    done; \
    [ "${ok}" -eq 1 ]; \
    apt-get upgrade -y && \
    apt-get install -y \
        vim \
        curl \
        gnupg \
        net-tools \
        iproute2 \
        build-essential \
        lsb-release \
        ca-certificates \
        git \
        openssh-server \
        python3-colcon-common-extensions \
        python3-rosdep \
        libudev-dev \
        udev \
        ros-humble-dynamixel-sdk \
        ros-humble-hls-lfcd-lds-driver \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    sed -i "s/^#\\?Port.*/Port 2222/" /etc/ssh/sshd_config; \
    sed -i "s/^#\\?PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config; \
    sed -i "s/^#\\?PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config; \
    echo 'root:root' | chpasswd

RUN set -eux; \
    if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then \
      rosdep init; \
    fi; \
    ok=0; \
    for i in 1 2 3; do \
      if rosdep update --rosdistro "${ROS_DISTRO}"; then ok=1; break; fi; \
      echo "rosdep update failed (attempt ${i}/3), retrying..." >&2; \
      sleep 5; \
    done; \
    [ "${ok}" -eq 1 ]

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
    rm -rf /var/lib/apt/lists/*; \
    apt-get clean; \
    ok=0; \
    for i in 1 2 3 4 5; do \
      if apt-get update; then ok=1; break; fi; \
      echo "apt-get update failed (attempt ${i}/5), retrying..." >&2; \
      sleep 5; \
    done; \
    [ "${ok}" -eq 1 ]; \
    rosdep install --from-paths src --ignore-src --rosdistro "${ROS_DISTRO}" -r -y; \
    rm -rf /var/lib/apt/lists/*

RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
    cd ${COLCON_WS} && \
    colcon build --symlink-install --packages-up-to turtlebot3_bringup

RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc && \
    echo "export TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL}" >> /root/.bashrc && \
    echo "alias humble='source /opt/ros/humble/setup.bash && [ -f ${COLCON_WS}/install/setup.bash ] && source ${COLCON_WS}/install/setup.bash || true'" >> /root/.bashrc

CMD ["/usr/sbin/sshd","-D"]
