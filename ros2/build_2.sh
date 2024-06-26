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
robot="KMR"
lbr_id=2
kmp_id=2
camera_id=2
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

sed "/^\([[:space:]]*connection_type: \).*/s//\1\'$connection_type\'/" kmr_communication/kmr_communication/config/bringup_base.yaml > kmr_communication/kmr_communication/config/bringup.yaml
sed -i "/^\([[:space:]]*robot: \).*/s//\1\'$robot\'/" kmr_communication/kmr_communication/config/bringup.yaml

sed -i 's/lbr_id/'$lbr_id'/' kmr_communication/kmr_communication/config/bringup.yaml
sed -i 's/kmp_id/'$kmp_id'/' kmr_communication/kmr_communication/config/bringup.yaml
sed -i 's/camera_id/'$camera_id'/' kmr_communication/kmr_communication/config/bringup.yaml

sed -i 's/lbr_port/'$lbr_port'/' kmr_communication/kmr_communication/config/bringup.yaml
sed -i 's/kmp_port/'$kmp_port'/' kmr_communication/kmr_communication/config/bringup.yaml

sed -i 's/lbr_ip/'$kmr_ip'/' kmr_communication/kmr_communication/config/bringup.yaml
sed -i 's/kmp_ip/'$kmr_ip'/' kmr_communication/kmr_communication/config/bringup.yaml

sed -i 's/camera_udp_ip/'$udp_ip'/' kmr_communication/kmr_communication/config/bringup.yaml

colcon build --symlink-install
source install/setup.bash 
ros2 launch kmr_communication kmr.launch.py

exit 0
