@echo off
echo ======================================
echo   PharmaX MongoDB Backend Startup
echo ======================================
echo.

cd /d "%~dp0"

echo 🔍 Checking Node.js installation...
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js not found! Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo ✅ Node.js found: 
node --version

echo.
echo 🔍 Checking MongoDB installation...
mongo --version >nul 2>&1
if errorlevel 1 (
    mongod --version >nul 2>&1
    if errorlevel 1 (
        echo ❌ MongoDB not found!
        echo.
        echo 📥 To install MongoDB:
        echo 1. Download MongoDB Community Server from: https://www.mongodb.com/try/download/community
        echo 2. Install it with default settings
        echo 3. Start MongoDB service or run: mongod --dbpath C:\data\db
        echo.
        pause
        exit /b 1
    )
)

echo ✅ MongoDB found

echo.
echo 📦 Installing backend dependencies...
call npm install
if errorlevel 1 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo 🚀 Starting PharmaX Backend Server...
echo 📋 API will be available at: http://localhost:3000/api
echo 🔍 Health Check: http://localhost:3000/health
echo 🛑 Press Ctrl+C to stop the server
echo.

node server.js