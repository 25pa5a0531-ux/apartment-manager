@echo off
title Apartment Management - Launcher

echo =====================================================================
echo    Apartment Visitor and Maintenance Management System Launcher
echo =====================================================================
echo.

:: 1. Navigate to script directory
cd /d "%~dp0"

:: 2. Check if Node.js is installed
where node >nul 2>&1
if errorlevel 1 goto :node_missing

:: 3. Select npm command (prefer npm.cmd on Windows)
set NPM_CMD=npm
where npm.cmd >nul 2>&1
if not errorlevel 1 set NPM_CMD=npm.cmd

echo [OK] Node.js is available:
node -v
echo [OK] Using package manager: %NPM_CMD%
echo.

:: 4. Verify project structure exists
if not exist "%~dp0server\package.json" goto :server_missing
if not exist "%~dp0client\package.json" goto :client_missing

:: 5. Preserve existing .env or create default if missing
if exist "%~dp0server\.env" goto :env_ready
echo [INFO] server\.env not found. Creating default configuration...
> "%~dp0server\.env" echo PORT=5000
>> "%~dp0server\.env" echo JWT_SECRET=apartment_management_secret_key_college_project_2026
>> "%~dp0server\.env" echo NODE_ENV=development
echo [OK] server\.env created.
:env_ready

:: 6. Install Server Dependencies if missing
if exist "%~dp0server\node_modules" goto :server_deps_ok
echo [INFO] Server dependencies not found. Installing now...
cd /d "%~dp0server"
call %NPM_CMD% install
if errorlevel 1 goto :server_install_failed
cd /d "%~dp0"
echo [OK] Server dependencies installed.
:server_deps_ok

:: 7. Install Client Dependencies if missing
if exist "%~dp0client\node_modules" goto :client_deps_ok
echo [INFO] Client dependencies not found. Installing now...
cd /d "%~dp0client"
call %NPM_CMD% install
if errorlevel 1 goto :client_install_failed
cd /d "%~dp0"
echo [OK] Client dependencies installed.
:client_deps_ok

echo.
echo =====================================================================
echo    Launching Backend and Frontend in separate windows...
echo =====================================================================
echo.

:: 8. Launch Backend Server in its own window
echo [1/2] Starting Backend Server on port 5000...
start "Apartment Backend Server (Port 5000)" cmd.exe /k "cd /d ""%~dp0server"" && %NPM_CMD% start"

:: Wait 2 seconds for backend initialization
timeout /t 2 /nobreak >nul 2>&1

:: 9. Launch Frontend Server in its own window
echo [2/2] Starting Frontend Vite Server on port 5173...
start "Apartment Frontend Server (Port 5173)" cmd.exe /k "cd /d ""%~dp0client"" && %NPM_CMD% run dev"

:: Wait 3 seconds for Vite initialization
timeout /t 3 /nobreak >nul 2>&1

:: 10. Open web browser to the application URL
echo.
echo [INFO] Opening application in default browser: http://localhost:5173
start http://localhost:5173

echo.
echo =====================================================================
echo    Application successfully started!
echo =====================================================================
echo.
echo    Frontend:   http://localhost:5173
echo    Backend:    http://localhost:5000/api/health
echo.
echo    DEMO LOGIN ACCOUNTS:
echo    - Admin:    admin@apartment.com    / admin123
echo    - Security: security@apartment.com / security123
echo    - Resident: john@resident.com     / resident123
echo.
echo    To STOP the application:
echo    - Run 'stop.bat' or close the two server terminal windows.
echo =====================================================================
echo.
pause
exit /b 0

:: =====================================================================
:: Error Handlers
:: =====================================================================

:node_missing
echo.
echo [ERROR] Node.js was not found in your system PATH!
echo Please install Node.js v18 or higher from https://nodejs.org/
echo After installing, reopen this script.
echo.
pause
exit /b 1

:server_missing
echo.
echo [ERROR] Cannot find server\package.json!
echo Make sure start.bat is placed in the apartment-management project root.
echo Expected path: %~dp0server\package.json
echo.
pause
exit /b 1

:client_missing
echo.
echo [ERROR] Cannot find client\package.json!
echo Make sure start.bat is placed in the apartment-management project root.
echo Expected path: %~dp0client\package.json
echo.
pause
exit /b 1

:server_install_failed
echo.
echo [ERROR] Failed to install server dependencies.
echo Please check your internet connection or run 'npm install' inside the server directory.
echo.
cd /d "%~dp0"
pause
exit /b 1

:client_install_failed
echo.
echo [ERROR] Failed to install client dependencies.
echo Please check your internet connection or run 'npm install' inside the client directory.
echo.
cd /d "%~dp0"
pause
exit /b 1
