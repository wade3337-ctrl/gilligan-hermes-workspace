# ============================================================================
#  GILLIGAN RECOVERY - one-script bring-back (WINDOWS)
#  Don't run this directly. Double-click  START-GILLIGAN.bat  instead.
# ============================================================================
$ErrorActionPreference = 'Stop'
function Say($m){ Write-Host "`n==> $m" -ForegroundColor Cyan }
function Die($m){ Write-Host "`nSTOP: $m" -ForegroundColor Red; Read-Host 'Press Enter to close'; exit 1 }

$KIT    = Split-Path -Parent $MyInvocation.MyCommand.Path
$BUNDLE = Join-Path $KIT 'gilligan-credentials.tar.gz.gpg'
$HOMEDIR = $env:USERPROFILE

Say "Gilligan recovery starting (Windows). This takes a few minutes."

# --- 1. prerequisites via winget -------------------------------------------
function Need($cmd,$wingetId,$label){
  if (Get-Command $cmd -ErrorAction SilentlyContinue){ return }
  if (Get-Command winget -ErrorAction SilentlyContinue){
    Say "Installing $label ..."
    winget install --silent --accept-source-agreements --accept-package-agreements -e --id $wingetId | Out-Null
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path','User')
  }
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)){
    Die "$label is required but couldn't be installed automatically. Install it manually, then re-run."
  }
}
Need 'node' 'OpenJS.NodeJS.LTS' 'Node.js'
Need 'git'  'Git.Git'          'Git'
Need 'gpg'  'GnuPG.GnuPG'      'GnuPG'
if (-not (Get-Command tar -ErrorAction SilentlyContinue)){ Die "tar.exe missing (needs Windows 10 1803+)." }

Say "Installing OpenClaw (needs internet)..."
cmd /c "npm install -g openclaw" | Out-Null
if ($LASTEXITCODE -ne 0){ Die "OpenClaw install failed. Check internet, then re-run." }

# --- 2. unlock the credential bundle ---------------------------------------
if (-not (Test-Path $BUNDLE)){ Die "Credential bundle missing from the USB." }
$pf = Join-Path $KIT 'passphrase.txt'
$tmp = Join-Path $env:TEMP ("gilligan-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
$passFile = Join-Path $tmp 'pp.txt'
if (Test-Path $pf){
  Say "Using passphrase from the USB (plug-and-go mode)."
  (Get-Content $pf -Raw).Trim() | Set-Content -NoNewline $passFile
} else {
  $sec = Read-Host -AsSecureString 'Enter the Gilligan recovery passphrase (from your password manager)'
  [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)) | Set-Content -NoNewline $passFile
}
$tgz = Join-Path $tmp 'bundle.tgz'
& gpg --batch --yes --passphrase-file $passFile -o $tgz -d $BUNDLE 2>$null
if ($LASTEXITCODE -ne 0){ Remove-Item $tmp -Recurse -Force; Die "Wrong passphrase or corrupt bundle. Re-run and re-check the passphrase." }
Remove-Item $passFile -Force
tar -xzf $tgz -C $tmp
Say "Credential bundle unlocked."

# --- 3. clone the 3 repos with the bundled GitHub token --------------------
$PAT = (Get-Content (Join-Path $tmp 'files\backups\.gh-token') -Raw).Trim()
if (-not $PAT){ Die "GitHub token not found in bundle." }
function Clone($name,$dest){
  if (Test-Path (Join-Path $dest '.git')){ Say "$name already present, skipping."; return }
  Say "Cloning $name ..."
  git clone --quiet "https://$PAT@github.com/wade3337-ctrl/$name.git" $dest
  if ($LASTEXITCODE -ne 0){ Die "Could not clone $name (check internet / token)." }
}
Clone 'gilligan-workspace'  (Join-Path $HOMEDIR '.openclaw\workspace')
Clone 'gilligan-arborstack' (Join-Path $HOMEDIR 'arbor-stack')
Clone 'arbor-core'          (Join-Path $HOMEDIR 'arbor-core')

# --- 4. restore credentials into %USERPROFILE% -----------------------------
Say "Restoring credentials..."
Copy-Item -Path (Join-Path $tmp 'files\*') -Destination $HOMEDIR -Recurse -Force
Remove-Item $tmp -Recurse -Force

# --- 5. light up -----------------------------------------------------------
Say "Starting Gilligan's gateway..."
cmd /c "openclaw gateway start"
Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "  DONE. Watch Discord - Gilligan should reconnect shortly." -ForegroundColor Green
Write-Host "  Say hi. If he answers and knows you, you're back." -ForegroundColor Green
Write-Host "============================================================`n" -ForegroundColor Green
Write-Host "NOTE (Windows): the scheduled email monitors (COO daily, etc.) use"
Write-Host "Linux cron and will NOT auto-run here. Gilligan is back and fully"
Write-Host "conversational; for the automated emails, rebuild on a Linux box when"
Write-Host "you can, or ask Gilligan to set up Windows Task Scheduler jobs."
Read-Host "`nPress Enter to close"
