# Check if packages are provided as arguments and notify user to pass some if it isn't
if ($args.Count -eq 0) {
  Write-Host "Usage: ./install_software.ps1 <package1> <package2> ..." -ForegroundColor Yellow
  Write-Host "Please provide the list of packages to install or upgrade as arguments." -ForegroundColor Yellow
  return
}

# Define the list of packages from the provided arguments
$packages = $args

# Check if the script is running with administrative privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
  Write-Host "This script requires administrative privileges to run." -ForegroundColor Red
  Write-Host "Please run the script as an administrator and try again." -ForegroundColor Red
  return
}

# Function to install Chocolatey and restart the shell session so that chocoltey can be used to install applications
function Install-Chocolatey {
  Write-Host "================================================" -ForegroundColor Green
  Write-Host "Chocolatey is not installed." -ForegroundColor Green
  Write-Host "Installing Chocolatey..." -ForegroundColor Green
  Write-Host "================================================" -ForegroundColor Green
  Set-ExecutionPolicy Bypass -Scope Process -Force;
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  Write-Host "================================================" -ForegroundColor Green
  Write-Host "Chocolatey installation completed." -ForegroundColor Green
  Write-Host "Restarting shell..." -ForegroundColor Green
  Write-Host "================================================" -ForegroundColor Green

  # Restart the shell
  $newProcess = New-Object System.Diagnostics.ProcessStartInfo
  $newProcess.FileName = "powershell.exe"
  $newProcess.Arguments = "-NoExit -Command `"& {$($MyInvocation.ScriptName) $($args)}`""
  [System.Diagnostics.Process]::Start($newProcess) | Out-Null
  exit
}

# Check if Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
  Install-Chocolatey
  if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "Failed to install Chocolatey. Exiting script." -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    exit 1
  }
}

# Keep a list of the applications that were successfully installed or upgraded and those that failed, to update the user at the end of the script run

$installedPackages = @()
$failedPackages = @()

foreach ($package in $packages) {
  Write-Host "================================================" -ForegroundColor Green
  Write-Host "Installing package: $package" -ForegroundColor Green
  Write-Host "================================================" -ForegroundColor Green

  try {
    # Check if the package is already installed
    $installedPackage = choco list --local-only | Select-String $package

    if ($installedPackage) {
      # If installed, upgrade the package
      Write-Host "Upgrading $package..."
      choco upgrade $package -y
      $installedPackages += $package
    }
    else {
      # If not installed, install the package
      Write-Host "Installing $package..."
      choco install $package -y
      $installedPackages += $package
    }
}
catch {
  $failedPackages += @{
      Package = $package
      Reason  = $_.Exception.Message
  }
}

  Write-Host "================================================" -ForegroundColor Green
  Write-Host "$package sucessfully installed." -ForegroundColor Green
  Write-Host "================================================" -ForegroundColor Green
}

# List the successfully installed or upgraded Application
Write-Host "================================================" -ForegroundColor Green
Write-Host "Applications installed or upgraded:" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
$installedPackages | ForEach-Object { Write-Host $_ -ForegroundColor Green }

# List the Applications that failed to install or upgrade
if ($failedPackages.Count -gt 0) {
  Write-Host "================================================" -ForegroundColor Red
  Write-Host "Applications that failed to install or upgrade:" -ForegroundColor Red
  Write-Host "================================================" -ForegroundColor Red
  $failedPackages | ForEach-Object {
      Write-Host "Package: $($_.Package)" -ForegroundColor Red
      Write-Host "Reason: $($_.Reason)" -ForegroundColor Red
      Write-Host ""
  }
}