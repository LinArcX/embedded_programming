add_library(
  parser
  parser.h
  parser.c
)

target_link_libraries(parser PUBLIC
  ${PROJECT_SOURCE_DIR}/dependencies/lib/libiniparser.a
  util)

target_include_directories(parser PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}"
  util
  ${PROJECT_SOURCE_DIR}/dependencies/include)
