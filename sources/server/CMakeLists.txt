add_library(
  server
  server.h
  server.c
)

target_link_libraries(server PUBLIC util database pthread)

target_include_directories(server PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}"
  util
  database)
