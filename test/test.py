import sys
import socket

host = "127.0.0.1"
port = 9000

client = socket.socket()

def printf(format, *args):
    sys.stdout.write(format % args)

try:
  client.connect((host, port))

  print("\n****************************************************")
  printf("***** Client connected to: [%s]:[%d]. *****\n", host, port)
  print("*****            Press :q to quit!             *****")
  print("****************************************************\n")

  while True:
      data = input("client: ")
      client.send(data.encode());
      if(data == ":q" or data == ":Q"):
          break
      print("server:", client.recv(1024).decode())
  client.close()

except socket.error as e:
  print(str(e))
