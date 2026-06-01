# =====================================================
# AutoVSF Installer - One-click install
# =====================================================

Write-Host "AutoVSF Installer" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

$RepoName = "autovsf"
$RepoUrl  = "https://github.com/lionc2240/autovsf.git"

# 1. Cài Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Dang cai Git..." -ForegroundColor Yellow
    winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements
}

# 2. Cài Python 3.12
if (-not (Get-Command python -ErrorAction SilentlyContinue) -or 
    (python --version 2>&1) -notmatch "3\.1[2-9]") {
    Write-Host "Dang cai Python 3.12..." -ForegroundColor Yellow
    winget install --id Python.Python.3.12 -e --source winget --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + 
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

# 3. Clone / Update repo (đã bao gồm VideoSubFinder)
Write-Host "Dang clone/cap nhat repository..." -ForegroundColor Yellow
if (Test-Path $RepoName) {
    Write-Host "Thu muc autovsf da ton tai → Dang cap nhat..." -ForegroundColor Yellow
    Set-Location $RepoName
    git pull
} else {
    git clone $RepoUrl
    Set-Location $RepoName
}

# 4. Kiểm tra VideoSubFinder (đã có trong repo)
$vsfExe = Join-Path $PWD "program\VideoSubFinder_6.10_x64\Release_x64\VideoSubFinderWXW_intel.exe"

if (Test-Path $vsfExe) {
    Write-Host "Da tim thay VideoSubFinderWXW_intel.exe" -ForegroundColor Green
} else {
    Write-Host "Canh bao: Khong tim thay VideoSubFinder trong repo!" -ForegroundColor Red
}

# 5. Cài Python packages
Write-Host "Dang cai thu vien Python..." -ForegroundColor Yellow
python -m pip install --upgrade pip
python -m pip install watchdog google-api-python-client oauth2client httplib2 opencv-python psutil Pillow

# 6. Hoàn tất
Write-Host "`nCai dat AutoVSF HOAN TAT!" -ForegroundColor Green
Write-Host "Thu muc hien tai: $(Get-Location)" -ForegroundColor Green
Write-Host "Duong dan VSF: $vsfExe" -ForegroundColor Cyan

Write-Host "`nDe chay chuong trinh:" -ForegroundColor White
Write-Host "   python main.py" -ForegroundColor Yellow