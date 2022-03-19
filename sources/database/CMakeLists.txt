FIND_PACKAGE(PkgConfig REQUIRED)
PKG_CHECK_MODULES(SQLITE3 REQUIRED sqlite3)

add_library(
  database
  database.h
  database.c)

target_include_directories(database PUBLIC
  ${SQLITE3_INCLUDE_DIRS}
  "${CMAKE_CURRENT_SOURCE_DIR}"
  util)

target_link_libraries(database PUBLIC
  ${SQLITE3_LIBRARIES}
  util)
