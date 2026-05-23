# HappyFamily Backend Deploy Script
# Usage: .\deploy.ps1

$SERVER = "root@39.106.208.29"
$APP_DIR = "/opt/happyfamily/backend"
$PM2_NAME = "happyfamily"

Write-Host "==> Deploying to $SERVER..." -ForegroundColor Cyan

ssh $SERVER @"
set -e

echo '--- [1/4] Pulling latest code ---'
cd /opt/happyfamily
git pull

echo '--- [2/4] Installing dependencies ---'
cd backend
npm install --production

echo '--- [3/4] Checking PM2 ---'
if ! command -v pm2 &> /dev/null; then
  echo 'PM2 not found, installing...'
  npm install -g pm2
fi

echo '--- [4/4] Restarting service ---'
if pm2 describe $PM2_NAME > /dev/null 2>&1; then
  pm2 restart $PM2_NAME
else
  echo 'First deploy: starting with PM2...'
  pm2 start src/app.js --name $PM2_NAME
  pm2 save
  pm2 startup
fi

echo ''
echo '=== Deploy complete! ==='
pm2 status $PM2_NAME
"@

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[OK] Deploy succeeded!" -ForegroundColor Green
} else {
    Write-Host "`n[FAILED] Deploy failed, check output above." -ForegroundColor Red
}
