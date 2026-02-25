FROM ros:humble

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV TURTLEBOT3_MODEL=burger

# PC image: Nav2 (source build) + TurtleBot3 simulation/navigation wrapper packages
# 1. Update system packages and install required tools including SSH, rosdep and TurtleBot3 + Gazebo Classic packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        vim \
        curl \
        gnupg \
        build-essential \
        lsb-release \
        ca-certificates \
        git \
        openssh-server \
        python3-colcon-common-extensions \
        python3-rosdep \
        x11-apps \
        ros-humble-gazebo-ros-pkgs \
        ros-humble-turtlebot3-msgs \
        ros-humble-turtlebot3-description \
        ros-humble-turtlebot3-navigation2 \
        ros-humble-turtlebot3-simulations \
    && rm -rf /var/lib/apt/lists/*

# 2. Create required directory for sshd runtime
RUN set -e
RUN grep -nE "^(#?PermitRootLogin|#?PasswordAuthentication)" /etc/ssh/sshd_config || true
RUN sed -i "s/^#\\?PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config
RUN sed -i "s/^#\\?PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd
RUN pkill sshd || true
# RUN /usr/sbin/sshd
RUN echo 'root:root' | chpasswd

# 3. Initialize rosdep
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

# 4. Create workspace
WORKDIR /ws
RUN mkdir -p src

# 5. Clone Navigation2 repository (Humble branch)
RUN cd src && \
    git clone -b humble https://github.com/ros-planning/navigation2.git

# 6. Install Navigation2 dependencies using rosdep
RUN set -eux; \
    apt-get update; \
    skip_keys=""; \
    if ! apt-cache show ros-humble-gazebo-ros-pkgs >/dev/null 2>&1; then \
      skip_keys="ros-humble-gazebo-ros-pkgs gazebo_ros_pkgs"; \
    fi; \
    ok=0; \
    for i in 1 2 3; do \
      if rosdep update --rosdistro "${ROS_DISTRO}"; then ok=1; break; fi; \
      echo "rosdep update failed (attempt ${i}/3), retrying..." >&2; \
      sleep 5; \
    done; \
    [ "${ok}" -eq 1 ]; \
    ok=0; \
    for i in 1 2 3; do \
      if [ -n "${skip_keys}" ]; then \
        rosdep install --from-paths src --ignore-src --rosdistro "${ROS_DISTRO}" --skip-keys "${skip_keys}" -r -y; \
      else \
        rosdep install --from-paths src --ignore-src --rosdistro "${ROS_DISTRO}" -r -y; \
      fi && ok=1 && break; \
      echo "rosdep install failed (attempt ${i}/3), retrying..." >&2; \
      sleep 5; \
    done; \
    [ "${ok}" -eq 1 ]; \
    rm -rf /var/lib/apt/lists/*

# 7. Automatically source ROS environment on shell startup
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc && \
    echo "export TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL}" >> /root/.bashrc && \
    echo "alias humble='source /opt/ros/humble/setup.bash && [ -f /ws/install/setup.bash ] && source /ws/install/setup.bash || true'" >> /root/.bashrc

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]
