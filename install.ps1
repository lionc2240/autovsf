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
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + 
                [System.Environment]::GetEnvironmentVariable("Path","User")
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
$currentDirName = Split-Path $PWD -Leaf

if ($currentDirName -eq $RepoName -and (Test-Path ".git")) {
    Write-Host "Ban dang dung san trong thu muc autovsf -> Dang cap nhat..." -ForegroundColor Yellow
    git pull
} elseif (Test-Path $RepoName) {
    Write-Host "Thu muc autovsf da ton tai → Dang cap nhat..." -ForegroundColor Yellow
    Set-Location $RepoName
    git pull
} else {
    git clone $RepoUrl
    Set-Location $RepoName
}

# 4. Kiểm tra VideoSubFinder (đã có sẵn trong repo tại thư mục program)
$vsfExe = Join-Path $PWD "program\VideoSubFinder_6.10_x64\Release_x64\VideoSubFinderWXW_intel.exe"

Write-Host "`n────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "[..] Dang kiem tra VideoSubFinder..." -ForegroundColor Cyan

if (Test-Path $vsfExe) {
    Write-Host "[OK] VideoSubFinderWXW_intel.exe da co san!" -ForegroundColor Green
} else {
    Write-Host "[❌] Canh bao: Khong tim thay VideoSubFinder tai: $vsfExe" -ForegroundColor Red
    Write-Host "Vui long kiem tra lai thu muc program trong repo!" -ForegroundColor Yellow
}
Write-Host "────────────────────────────────────────" -ForegroundColor DarkGray

# 5. Cài Python packages
Write-Host "`n[..] Dang cai thu vien Python..." -ForegroundColor Yellow
python -m pip install --upgrade pip --quiet
python -m pip install watchdog google-api-python-client oauth2client httplib2 opencv-python psutil Pillow --quiet
Write-Host "[OK] Da cai dat day du thu vien Python." -ForegroundColor Green

# 6. Hoàn tất & Tương tác Menu
Write-Host "`n=======================================" -ForegroundColor Cyan
Write-Host "   Cai dat AutoVSF HOAN TAT!" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Thu muc: $(Get-Location)" -ForegroundColor Gray
Write-Host "VSF Path: $vsfExe" -ForegroundColor Gray
Write-Host "───────────────────────────────────────" -ForegroundColor DarkGray

while ($true) {
    Write-Host "`n[1] Launch AutoVSF (Chay ngay)" -ForegroundColor Green
    Write-Host "[2] Configure Google Cloud (Cai dat Google Drive OCR)" -ForegroundColor Yellow
    Write-Host "[0] Cancel / Discard (Thoat)" -ForegroundColor LightRed
    Write-Host "───────────────────────────────────────" -ForegroundColor DarkGray
    
    $choice = Read-Host "Nhap lua chon cua ban [1/2/0]"
    
    switch ($choice) {
        "1" {
            Write-Host "`n[..] Dang khoi chay AutoVSF..." -ForegroundColor Green
            python main.py
            break
        }
        "2" {
            Write-Host "`n[..] Dang mo link huong dan GOOGLE_SETUP.md..." -ForegroundColor Yellow
            Start-Process "https://github.com/lionc2240/autovsf/blob/main/docs/GOOGLE_SETUP.md"
            
            Write-Host "[..] Dang mo Google Cloud Console..." -ForegroundColor Yellow
            Start-Process "https://console.cloud.google.com/"
            
            Write-Host "`n[!] HUONG DAN:" -ForegroundColor Cyan
            Write-Host "  1. Doc ky tai lieu tren Github de lam theo 4 buoc." -ForegroundColor White
            Write-Host "  2. Sau khi co file 'credentials.json', hay bo vao thu muc: $(Get-Location)" -ForegroundColor White
            Write-Host "  3. Ban co the bat dau chay AutoVSF ngay sau khi dat file." -ForegroundColor White
            continue
        }
        "0" {
            Write-Host "`n[OK] Tam biet! Ban co the chay lai bang lenh: python main.py" -ForegroundColor Cyan
            break
        }
        default {
            Write-Host "Lua chon khong hop le! Vui long nhap 1, 2 hoac 0." -ForegroundColor Red
        }
    }
}