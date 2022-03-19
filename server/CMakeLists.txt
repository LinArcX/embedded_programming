add_executable(${NAME} main.c)

add_subdirectory(util)
add_subdirectory(database)
add_subdirectory(parser)
add_subdirectory(server)

target_link_libraries(${NAME} PUBLIC pthread)
target_link_libraries(${NAME} PUBLIC util)
target_link_libraries(${NAME} PUBLIC database)
target_link_libraries(${NAME} PUBLIC parser)
target_link_libraries(${NAME} PUBLIC server)
