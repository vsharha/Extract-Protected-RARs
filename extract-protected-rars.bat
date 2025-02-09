@echo off
setlocal enabledelayedexpansion

:: Set path to 7-Zip (modify this according to your 7-Zip installation path)
set "sevenzip=C:\Program Files\7-Zip\7z.exe"

:: Create log file name with timestamp
set "timestamp=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=%timestamp: =0%"
set "logfile=failed_extractions_%timestamp%.log"

:: Create main extraction directory
mkdir "extracted" 2>nul

:: Function to log with timestamp
call :LogMessage "Extraction process started by user: %USERNAME%"

:: Check if rar_passwords.csv exists
if not exist "rar_passwords.csv" (
    echo Error: rar_passwords.csv not found!
    call :LogMessage "Error: rar_passwords.csv not found!"
    pause
    exit /b 1
)

:: Process each RAR file
for %%R in (*.rar) do (
    set "rar_name=%%~nR"
    set "password="
    
    :: Find password in CSV for current RAR
    for /f "usebackq tokens=1,2 delims=," %%a in ("rar_passwords.csv") do (
        if "%%a"=="!rar_name!" set "password=%%b"
    )
    
    if defined password (
        echo Processing: %%R
        mkdir "extracted\%%~nR" 2>nul
        "%sevenzip%" x "%%R" -o"extracted\%%~nR" -p"!password!" -y
        if !errorlevel! equ 0 (
            echo Successfully extracted: %%R
        ) else (
            echo Failed to extract: %%R
            call :LogMessage "Failed to extract: %%R - Error level: !errorlevel!"
        )
    ) else (
        echo Warning: No password found for %%R
        call :LogMessage "No password found for: %%R"
    )
)

echo.
echo Extraction complete!
echo Check %logfile% for any failed extractions.
echo All files have been extracted to the "extracted" folder
echo Original RAR files have been preserved.
pause
exit /b 0

:LogMessage
set "message=%~1"
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "datetime=%%I"
set "timestamp=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2% %datetime:~8,2%:%datetime:~10,2%:%datetime:~12,2%"
echo %timestamp% - %message%>>"%logfile%"
exit /b