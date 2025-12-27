# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(flutter_opencv_library VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(OpenCV REQUIRED)

add_library(flutter_opencv SHARED
  "flutter_opencv.cc"
)

set_target_properties(flutter_opencv PROPERTIES
  PUBLIC_HEADER flutter_opencv.h
  OUTPUT_NAME "flutter_opencv"
)

target_link_libraries(flutter_opencv PRIVATE ${OpenCV_LIBS})

target_compile_definitions(flutter_opencv PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(flutter_opencv PRIVATE "-Wl,-z,max-page-size=16384")
endif()
