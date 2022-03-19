#include <stdlib.h>

#include <parser.h>
#include <server.h>
#include <configs.h>
#include <database.h>

int main(int argc, char * argv[])
{
  Configs configs;

  if(EXIT_FAILURE == prepare_database(&configs))
    return EXIT_FAILURE;

  if(EXIT_FAILURE == parse(&configs))
    return EXIT_FAILURE;

  if(EXIT_FAILURE == run_server(&configs))
    return EXIT_FAILURE;

  return EXIT_SUCCESS;
}
