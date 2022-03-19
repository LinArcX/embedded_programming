add_library(
  util
  vector.h
  vector.c
  types.h
  types.c
  configs.h
  configs.c)

target_include_directories(util PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
