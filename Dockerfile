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
WORKDIR /src/Firmware
RUN bash ./Tools/setup/ubuntu.sh

FROM build1 AS build12

# ROS install
WORKDIR /src

# install keyboard-config seperately as it requires an user-input which cannot be supressed in the bash script
RUN DEBIAN_FRONTEND=noninteractive apt update && apt install -y \
    keyboard-configuration

COPY *.sh /src
RUN bash ubuntu_sim_ros_noetic.sh

#Install geographiclib
RUN apt update && apt install -y \
   geographiclib-tools
RUN chmod +x /src/install_geographiclib_datasets.sh && /src/install_geographiclib_datasets.sh

# install submodules
WORKDIR /src/Firmware
RUN git submodule update --init --recursive
RUN DONT_RUN=1 make px4_sitl_default gazebo