import socket
import threading
import time
from pycomm3 import LogixDriver  # EtherNet/IP 라이브러리 설치 필요: `pip install pycomm3`
import pyrealsense2 as rs
import numpy as np
import cv2
import base64
import datetime
import json
import struct

from pymodbus.client import ModbusTcpClient

names = ['MS-010']

value_num = [[2],[2],[2,3],[2],[1,2,3],[1,2,4]]

class Data:
    
    def __init__(self, name, values, image):
        date = datetime.now()
        self.date = date.strftime('%Y-%m-%d')
        self.name = name
        self.values = values
        self.image = image
        
    def toJson(self):
        return json.dumps(self.__dict__, ensure_ascii=False)
    
class Server:
    def __init__(self, flutter_host, flutter_port):
        self.flutter_host = flutter_host
        self.flutter_port = flutter_port

        self.flutter_socket = None
        self.plc_connection = None
        self.is_flutter_connected = False
        
        self.pipeline = rs.pipeline()
        config = rs.config()
        config.enable_stream(rs.stream.color, 640, 480, rs.format.bgr8, 30)  # 컬러 영상 설정
        self.pipeline.start(config)

    def is_socket_connected(self, sock):
        """소켓 연결 상태를 getsockopt로 확인"""
        try:
            # 소켓 옵션 SO_ERROR를 확인 (0이면 정상, 그렇지 않으면 오류)
            err = sock.getsockopt(socket.SOL_SOCKET, socket.SO_ERROR)
            return err == 0
        except socket.error:
            self.is_flutter_connected = False
            return False

    def connect_flutter(self):
        """Flutter 앱과 소켓 연결을 시도"""
        while not self.is_flutter_connected:
            try:
                print(f"Connecting to Flutter at {self.flutter_host}:{self.flutter_port}...")
                self.flutter_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                self.flutter_socket.connect((self.flutter_host, self.flutter_port))
                self.is_flutter_connected = True
                print("Flutter connected successfully.")
            except (ConnectionRefusedError, socket.error):
                print("Failed to connect to Flutter. Retrying in 5 seconds...")
                time.sleep(5)


    def start(self):
        """서버 시작"""
        # PLC 연결
        self.connect_plc()

        # Flutter 연결 스레드
        flutter_thread = threading.Thread(target=self.connect_flutter, daemon=True)
        flutter_thread.start()
        
        # PLC 데이터 읽기 및 Flutter로 전송
        self.listen_plc()

# 실행 예시
if __name__ == "__main__":
    FLUTTER_HOST = "127.0.0.1"  # Flutter 앱의 호스트 주소
    FLUTTER_PORT = 12345        # Flutter 앱의 포트 번호
    PLC_IP = "192.168.0.10"     # PLC의 IP 주소
    PLC_FLAG_TAG = "Flag"            # PLC에서 읽을 태그 이름
    PLC_DATA_TAG = "Data"            # PLC에서 읽을 태그 이름

    server = FlutterServer(FLUTTER_HOST, FLUTTER_PORT, PLC_IP, PLC_FLAG_TAG, PLC_DATA_TAG)
    server.start()
