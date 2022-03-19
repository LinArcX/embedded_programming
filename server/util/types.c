#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>

int is_digit(char* input)
{
  for (size_t i=0; i < strlen(input); ++i)
  {
    if (!isdigit(input[i]))
    {
        return EXIT_FAILURE;
    }
  }
  return EXIT_SUCCESS;
}
