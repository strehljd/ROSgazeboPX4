# ROSgazeboPX4
This is the result of the installation guide provided by the IRT.

# Build docker container
```
docker build . -t rosgazebopx4
```

To allow usage of private repositories (using ssh authentication) use: 
```
docker buildx build --ssh default=$SSH_AUTH_SOCK -t rosgazebo:submodules --target SITL_GAZEBO .
```

# Start the docker container

In your ubuntu systems allow xhost sharing:

```
xhost +local:root
```

Then, start docker container using: (see http://wiki.ros.org/docker/Tutorials/GUI)
```
sudo docker run \
    --net=host \
    --privileged \
    --rm \
    -it \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    rosgazebopx4 \
    bash
```
In the docker container, source: 

```
source Tools/simulation/gazebo-classic/setup_gazebo.bash $(pwd) $(pwd)/build/px4_sitl_default
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd):$(pwd)/Tools/simulation/gazebo-classic/sitl_gazebo-classic
```

Look at the fancy gazebo with:
```
roslaunch px4 multi_uav_mavros_sitl.launch
```

When done remove xhost priviliges: 
```
xhost -local:root
```