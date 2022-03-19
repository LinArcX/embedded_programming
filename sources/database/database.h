#ifndef MODULE_UTILITY_SQLITE_H
#define MODULE_UTILITY_SQLITE_H

#include <sqlite3.h>

int prepare_database();

char** messages();
int save_message(char* date, int p1_message, char* p2_message);
#endif
