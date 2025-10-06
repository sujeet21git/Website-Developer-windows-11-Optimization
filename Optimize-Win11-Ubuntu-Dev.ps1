<# 
   Windows 11 Optimization + WSL2 (Ubuntu) + Docker Performance Script
   Author: Sujeet (with GPT-5 assistance)
   Safe system optimization for web developers
#>

Write-Host "=== Starting Windows 11 Developer Optimization with WSL2 + Ubuntu ===" -ForegroundColor Cyan

# --- STEP 1: Check for Administrator Privileges ---
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "⚠️  Please run PowerShell as Administrator!"
    Exit
}

# --- STEP 2: Enable Developer Mode ---
Write-Host "Enabling Developer Mode..."
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /v "AllowDevelopmentWithoutDevLicense" /d 1 /f

# --- STEP 3: Enable WSL and Virtual Machine Platform ---
Write-Host "Enabling WSL and Virtual Machine Platform..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# --- STEP 4: Set WSL2 as Default ---
Write-Host "Setting WSL 2 as default version..."
wsl --set-default-version 2

# --- STEP 5: Install Lightweight Ubuntu ---
Write-Host "Installing Ubuntu (lightweight)..."
wsl --install -d Ubuntu

Write-Host "⚙️  Please complete Ubuntu setup (username & password) when prompted after reboot."

# --- STEP 6: Create WSL Performance Configuration ---
Write-Host "Configuring WSL performance..."
$wslConfigPath = "$env:USERPROFILE\.wslconfig"
@"
[wsl2]
memory=4GB
processors=4
swap=0
localhostForwarding=true
"@ | Out-File -Encoding ASCII -FilePath $wslConfigPath -Force
Write-Host "✅ WSL configuration saved at $wslConfigPath"

# --- STEP 7: Set Power Plan to High Performance ---
Write-Host "Setting power plan to High Performance..."
powercfg -setactive SCHEME_MIN

# --- STEP 8: Disable Unnecessary Startup Apps ---
Write-Host "Disabling unnecessary startup apps..."
Get-CimInstance Win32_StartupCommand | ForEach-Object {
    if ($_.'Command' -notmatch 'code|phpstorm|docker|node|git|chrome|edge|wsl|ubuntu') {
        Write-Host "🧹 Disabling: $($_.Name)"
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $_.Name -ErrorAction SilentlyContinue
    }
}

# --- STEP 9: Disable Background Apps ---
Write-Host "Disabling background apps..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f

# --- STEP 10: Visual Effects (Best Performance) ---
Write-Host "Setting Windows visual effects for best performance..."
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
New-ItemProperty -Path $regPath -Name VisualFXSetting -Value 2 -PropertyType DWord -Force | Out-Null

# --- STEP 11: Optimize Unneeded Services ---
Write-Host "Optimizing background services..."
$services = @("DiagTrack", "SysMain", "MapsBroker", "WSearch")
foreach ($svc in $services) {
    Write-Host "Stopping and disabling service: $svc"
    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name $svc -ErrorAction SilentlyContinue
}

# --- STEP 12: Install Docker Desktop for WSL2 Backend ---
Write-Host "Downloading Docker Desktop installer..."
$dockerInstaller = "$env:TEMP\DockerInstaller.exe"
Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile $dockerInstaller -UseBasicParsing

Write-Host "Installing Docker Desktop silently..."
Start-Process $dockerInstaller -ArgumentList "install", "--quiet" -Wait

# --- STEP 13: Optimize Docker Configuration ---
$dockerSettingsPath = "$env:APPDATA\Docker\settings.json"
if (Test-Path $dockerSettingsPath) {
    Write-Host "Tuning Docker resource settings..."
    $dockerSettings = Get-Content $dockerSettingsPath | Out-String | ConvertFrom-Json
    $dockerSettings.wslEngine = $true
    $dockerSettings.autoStart = $false
    $dockerSettings.resources.memoryMiB = 4096
    $dockerSettings.resources.cpus = 4
    $dockerSettings.resources.swapMiB = 0
    $dockerSettings | ConvertTo-Json -Depth 10 | Set-Content -Path $dockerSettingsPath -Encoding UTF8
}

# --- STEP 14: Clean Temporary Files ---
Write-Host "Cleaning temporary files..."
$paths = @("$env:TEMP\*", "$env:WinDir\Temp\*")
foreach ($path in $paths) { Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue }
Write-Host "🧹 Temporary files cleaned."

# --- STEP 15: Network Optimization ---
Write-Host "Optimizing network stack..."
netsh interface tcp set global autotuninglevel=normal
ipconfig /flushdns

# --- STEP 16: Completion ---
Write-Host "`n✅ Optimization complete!"
Write-Host "Please RESTART your computer to finish installation and launch Ubuntu setup." -ForegroundColor Green
