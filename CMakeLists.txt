cmake_minimum_required (VERSION 2.8)
project(AK2 C ASM)

set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -no-pie -Wall -lboost_unit_test_framework")
set(CMAKE_BUILD_TYPE Debug)

file(MAKE_DIRECTORY bin)
set(CMAKE_BINARY_DIR ${CMAKE_SOURCE_DIR}/bin)
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR})
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})


enable_testing()
add_subdirectory(src)
# add_subdirectory(test)
add_test(NAME Test COMMAND Test)
set(UNIT_TEST Test)
