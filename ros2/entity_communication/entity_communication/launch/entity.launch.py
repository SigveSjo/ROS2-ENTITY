import os
import sys
import yaml
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node

def generate_launch_description(argv=sys.argv[1:]):
    pkg_name = 'entity_communication'

    config_file_path = os.path.join(
            get_package_share_directory(pkg_name),
            'config',
            'bringup.yaml')
    config_file = open(config_file_path)
    parsed_config_file = yaml.load(config_file, Loader=yaml.FullLoader)
    
    connection_params = parsed_config_file['connection_params']['ros__parameters']
    
    connection_type = connection_params['connection_type']
    robot = connection_params['robot']

    param_dir = LaunchConfiguration(
        'param_dir',
        default=config_file_path
    )
    
    # Choose nodes depending on what robot is selected from the bringup.yaml
    launch_description = None
    if robot == "KMR":
    	launch_description = LaunchDescription([
        DeclareLaunchArgument(
                'param_dir',
                default_value=param_dir,
                description="Full path to parameter file to load"
            ),

        Node(
            package=pkg_name,
            executable='lbr',
            name='lbr_command_node',
            output='screen',
            emulate_tty=True,
            arguments=['-c', connection_type, '-ro', robot],
            parameters=[param_dir]
        ), 

        Node(
            package=pkg_name,
            executable='kmp',
            name='kmp_command_node',
            output='screen',
            emulate_tty=True,
            arguments=['-c', connection_type, '-ro', robot],
            parameters=[param_dir]
        ),
        
        Node(
            package=pkg_name,
            executable='camera',
            name='camera_node',
            output='screen',
            emulate_tty=True,
            arguments=['-ro', robot],
            parameters=[param_dir]
        ),
    ])
    elif robot == "turtlebot":
    	launch_description = LaunchDescription([
        DeclareLaunchArgument(
                'param_dir',
                default_value=param_dir,
                description="Full path to parameter file to load"
            ),
        
        Node(
            package=pkg_name,
            executable='turtlebot',
            name='turtlebot_command_node',
            output='screen',
            emulate_tty=True,
            arguments=['-c', connection_type, '-ro', robot],
            parameters=[param_dir]
        ),

        Node(
            package=pkg_name,
            executable='camera',
            name='camera_node',
            output='screen',
            emulate_tty=True,
            arguments=['-ro', robot],
            parameters=[param_dir]
        ),
    ])

    return launch_description
