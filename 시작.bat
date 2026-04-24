@echo off
REM ============================================================
REM nobel_project 통합 실행 스크립트
REM - main.exe (Python 서버) 가 떠있지 않으면 먼저 실행
REM - test_novel_i_r_i_s3.exe (Flutter UI) 실행
REM UI만 껐다 켜려면 이 bat 을 다시 더블클릭해도 서버가 중복 실행되지 않습니다.
REM ============================================================

set "SERVER_EXE=C:\nobelApp20260423\main.exe"
set "UI_EXE=C:\nobelApp20260423\test_novel_i_r_i_s3.exe"

REM === 서버 중복 실행 방지 ===
tasklist /FI "IMAGENAME eq main.exe" 2>nul | find /I "main.exe" >nul
if errorlevel 1 (
    start "" "%SERVER_EXE%"
    REM 서버 초기화 대기 (5초)
    timeout /t 5 /nobreak >nul
)

REM === UI 실행 ===
start "" "%UI_EXE%"
