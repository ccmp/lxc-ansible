from __future__ import print_function
import socket
import select
import re

def main():
  host = '0.0.0.0'
  port = 4000
  backlog = 10
  bufsize = 4096
  icount=0
  icount2={}

  re_hello=re.compile("HELLO")
  re_quit=re.compile("QUIT")
  
  server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  readfds = set([server_sock])
  for i in readfds:
      print("open initial socket:{0}".format(i))
  
  try:
    server_sock.bind((host, port))
    server_sock.listen(backlog)

    while True:
      rready, wready, xready = select.select(readfds, [], [])
      for sock in rready:
        if sock is server_sock:
          conn, address = server_sock.accept()
          print("open socket:{0}".format(conn))
          readfds.add(conn)
          icount2[conn]=0
        else:
          msg = sock.recv(bufsize)
          if len(msg) == 0 or re_quit.match(msg):
            print("close socket:{0}".format(sock))
            sock.close()
            readfds.remove(sock)
          else:
            if re_hello.match(msg):
              print(msg)
              msg1="HELLO This is "+socket.gethostname()+". I am FINE. :"+"T={0}".format(icount)+":I={0}".format(icount2[sock])
              sock.send(msg1)
              icount +=1
              icount2[sock] +=1
  finally:
    for sock in readfds:
      print("finally close socket:{0}".format(sock))
      sock.close()
  return

if __name__ == '__main__':
  main()
