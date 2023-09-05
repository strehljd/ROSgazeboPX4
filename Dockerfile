FROM ubuntu:20.04 as dependecies
ENV DEBIAN_FRONTEND=noninteractive

# install dependecies
RUN apt update && apt install -y \
    bash\
    sudo\
    wget\
    lsb-release\
    git \
    gnupg
# gnupg required for set up script

FROM dependecies as build1

# PX4 firmware github clone
WORKDIR /src
RUN git clone https://github.com/PX4/Firmware.git --recursive

# setup of the development environment
WORKDIR Firmware
RUN bash ./Tools/setup/ubuntu.sh

FROM build1 AS build12

# ROS install
WORKDIR /src

# install keyboard-config seperately as it requires an user-input which cannot be supressed in the bash script
RUN DEBIAN_FRONTEND=noninteractive apt update && apt install -y \
    keyboard-configuration


RUN wget https://raw.githubusercontent.com/PX4/PX4-Devguide/pr-installation-instructions-noetic/build_scripts/ubuntu_sim_ros_noetic.sh
# COPY ubuntu_sim_ros_noetic.sh /src
RUN bash ubuntu_sim_ros_noetic.sh

# install submodules
WORKDIR /src/Firmware
RUN git submodule update --init --recursive
RUN DONT_RUN=1 make px4_sitl_default gazebo

# # add firmware to ROS path
# RUN echo "source Tools/simulation/gazebo-classic/setup_gazebo.bash $(pwd) $(pwd)/build/px4_sitl_default" >> ~/.bashrc \
#     && echo "export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd):$(pwd)/Tools/simulation/gazebo-classic/sitl_gazebo-classic" >> ~/.bashrc
#sudo docker run     --net=host     --privileged     --rm     -it      --env="DISPLAY"     --env="QT_X11_NO_MITSHM=1"     --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" osrf/ros:indigo-desktop-full bash