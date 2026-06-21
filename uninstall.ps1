# =====================================================
# AutoVSF Uninstaller
# =====================================================

Write-Host "AutoVSF Uninstaller" -ForegroundColor Yellow
Write-Host "=======================================" -ForegroundColor Yellow

$desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "AutoVSF.lnk")
$startMenuPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('StartMenu'), "Programs", "AutoVSF.lnk")

# 1. Remove Desktop Shortcut
if (Test-Path $desktopPath) {
    Remove-Item $desktopPath -Force
    Write-Host "[OK] Da xoa shortcut Desktop." -ForegroundColor White
} else {
    Write-Host "[.] Khong thay shortcut Desktop." -ForegroundColor Gray
}

# 2. Remove Start Menu Shortcut
if (Test-Path $startMenuPath) {
    Remove-Item $startMenuPath -Force
    Write-Host "[OK] Da xoa shortcut Start Menu." -ForegroundColor White
} else {
    Write-Host "[.] Khong thay shortcut Start Menu." -ForegroundColor Gray
}

# 3. Remove autovsf function from PowerShell Profile
try {
    if (Test-Path $PROFILE) {
        $lines = Get-Content $PROFILE -Raw
        if ($lines -match "function autovsf") {
            # Đọc theo dòng để lọc bỏ dòng chứa function autovsf
            $linesArray = Get-Content $PROFILE
            $newLines = @()
            foreach ($line in $linesArray) {
                if ($line -notmatch "function autovsf") {
                    $newLines += $line
                }
            }
            $newLines | Set-Content $PROFILE
            Write-Host "[OK] Da go lenh nhanh 'autovsf' khoi PowerShell Profile." -ForegroundColor White
        } else {
            Write-Host "[.] Khong tim thay lenh nhanh 'autovsf' trong PowerShell Profile." -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "[⚠️] Khong the cap nhat PowerShell Profile: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n=======================================" -ForegroundColor Yellow
Write-Host "Go cai dat Shortcut va Cau hinh hoan tat!" -ForegroundColor White
Write-Host "De xoa hoan toan code va moi truong ao (venv), ban co the xoa thu muc du an tai:" -ForegroundColor Yellow
Write-Host "  $PWD" -ForegroundColor White
Write-Host "=======================================" -ForegroundColor Yellow
