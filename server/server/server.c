#include "server.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#include <time.h>
#include <types.h>
#include <vector.h>
#include <database.h>

int read_size;
int descriptor;
int client_socket;
char client_message[2000];

struct sockaddr_in server;
struct sockaddr_in client;

int create_socket()
{
	descriptor = socket(AF_INET, SOCK_STREAM, 0);
	if (-1 == descriptor)
	{
		printf("ERROR: Could not create socket!\n");
    return EXIT_FAILURE;
	}
  return EXIT_SUCCESS;
}

void prepare_socket_structure(int port)
{
  server.sin_family = AF_INET;
	server.sin_addr.s_addr = INADDR_ANY;
	server.sin_port = htons(port);
}

int bind_address()
{
	if(bind(descriptor, (struct sockaddr *)&server, sizeof(server)) < 0)
	{
		printf("ERROR: Bind failed!\n");
		return EXIT_FAILURE;
	}
  return EXIT_SUCCESS;
}

int accept_incoming_connection(Configs *configs)
{
	printf("Listening on port:[%d]\n", configs->port);
  int c = sizeof(struct sockaddr_in);

  client_socket = accept(descriptor, (struct sockaddr *)&client, (socklen_t*)&c);

	if (client_socket < 0)
	{
		printf("ERROR: accept failed!\n");
		return EXIT_FAILURE;
	}

	printf("Connection accepted.\n");
  return EXIT_SUCCESS;
}

char* get_time()
{
  time_t mytime = time(NULL);
  char * time_str = ctime(&mytime);
  time_str[strlen(time_str)-1] = '\0';
  return time_str;
}

void process_input_messages()
{
  char *message_body = calloc(1, sizeof(int));

  if('p' == client_message[0])
  {
    if('1' == client_message[1])
    {
      if('\0' == client_message[2])
      {
        char* p1_body_is_empty = "[ERROR] >> p1 body is empty!";

        printf("%s\n", p1_body_is_empty);
		    write(client_socket, p1_body_is_empty, strlen(p1_body_is_empty));
        fflush(stdout);

        memset(client_message, '\0', sizeof(char)*strlen(client_message));
        return;
      }
      else
      {
        if(EXIT_SUCCESS == is_digit(&client_message[2]))
        {
          message_body = realloc(message_body, 40 + strlen(&client_message[2]));
          sprintf(message_body, "[%s], p1: [%s]", get_time(), &client_message[2]);

          printf("%s\n", message_body);
		      write(client_socket, message_body, strlen(message_body));
          fflush(stdout);

          save_message(get_time(), atoi(&client_message[2]), "");

          memset(client_message, '\0', sizeof(char)*strlen(client_message));
          free(message_body);
          return;
        }
        else
        {
          char* p1_error = "[ERROR] >> p1 isn't an integer!";

          printf("%s\n", p1_error);
		      write(client_socket, p1_error, strlen(p1_error));
          fflush(stdout);

          memset(client_message, '\0', sizeof(char)*strlen(client_message));
          return;
        }
      }
    }

    if('2' == client_message[1])
    {
      if('\0' == client_message[2])
      {
        char* p2_body_is_empty = "[ERROR] >> p2 body is empty!";

        printf("%s\n", p2_body_is_empty);
		    write(client_socket, p2_body_is_empty, strlen(p2_body_is_empty));
        fflush(stdout);

        memset(client_message, '\0', sizeof(char)*strlen(client_message));
        return;
      }
      else
      {
        message_body = realloc(message_body, 40 + strlen(&client_message[2]));
        sprintf(message_body, "[%s], p2: [%s]", get_time(), &client_message[2]);

        printf("%s\n", message_body);
	      write(client_socket, message_body, strlen(message_body));
        fflush(stdout);

        save_message(get_time(), 0, &client_message[2]);

        memset(client_message, '\0', sizeof(char)*strlen(client_message));
        free(message_body);
        return;
      }
    }
  }
  fflush(stdout);
  write(client_socket, client_message, strlen(client_message));
  memset(client_message, '\0', sizeof(char)*strlen(client_message));
}

pthread_t thread_id;
void *thread_function(void *args)
{
  int millisecond = 0;
  int trigger_moment = 1000 * 60 * 2;
  clock_t before = clock();

  printf("[%s] >> timer elapsed!\n", get_time());

  char** rows = messages();

  if (rows)
  {
    for (size_t i = 0; i < vector_size(rows); ++i)
    {
      printf("%s\n", rows[i]);
    }
    vector_free(rows);
  }

  do
  {
    millisecond = (clock() - before) * 1000 / CLOCKS_PER_SEC;
  }
  while (millisecond < trigger_moment);

  pthread_join(thread_id, NULL);
  thread_function(NULL);

  return NULL;
}

void receive_message()
{
  pthread_create(&thread_id, NULL, thread_function, NULL);
	while((read_size = recv(client_socket , client_message , 2000 , 0)) > 0 )
	{
    process_input_messages();
	}
}

void handle_exit()
{
	if(0 == read_size)
	{
		printf("Client disconnected!\n");
		fflush(stdout);
	}
	else if(-1 == read_size)
	{
		printf("ERROR: recv failed!\n");
	}
}

int run_server(Configs *configs)
{
  if(EXIT_FAILURE == create_socket())
    return EXIT_FAILURE;

  prepare_socket_structure(configs->port);

  if(EXIT_FAILURE == bind_address())
    return EXIT_FAILURE;

	listen(descriptor , 3);

  if(EXIT_FAILURE == accept_incoming_connection(configs))
    return EXIT_FAILURE;

  receive_message();
  handle_exit();

	return EXIT_SUCCESS;
}
