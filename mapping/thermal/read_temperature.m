clear all
clear 
clc

data_bag = rosbag('2020-08-19-11-13-27.bag');
thermal_bag = select(data_bag, 'Topic', '/thermalgrabber_ros/image_mono16');
thermal_msg = readMessages(thermal_bag,'DataFormat','struct');
