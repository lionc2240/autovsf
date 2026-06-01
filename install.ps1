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

# 4. Kiểm tra và tải VideoSubFinder (nếu thiếu)
$vsfDir = Join-Path $PWD "program"
$vsfZipUrl = "https://github.com/lionc2240/autovsf/releases/download/VideoSubFinder_6.10_x64/VideoSubFinder_6.10_x64.zip"
$vsfZipFile = Join-Path $vsfDir "VideoSubFinder_6.10_x64.zip"
$vsfExe = Join-Path $vsfDir "VideoSubFinder_6.10_x64\Release_x64\VideoSubFinderWXW_intel.exe"

# Đảm bảo có thư mục program
if (-not (Test-Path $vsfDir)) {
    New-Item -ItemType Directory -Force -Path $vsfDir | Out-Null
}

Write-Host "`n────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "[..] Dang kiem tra VideoSubFinder..." -ForegroundColor Cyan
$osArch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
Write-Host "  [OK] Environment: Windows ($osArch)" -ForegroundColor Green

if (Test-Path $vsfExe) {
    Write-Host "[OK] VideoSubFinderWXW_intel.exe da co san!" -ForegroundColor Green
} else {
    Write-Host "[..] Thieu VideoSubFinder -> Dang tai tu Github Release..." -ForegroundColor Yellow
    
    # Hàm vẽ progress bar
    function Draw-ProgressBar ($bytesWritten, $totalBytes) {
        $percent = [Math]::Min(100, [Math]::Max(0, [int](($bytesWritten / $totalBytes) * 100)))
        $barWidth = 22
        $filledWidth = [int]($percent * $barWidth / 100)
        $unfilledWidth = $barWidth - $filledWidth
        
        $bar = ("█" * $filledWidth) + ("░" * $unfilledWidth)
        $writtenMB = ($bytesWritten / 1MB).ToString("F1")
        $totalMB = ($totalBytes / 1MB).ToString("F1")
        
        $status = "  [..] [$bar] $("{0,3}"-f $percent)% $writtenMB`M / $totalMB`M"
        [Console]::Write("`r" + $status.PadRight([Console]::WindowWidth - 1))
    }

    try {
        # Bật bảo mật TLS để tải an toàn từ Github
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Lấy dung lượng thật từ server trước
        $req = [System.Net.WebRequest]::Create($vsfZipUrl)
        $req.UserAgent = "Mozilla/5.0"
        $req.Method = "HEAD"
        $resp = $req.GetResponse()
        $totalBytes = [int64]$resp.ContentLength
        $resp.Close()
        if ($totalBytes -le 0) { $totalBytes = 49053912 }
        $totalMB = ($totalBytes / 1MB).ToString("F1")
        Write-Host "  [..] File: $totalMB MB - Dang tai..." -ForegroundColor Yellow
        
        # Tải file với progress bar
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0")
        
        $onProgress = {
            param($sender, $e)
            Draw-ProgressBar $e.BytesReceived $e.TotalBytesToReceive
        }
        $webClient.add_DownloadProgressChanged($onProgress)
        
        $asyncTask = $webClient.DownloadFileTaskAsync($vsfZipUrl, $vsfZipFile)
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        while (-not $asyncTask.IsCompleted) {
            if ($sw.Elapsed.TotalMinutes -ge 10) { throw "Qua thoi gian cho (10 phut)" }
            Start-Sleep -Milliseconds 200
        }
        if ($asyncTask.IsFaulted) { throw $asyncTask.Exception.InnerException }
        
        # Hoàn tất thanh tiến trình
        $bar = "█" * 22
        [Console]::Write("`r  [OK] [$bar] 100% $totalMB`M / $totalMB`M`n")
        
        # Giải nén tự động vào program\VideoSubFinder_6.10_x64
        Write-Host "[..] Dang giai nen VideoSubFinder..." -ForegroundColor Yellow
        $extractDir = Join-Path $vsfDir "VideoSubFinder_6.10_x64"
        if (-not (Test-Path $extractDir)) {
            New-Item -ItemType Directory -Force -Path $extractDir | Out-Null
        }
        Expand-Archive -Path $vsfZipFile -DestinationPath $extractDir -Force
        Remove-Item -Path $vsfZipFile -Force
        
        if (Test-Path $vsfExe) {
            Write-Host "[OK] Giai nen thanh cong! Da kich hoat VideoSubFinder." -ForegroundColor Green
        } else {
            Write-Host "[❌] Canh bao: File chay van thieu sau khi giai nen!" -ForegroundColor Red
        }
    } catch {
        Write-Host "`r[❌] Tai VideoSubFinder that bai!" -ForegroundColor Red
        Write-Host "Loi: $($_.Exception.Message)" -ForegroundColor DarkGray
    }
}
Write-Host "────────────────────────────────────────" -ForegroundColor DarkGray

# 5. Cài Python packages
Write-Host "`n[..] Dang cai thu vien Python..." -ForegroundColor Yellow
python -m pip install --upgrade pip --quiet
python -m pip install watchdog google-api-python-client oauth2client httplib2 opencv-python psutil Pillow --quiet
Write-Host "[OK] Da cai dat day du thu vien Python." -ForegroundColor Green

# 6. Hoàn tất & Tương tác Menu
Write-Host "`n=======================================" -ForegroundColor Cyan
Write-Host "   Cai dat AutoVSF HOANTAT!" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Thu muc: $(Get-Location)" -ForegroundColor Gray
Write-Host "VSF Path: $vsfExe" -ForegroundColor Gray
Write-Host "───────────────────────────────────────" -ForegroundColor DarkGray

$shouldExit = $false
while (-not $shouldExit) {
    Write-Host "`n[1] Launch AutoVSF (Chay ngay)" -ForegroundColor Green
    Write-Host "[2] Configure Google Cloud (Cai dat Google Drive OCR)" -ForegroundColor Yellow
    Write-Host "[0] Cancel / Discard (Thoat)" -ForegroundColor Red
    Write-Host "───────────────────────────────────────" -ForegroundColor DarkGray
    
    $choice = Read-Host "Nhap lua chon cua ban [1/2/0]"
    
    switch ($choice) {
        "1" {
            Write-Host "`n[..] Dang khoi chay AutoVSF..." -ForegroundColor Green
            python main.py
            $shouldExit = $true
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
            Write-Host "  3. Ban co the quay lai day va chon [1] de chay AutoVSF ngay." -ForegroundColor White
            # Vòng lặp sẽ tiếp tục để người dùng có thể chọn [1] sau khi hoàn tất setup
            continue
        }
        "0" {
            Write-Host "`n[OK] Tam biet! Ban co the chay lai bang lenh: python main.py" -ForegroundColor Cyan
            $shouldExit = $true
            break
        }
        default {
            Write-Host "Lua chon khong hop le! Vui long nhap 1, 2 hoac 0." -ForegroundColor Red
        }
    }
}