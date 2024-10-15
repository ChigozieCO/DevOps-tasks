# Check if the script is running with administrative privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
  Write-Host "This script requires administrative privileges to run." -ForegroundColor Red
  Write-Host "Please run the script as an administrator and try again." -ForegroundColor Red
  return
}

# Check if the GitHubRepoUrl environment variable is defined
if ($env:GitHubRepoUrl) {
  $githubRepoUrl = $env:GitHubRepoUrl
} else {
  # Prompt the user for the GitHub repository URL
  $githubRepoUrl = Read-Host "Please enter the GitHub repository URL for your web application"
}

# Define the software to check and install
$softwareList = @(
  @{
    Name = "Git"
    CheckCommand = { Get-Command git -ErrorAction SilentlyContinue }
    InstallCommand = {
      # Fetch the latest release version from GitHub API
      $gitReleaseApi = "https://api.github.com/repos/git-for-windows/git/releases/latest"
      $gitReleaseInfo = Invoke-RestMethod -Uri $gitReleaseApi
      
      # Get the installer URL for the 64-bit version
      $gitInstallerUrl = $gitReleaseInfo.assets | Where-Object { $_.name -like "*64-bit.exe" } | Select-Object -ExpandProperty browser_download_url
      
      # Define the installer path
      $gitInstallerPath = "$env:TEMP\GitInstaller.exe"
      
      # Download the installer
      Invoke-WebRequest -Uri $gitInstallerUrl -OutFile $gitInstallerPath
      
      # Start the installation process
      Start-Process -FilePath $gitInstallerPath -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
      
      # Optionally, update the system PATH
      $gitInstallDir = "C:\Program Files\Git\cmd"
      [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$gitInstallDir", "Machine")
    }
  },
  @{
    Name = "IIS"
    CheckCommand = {
      $feature = Get-WindowsFeature -Name Web-Server
      $feature -and $feature.InstallState -eq 'Installed'
    }
    InstallCommand = {
      try {
        # Store the result of the installation command
        $installResult = Install-WindowsFeature -Name Web-Server -IncludeManagementTools -ErrorAction Stop

        # Check the installation state
        if ($installResult.Success) {
          if ($installResult.RestartNeeded) {
            Write-Host "IIS installation completed successfully, but a system restart is required." -ForegroundColor Yellow
          } else {
            Write-Host "IIS installation completed successfully." -ForegroundColor Green
          }
        } else {
          $failureDetails = ($installResult.FeatureResult | Where-Object { -not $_.Success }).Message
          Write-Host "IIS installation failed: $failureDetails" -ForegroundColor Red
        }
      } catch {
        Write-Host "IIS installation failed: $($_.Exception.Message)" -ForegroundColor Red
      }
    }
  }
)

# Loop through each software item
foreach ($software in $softwareList) {
  $isInstalled = & $software.CheckCommand

  if ($isInstalled) {
    Write-Host "$($software.Name) is already installed."
  } else {
    Write-Host "$($software.Name) is not installed. Installing $($software.Name)..."
    & $software.InstallCommand
    
    # Wait for a moment to allow the system to update the environment
    Start-Sleep -Seconds 5 
    
    # Check again if the installation was successful
    $isInstalled = & $software.CheckCommand
    if ($isInstalled) {
      Write-Host "$($software.Name) installation successful."
    } else {
      # Explicitly check for the Git executable
      if (Test-Path "$env:ProgramFiles\Git\bin\git.exe") {
        Write-Host "Git installation successful (verified by path check)."
      } else {
        Write-Host "$($software.Name) installation failed."
      }
    }
  }
}

# Check if IIS was installed successfully 
$isIISInstalled = & $softwareList[1].CheckCommand

# If IIS was installed successfully, navigate to the default website directory
if ($isIISInstalled) {
  try {
    # Get the default website directory
    $iisWebsiteDir = (Get-Website -Name 'Default Web Site').PhysicalPath
    $resolvedWebsiteDir = $iisWebsiteDir -replace '%SystemDrive%', 'C:'

    # Remove any existing files in the website directory
    if (Test-Path -Path $resolvedWebsiteDir) {
      Write-Host "Removing existing files from the IIS default website directory: $resolvedWebsiteDir"
      Remove-Item -Path "$resolvedWebsiteDir\*" -Recurse -Force
    } else {
      Write-Host "The default website directory $resolvedWebsiteDir does not exist. Creating it now."
      New-Item -Path $resolvedWebsiteDir -ItemType Directory -Force
    }

    # Navigate to the website directory (Push-Location saves the current directory before switching)
    Push-Location -Path $resolvedWebsiteDir

    # Clone the GitHub repository directly into the website directory
    git clone $githubRepoUrl ./ 2>&1 | Out-Null

    Write-Host "Web application files have been cloned to the IIS default website directory: $resolvedWebsiteDir"

  } catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
  }
} else {
  Write-Host "IIS installation failed, so the web application files were not cloned."
}

# Navigate back to the previous directory (Pop-Location restores the previous directory.)
Pop-Location

# Only add firewall rules if IIS is installed
if ($isIISInstalled) {
  # Allow HTTP traffic (port 80)
  netsh advfirewall firewall add rule name="IIS Allow HTTP (HTTP-In)" dir=in action=allow protocol=TCP localport=80
  # Allow HTTPS traffic (port 443)
  netsh advfirewall firewall add rule name="IIS Allow HTTPS (HTTPS-In)" dir=in action=allow protocol=TCP localport=443
  Write-Host "Firewall rules for IIS have been configured."
} else {
  Write-Host "IIS installation failed, so firewall rules were not configured."
}