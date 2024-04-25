#!/bin/bash
# test: bash build.sh binary TCP test 
# prod: bash build.sh binary TCP prod

build_type=$1
connection_type=$2
connection_type=$( echo "$connection_type" | tr '[a-z]' '[A-Z]' )
run_type=$3

# Prod parameters as default 
lbr_port=30005
kmp_port=30002
kmr_ip=172.31.1.69
robot="turtlebot" #turtlebot or KMR
lbr_id=1
kmp_id=1
turtlebot_id=6
camera_id=1
udp_ip="129.241.90.39:5000"

if [ $build_type = 'source_' ]
then
    source ~/ros2_humble/install/setup.bash
elif [ $build_type = 'binary' ]
then
    source /opt/ros/humble/setup.bash
fi

if [ $run_type = 'test' ]
then 
    echo "Running in test mode"
    lbr_port=50007
    kmp_port=50008
    kmr_ip=127.0.0.1
    udp_ip="10.22.22.52:5000"
elif [ $run_type = 'prod' ]
then 
    echo "Running in production mode"
fi

if [ $robot = 'KMR' ]
then
    sed "/^\([[:space:]]*connection_type: \).*/s//\1\'$connection_type\'/" entity_communication/entity_communication/config/bringup_base.yaml > entity_communication/entity_communication/config/bringup.yaml
    sed -i "/^\([[:space:]]*robot: \).*/s//\1\'$robot\'/" entity_communication/entity_communication/config/bringup.yaml

    sed -i 's/lbr_id/'$lbr_id'/' entity_communication/entity_communication/config/bringup.yaml
    sed -i 's/kmp_id/'$kmp_id'/' entity_communication/entity_communication/config/bringup.yaml
    sed -i 's/camera_id/'$camera_id'/' entity_communication/entity_communication/config/bringup.yaml

    sed -i 's/lbr_port/'$lbr_port'/' entity_communication/entity_communication/config/bringup.yaml
    sed -i 's/kmp_port/'$kmp_port'/' entity_communication/entity_communication/config/bringup.yaml

    sed -i 's/lbr_ip/'$kmr_ip'/' entity_communication/entity_communication/config/bringup.yaml
    sed -i 's/kmp_ip/'$kmr_ip'/' entity_communication/entity_communication/config/bringup.yaml

    sed -i 's/camera_udp_ip/'$udp_ip'/' entity_communication/entity_communication/config/bringup.yaml
    
    colcon build --symlink-install turtlebot3_bringup turtlebot3_node
    source install/setup.bash 
    ros2 launch entity_communication entity.launch.py
    
elif [ $robot = 'turtlebot' ]
then
    cd ~/turtlebot3_ws
    #sed "/^\([[:space:]]*robot_id: \).*/s//\8\'$turtlebot_id\'/" src/turtlebot3/turtlebot3_bringup/param/waffle_pi.yaml > src/turtlebot3/turtlebot3_bringup/param/waffle_pi.yaml
    
    colcon build --symlink-install --packages-ignore turtlebot3_description turtlebot3_teleop turtlebot3_example
    #colcon build --symlink-install --packages-ignore entity_communication
    export TURTLEBOT3_MODEL=waffle_pi 
    ros2 launch turtlebot3_bringup robot.launch.py
fi

exit 0
