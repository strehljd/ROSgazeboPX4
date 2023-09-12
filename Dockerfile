### build stage for basic deps ###
FROM ubuntu:20.04 as dependecies
ENV DEBIAN_FRONTEND=noninteractive

# install dependecies
RUN apt update && apt install -y \
    bash\
    sudo\
    wget\
    lsb-release\
    git \
    openssh-client\
    gnupg
# gnupg required for set up script

### build stage 1 ###
FROM dependecies as build1
# prepare for private ssh clone
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# PX4 firmware github clone
WORKDIR /src
# COPY PX4-Autopilot /src/PX4-Autopilot
RUN --mount=type=ssh git clone -b git_submodules https://github.com/strehljd/PX4-Autopilot.git --recursive
# here I am using my forked version. This can be changed to the origianal repo if there are no changes necessary

# setup of the development environment
WORKDIR /src/PX4-Autopilot
RUN bash ./Tools/setup/ubuntu.sh

###  build stage 2 ###
FROM build1 AS build12
# we need an additional build stage to "restart"

WORKDIR /src
# get setup scripts from host machine
COPY *.sh /src

# install keyboard-config seperately as it requires an user-input which cannot be supressed in the bash script
RUN DEBIAN_FRONTEND=noninteractive apt update && apt install -y \
    keyboard-configuration

#Install geographiclib
RUN apt update && apt install -y \
   geographiclib-tools
RUN chmod +x /src/install_geographiclib_datasets.sh && /src/install_geographiclib_datasets.sh

# install ROS
RUN bash ubuntu_sim_ros_noetic.sh

# get additional git content
WORKDIR /src/PX4-Autopilot
RUN --mount=type=ssh git fetch --tags && git submodule update --init --recursive 
# tags have to be fetched for the build process - otherwise CMAKE will fail (see https://github.com/PX4/PX4-Autopilot/issues/21644#issuecomment-1674169116)

### build stage SITL GAZEBO ###
FROM build2 as SITL_GAZEBO
# build with Sofware In The Loop (gazebo) as target
RUN DONT_RUN=1 make px4_sitl_default gazebo