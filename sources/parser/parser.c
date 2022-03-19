#include "parser.h"
#include <stdlib.h>
#include <iniparser/iniparser.h>

#define CONFIG_PATH "assets/fconfig.ini"

int parse(Configs *configs)
{
  dictionary *dictionary;
  dictionary = iniparser_load(CONFIG_PATH);
  if (NULL == dictionary)
  {
    fprintf(stderr, "cannot parse: %s\n", CONFIG_PATH);
    return EXIT_FAILURE;
  }

  configs->port = iniparser_getint(dictionary, "address:port", -1);
  configs->p1 = iniparser_getint(dictionary, "prefix:p1", -1);
  configs->p2 = iniparser_getstring(dictionary, "prefix:p2", NULL);

  iniparser_freedict(dictionary);
  return EXIT_SUCCESS;
}
