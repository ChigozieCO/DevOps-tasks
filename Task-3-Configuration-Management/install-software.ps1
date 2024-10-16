# Check if packages are provided as arguments and notify the user to pass some if they aren't
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

# Function to install Chocolatey and restart the shell session so that Chocolatey can be used to install applications
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
  Write-Host "Reloading shell......" -ForegroundColor Green
  Write-Host "================================================" -ForegroundColor Green

  # Reload the current shell session
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
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

# Loop through each package provided as arguments
foreach ($package in $packages) {
  Write-Host "================================================" -ForegroundColor Green
  Write-Host "Processing package: $package" -ForegroundColor Green
  Write-Host "================================================" -ForegroundColor Green

  # Check if the package is already installed
  $installedPackage = choco list --local-only | Select-String $package

  if ($installedPackage) {
    # If installed, upgrade the package
    Write-Host "Upgrading $package..."
    choco upgrade $package -y
  } else {
    # If not installed, install the package
    Write-Host "Installing $package..."
    choco install $package -y
  }

  # Confirmation message for successful or failed installation or upgrade
  if ($LASTEXITCODE -eq 0) {
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "$package was successfully installed or upgraded." -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
  } else {
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "Failed to install or upgrade $package." -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
  }
}