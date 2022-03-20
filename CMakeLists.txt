cmake_minimum_required(VERSION 3.12)

SET(NAME myserver)
SET(CMAKE_C_STANDARD 11)
SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)

project(${NAME} LANGUAGES C)
project(${NAME} VERSION 1.0.0)

add_subdirectory(server)

set_target_properties(${NAME} PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY_DEBUG   ${CMAKE_SOURCE_DIR}/output/x64/debug
  RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_SOURCE_DIR}/output/x64/release
)
