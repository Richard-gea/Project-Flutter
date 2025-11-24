# PharmaX Backend Setup Guide

## Prerequisites

1. **Node.js** - Download from [https://nodejs.org/](https://nodejs.org/)
2. **MongoDB** - Download from [https://www.mongodb.com/try/download/community](https://www.mongodb.com/try/download/community)

## MongoDB Setup Options

### Option 1: MongoDB Service (Recommended)
If you installed MongoDB with default settings, it should run as a Windows service automatically.

### Option 2: Manual MongoDB Start
If MongoDB isn't running as a service:
```bash
# Create data directory (run once)
md C:\data\db

# Start MongoDB manually
mongod --dbpath C:\data\db
```

## Quick Start

1. **Double-click** `start-backend.bat` in the `backend` folder
2. The script will:
   - Check Node.js and MongoDB installation
   - Install dependencies automatically
   - Start the backend server on port 3000

## Manual Start (Alternative)

```bash
cd backend
npm install
node server.js
```

## Health Check

Once the server is running, test it:
- Backend API: http://localhost:3000/health
- Should return: `{"status": "OK", "database": "Connected"}`

## Flutter App

After backend is running:
1. Open new terminal in `pharmax` folder
2. Run: `flutter run`
3. Test "Add Patient" functionality

## Troubleshooting

### MongoDB Connection Issues
- Ensure MongoDB service is running
- Check Windows Services for "MongoDB" service
- Try restarting MongoDB service

### Port 3000 Already in Use
- Stop any other applications using port 3000
- Or modify port in `server.js` (line: `const PORT = process.env.PORT || 3000;`)

### Dependencies Issues
- Delete `node_modules` folder and `package-lock.json`
- Run `npm install` again