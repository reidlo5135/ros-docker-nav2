FROM ros:humble

SHELL ["/bin/bash", "-c"]

# 1. Update system packages and install required tools including SSH and rosdep
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        curl \
        gnupg \
        lsb-release \
        ca-certificates \
        git \
        openssh-server \
        python3-colcon-common-extensions \
        python3-rosdep \
        ros-humble-ros-gz-* \
    && rm -rf /var/lib/apt/lists/*

# 2. Create required directory for sshd runtime
RUN set -e
RUN grep -nE "^(#?PermitRootLogin|#?PasswordAuthentication)" /etc/ssh/sshd_config || true
RUN sed -i "s/^#\\?PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config
RUN sed -i "s/^#\\?PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd
RUN pkill sshd || true
RUN /usr/sbin/sshd
RUN echo 'root:root' | chpasswd

# 3. Initialize rosdep
RUN rosdep init || true && rosdep update

# 4. Create workspace
WORKDIR /ws
RUN mkdir -p src

# 5. Clone Navigation2 repository (Humble branch)
RUN cd src && \
    git clone -b humble https://github.com/ros-planning/navigation2.git

# 6. Install Navigation2 dependencies using rosdep
RUN apt-get update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    rm -rf /var/lib/apt/lists/*

# 7. Automatically source ROS environment on shell startup
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]
