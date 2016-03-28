from __future__ import print_function
import socket
import select
import re
import errno
import os
import time
import threading

g_counter = 0

def client_test(host,port,count,duration):

  global g_counter
  global g_lock
  
  bufsize=4096
  smsg="HELLO"
  cerr_count=0
  serr_count=0
  rerr_count=0
  merr_count=0

  re_fine=re.compile(".*FINE.*")
  
  wait_time=duration/count
  myname=threading.currentThread().getName()
  
  client_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  client_sock.settimeout(5)
  for x in range(3):
    try:
      client_sock.connect((host,port))
      #print("{0}:Connect to {1}".format(myname,client_sock.getpeername()))
      break
    except socket.error as cerr:
      print("{0}:Try:{1} failed: connect to {2}:{3}".format(myname,x,host,port))
      cerr_count+=1
      time.sleep(3)
    if x == 2 :
      print("{0}:Try:{1} Finaly failed: connect to {2}:{3}".format(myname,x,host,port))
      return (1)
  print("{0}:Connected to {1}".format(myname,client_sock.getpeername()))
  g_counter+=1
  
  for i in range(count):
    time.sleep(wait_time)
    try:
      if len(smsg) != client_sock.send(smsg):
        print("{0}:Count:{1} Cannot send all message to {2}".format(myname,i,client_sock.getpeername()))
    except socket.error as serr:
      print("{0}:Count:{1} At send message,exception occur:{2}".format(myname,i,serr.strerror))
      serr_count+=1
      continue
    #print("{0}:Count:{1} Send message :{2}".format(myname,i,smsg))
    
    try:
      rmsg=client_sock.recv(bufsize)
    except socket.error as rerr:
      rerr_count+=1
      if rerr.errno == errno.ECONNRESET:
        print("{0}:Count:{1} close socket reset by peer:{2}".format(myname,i,sock))
        break
      else:
        print("{0}:Count:{1} At recive message,exception raise:{2}".format(myname,i,rerr.strerror))
        continue
    #print("{0}:Count:{1} Recive message :{2}".format(myname,i,rmsg))
    if not re_fine.match(rmsg):
      print("{0}:Count:{1} Recive invaild message :{2}".format(myname,i,rmsg))
      merr_count+=1
      
  print("{0}:close to {1}".format(myname,client_sock.getpeername()))
  print("{0}:finished. cerr={1},serr={2},rerr={3},merr={4}".format(myname,cerr_count,serr_count,rerr_count,merr_count))
  client_sock.close()
  g_counter-=1
  return (0)
              
def main():
  host = '10.254.10.1'
  port = 4000
  count = 10
  duration = 70
  thread_max = 12

  threads=set([])
  while True:
    if g_counter <= thread_max :
      client_thread = threading.Thread(target=client_test,args=(host,port,count,duration))
      #threads.add(client_thread)
      client_thread.start()
    time.sleep(5)
              
if __name__ == '__main__':
  main()
