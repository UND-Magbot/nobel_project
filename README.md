# Nobel Project

노벨오토모티브 레이저 측정값 분석 UI + PLC 중계 서버.

PLC(Siemens Modbus TCP) + RealSense 카메라에서 측정값을 수집해 자주검사 체크시트를 자동 생성하는 Windows 데스크톱 시스템입니다.

## 구성

- **[nobel/python_server/](nobel/python_server/)** — Python 중계 서버
  - PLC Modbus TCP 폴링 (`192.168.0.100:502`)
  - RealSense 카메라 2대 스트리밍
  - Flutter UI 소켓 서버 (`127.0.0.1:12345`)
  - 자주검사 체크시트 Excel 자동 저장 (`C:\nobel\검사시트\`)
- **[nobel/nobel_ui/](nobel/nobel_ui/)** — Flutter Windows UI
  - 6개 품번 탭 (MS-010 ~ MS-015)
  - 초/중/종 단계별 측정값 입력·표시
  - SQLite 로컬 DB + 엑셀 내보내기
  - 월간 Xbar-R 관리도 생성

## 빌드

### Python 서버

```powershell
cd nobel\python_server
python -m venv .venv
.venv\Scripts\activate
pip install --upgrade pip
pip install pyrealsense2 opencv-python numpy openpyxl pymodbus==2.5.3 pywin32 pyinstaller
pyinstaller main.spec --noconfirm
```

결과물: `nobel/python_server/dist/main.exe`

> ⚠ `pymodbus`는 **반드시 2.x**. 코드가 `from pymodbus.client.sync import ModbusTcpClient` 형식을 사용합니다.
>
> Intel RealSense SDK 2.0 런타임이 실행 환경에 필요: https://www.intelrealsense.com/sdk-2/

### Flutter UI

Visual Studio 2022의 "Desktop development with C++" 워크로드가 필요합니다.

```powershell
cd nobel\nobel_ui
flutter pub get
flutter build windows --release
```

결과물: `nobel/nobel_ui/build/windows/x64/runner/Release/` — **폴더 전체를 통째로 배포**해야 합니다.

## 배포

1. `main.exe`를 대상 PC의 원하는 경로에 복사 (예: `C:\nobelApp\main.exe`)
2. Flutter Release 폴더를 같은 상위 경로에 복사 (예: `C:\nobelApp\test_novel_i_r_i_s3.exe`)
3. `C:\nobel\검사시트\` 폴더 생성 (엑셀 저장 경로)
4. [시작.bat](시작.bat)의 `SERVER_EXE`, `UI_EXE` 경로를 실제 배포 경로에 맞게 수정
5. `시작.bat` 바로가기를 바탕화면에 배치

### 실행 흐름

- `시작.bat` 더블클릭 → `main.exe` 실행 중인지 확인 → 없으면 실행 + 5초 대기 → UI 실행
- UI를 닫아도 서버는 계속 실행 (측정 큐에 쌓임)
- UI 재실행 시 쌓인 큐는 비워지고 깨끗한 상태로 시작
- PC 셧다운 시 자연스럽게 종료 ([서버종료.bat](서버종료.bat)은 비상용)

## 로그

모든 로그는 `C:\nobel\logs\`에 일별 로테이션으로 저장됩니다 (30일 보관).

| 파일 | 용도 |
| --- | --- |
| `plc_data.log` | PLC Modbus 폴링 + 트리거/수집 이벤트 |
| `socket_comm.log` | Flutter로 전송한 측정값 |
| `zero_value_alert.log` | 0값 감지 경고 |

## 트러블슈팅

| 증상 | 원인 | 조치 |
| --- | --- | --- |
| `main.exe` 실행 시 `ModuleNotFoundError` | PyInstaller hidden import 누락 | `main.spec`의 `hiddenimports`에 추가 후 재빌드 |
| `pyrealsense2` 임포트 실패 | RealSense SDK 미설치 / 32-bit Python | SDK 2.0 설치 + 64-bit Python |
| `ImportError: pymodbus.client.sync` | pymodbus 3.x 설치됨 | `pip install pymodbus==2.5.3` |
| 엑셀 저장 실패 | `C:\nobel\검사시트\` 없음 | 폴더 생성 |
| Flutter 빌드 `CMake Error` | Visual Studio C++ 워크로드 미설치 | VS Installer에서 추가 |
| 데이터 안 들어옴 | PLC 연결 끊김 / 트리거 warmup 중 | `plc_data.log` 확인 |

## 주요 설계 포인트

### 트리거 가드 (유령 데이터 방지)

PLC 연결 직후나 모델 전환 직후 레지스터에 남은 이전 값이 새 트리거로 오인되지 않도록 3중 방어:

1. PLC 연결 후 5초 warmup
2. 모델 변경 후 3초 쿨다운
3. Edge detection — 트리거 값이 **변할 때만** 발사

### 서버 수명

- Flutter가 닫혀도 서버는 유지 (이전에는 `os._exit(0)`로 자폭했음)
- UI 재접속 시 `measurement_queue` 비워서 과거 데이터 유입 방지
- `SO_REUSEADDR`로 포트 재사용 충돌 예방

### 자원 정리

- `atexit`로 RealSense 파이프라인 종료 보장
- `pythoncom.CoInitialize` ↔ `CoUninitialize` 페어링, `try/finally`로 Excel COM 객체 정리

## 라이선스

Private / 노벨오토모티브 내부 사용.
