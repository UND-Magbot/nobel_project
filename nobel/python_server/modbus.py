import os
import platform
import subprocess
from concurrent.futures import ThreadPoolExecutor

def ping(ip):
    """ 지정된 IP 주소에 Ping을 보내 응답 여부를 확인 """
    param = "-n" if platform.system().lower() == "windows" else "-c"
    try:
        result = subprocess.run(["ping", param, "1", "-w", "500", ip], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if "TTL=" in result.stdout or "ttl=" in result.stdout:  # Windows/Linux 응답 확인
            return ip
    except Exception as e:
        pass
    return None

def find_active_ips(network_prefix="192.168.0."):
    """ 192.168.0.1 ~ 192.168.0.255 중 응답이 있는 IP를 찾기 """
    active_ips = []
    with ThreadPoolExecutor(max_workers=20) as executor:  # 병렬 실행 (최대 20개 동시 요청)
        results = list(executor.map(ping, [f"{network_prefix}{i}" for i in range(1, 256)]))

    active_ips = [ip for ip in results if ip]
    return active_ips

# ✅ 실행 및 결과 출력
active_ips = find_active_ips()
if active_ips:
    print("✅ 응답이 있는 IP 목록:")
    for ip in active_ips:
        print(f" - {ip}")
else:
    print("❌ 응답하는 IP가 없습니다.")
