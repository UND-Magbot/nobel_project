import socket

TCP_IP = '192.xxx.x.xxx' # PLC의 ip
TCP_PORT = 2004 # PLC의 포트번호 TCP는 2004 UDP는 2005
BUFFER_SIZE = 1024
message = (b'LSIS-XGT\n\n\n\n\xA0\x33\x00\x00\x12\x00\x02\x00\x54\x00\x02\x00\00\00\x01\x00\x08\x00%DW00000')
    # (b'LSIS-XGT\n\n\n\n\xA0\x33\x00\x01\x10\x00\x00\x09\x54\x00\x14\x00\x00

# 소켓 오픈 
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 
s.connect((TCP_IP, TCP_PORT)) # 소켓 연결
s.send(message) # 메세지를 보낸다.
data = s.recv(BUFFER_SIZE) # 메세지를 받는다
s.close() # 소켓 닫기

print("received data: ", data.hex()) # 받은 메세지를 hex형태로 출력