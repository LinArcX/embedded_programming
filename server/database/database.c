#include "configs.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sqlite3.h>
#include <linux/limits.h>

#include <vector.h>

#define buffer_size 1024
#define RELATIVE_PATH "/assets/database.sqlite"

#define SQL_CREATE_MESSAGE_TABLE "CREATE TABLE IF NOT EXISTS messages(ID INTEGER PRIMARY KEY, date TEXT NOT NULL, p1_message INTEGER, p2_message TEXT);"
#define SQL_SELECT_P1_MESSAGES "SELECT p1_message FROM messages where p2_message == \"\" ORDER BY p1_message ASC"
#define SQL_INSERT_TO_MESSAGES "INSERT INTO messages(date, p1_message, p2_message) VALUES(?1, ?2, ?3);"

char* db_path;
sqlite3* m_database;

static int callback(void* files, int argc, char** argv, char** azColName) { return 0; }

int open_database(char* path)
{
  db_path = path;
  if (SQLITE_OK != sqlite3_open(path, &m_database))
  {
    fprintf(stderr, "[ERROR::DATABASE] open_database(): %s\n", sqlite3_errmsg(m_database));
    sqlite3_close(m_database);
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}

int execute(char* command)
{
  char* message = NULL;
  if (SQLITE_OK != sqlite3_exec(m_database, command, callback, 0, &message))
  {
    fprintf(stderr, "[ERROR::DATABASE] execute(): %s\n", message);
    sqlite3_free(message);
  }
  return EXIT_SUCCESS;
}

void create_table(char* statement)
{
  if (SQLITE_OK == open_database(db_path))
  {
      execute(statement);
  }
  sqlite3_close(m_database);
}

void wipe_table(char* statement)
{
  if (open_database(db_path))
  {
      execute(statement);
  }
  sqlite3_close(m_database);
}

int save_message(char* date, int p1_message, char* p2_message)
{
  if (EXIT_FAILURE == open_database(db_path))
    return EXIT_FAILURE;
  else
  {
    sqlite3_stmt* statement = NULL;

    if(sqlite3_prepare_v2(m_database, SQL_INSERT_TO_MESSAGES, -1, &statement, NULL))
    {
      printf("[ERROR::DATABASE] save_message()\n");
      sqlite3_close(m_database);
      return EXIT_FAILURE;
    }

    sqlite3_bind_text(statement, 1, date , -1, SQLITE_STATIC);
    sqlite3_bind_int(statement, 2, p1_message);
    sqlite3_bind_text(statement, 3, p2_message, -1, SQLITE_STATIC);

    if (SQLITE_DONE != sqlite3_step(statement))
    {
      printf("[ERROR::DATABASE] save_message(): %s\n", sqlite3_errmsg(m_database));
      sqlite3_close(m_database);
      return EXIT_FAILURE;
    }
    sqlite3_finalize(statement);
  }
  return EXIT_SUCCESS;
}

char** messages()
{
  char** messages = NULL;
  if (EXIT_FAILURE == open_database(db_path))
    return NULL;
  else
  {
    sqlite3_stmt* statement;
    sqlite3_prepare_v2(m_database, SQL_SELECT_P1_MESSAGES, -1, &statement, NULL);
    while (SQLITE_ROW == sqlite3_step(statement))
    {
      char* project_name = malloc(sizeof(char) * buffer_size);
      memset(project_name, 0, sizeof(char) * buffer_size);
      strcpy(project_name, (const char*) sqlite3_column_text(statement, 0));
      vector_push_back(messages, project_name);
    }
    sqlite3_finalize(statement);
  }
  sqlite3_close(m_database);
  return messages;
}

int database_path(Configs *configs)
{
  configs->db_path = (char*) calloc(1, sizeof(char));

  char cwd[PATH_MAX];
  if (NULL == getcwd(cwd, sizeof(cwd)))
  {
    return EXIT_FAILURE;
  }

  char* relative_path = RELATIVE_PATH;

  configs->db_path = (char*) realloc(configs->db_path, strlen(cwd) + strlen(relative_path) + 1);
  strcat(configs->db_path, cwd);
  strcat(configs->db_path, relative_path);

  return EXIT_SUCCESS;
}

int prepare_database(Configs* configs)
{
  if(EXIT_FAILURE == database_path(configs))
    return EXIT_FAILURE;

  if (EXIT_FAILURE == open_database(configs->db_path))
    return EXIT_FAILURE;
  else
    create_table(SQL_CREATE_MESSAGE_TABLE);
  return EXIT_SUCCESS;
}
