cmake_minimum_required(VERSION 3.5)
project(yarp_test)

find_package(YARP COMPONENTS OS REQUIRED)

add_executable(yarp_test main.cpp)
target_link_libraries(yarp_test YARP::YARP_OS YARP::YARP_init)
