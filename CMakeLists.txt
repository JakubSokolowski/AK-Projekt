cmake_minimum_required (VERSION 2.8)
project(AK2_Projekt C ASM)

set_source_files_properties(print.s PROPERTIES COMPILE_FLAGS "-x assembler-with-cpp")


file(MAKE_DIRECTORY bin)
set(CMAKE_BINARY_DIR ${CMAKE_SOURCE_DIR}/bin)
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR})
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})

include_directories("${PROJECT_SOURCE_DIR}/src")
add_executable(main src/main.c src/cryptography/print.s)
