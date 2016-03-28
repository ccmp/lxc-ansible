from __future__ import print_function
import socket
import select
import re
import errno
import signal
import os

global hello_msg
global readfds

def handler_usr1(signum,frame):
  global hello_msg
  hello_msg="I am preparing for the SHUTDOWN."
  print("Signal handler call with signal:{0}".format(signum))
  return(0)

def handler_inter(signum,frame):
  print("Signal handler call with signal:{0}".format(signum))
  for sock in readfds:
    print("finally close socket:{0}".format(sock))
    sock.close()
    os._exit(0)
  
def main():
  global hello_msg
  global readfds
  
  host = '0.0.0.0'
  port = 4000
  backlog = 10
  bufsize = 4096
  icount=0
  icount2={}

  hello_msg="I am FINE."
  re_hello=re.compile("HELLO")
  re_quit=re.compile("QUIT")

  signal.signal(signal.SIGUSR1,handler_usr1)
  signal.siginterrupt(signal.SIGUSR1,False)
  signal.signal(signal.SIGINT,handler_inter)
  
  server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  readfds = set([server_sock])
  
  for i in readfds:
      print("open initial socket:{0}".format(i))
  
  #try:
  server_sock.bind((host, port))
  server_sock.listen(backlog)
  #except socket.error as e:
  #  raise e
    
  while True:
    try:
      rready, wready, xready = select.select(readfds, [], [])
    except:
      continue
    
    for sock in rready:
      if sock is server_sock:
        conn, address = server_sock.accept()
        #print("open socket:{0}".format(conn))
        readfds.add(conn)
        icount2[conn]=0
      else:
        try:
          msg = sock.recv(bufsize)
        except socket.error as rerr:
          if rerr.errno != errno.ECONNRESET:
            raise rerr
          #print("close socket reset by peer:{0}".format(sock))
          sock.close()
          readfds.remove(sock)
        else:
          if len(msg) == 0 or re_quit.match(msg):
            #print("close socket:{0}".format(sock))
            sock.close()
            readfds.remove(sock)
          elif re_hello.match(msg):
            #print(msg)
            msg1="HELLO This is "+socket.gethostname()+". "+hello_msg+" :"+"T={0}".format(icount)+":I={0}".format(icount2[sock])+":From={0}".format(sock.getpeername())
            sock.send(msg1)
            icount +=1
            icount2[sock] +=1
    
#  for sock in readfds:
#    print("finally close socket:{0}".format(sock))
#    sock.close()
  return

if __name__ == '__main__':
  main()
