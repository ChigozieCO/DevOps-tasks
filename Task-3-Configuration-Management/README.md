# Task

Use Chocolatey to create a script that installs a list of software packages, checking for existing installations and updating as necessary.

# Implementation Overview

This script automates software installation, it makes it easy to install or update software packages on a Windows machine using Chocolatey. Here's how it works:

1. **Check for Chocolatey installation**: If Chocolatey isn’t already installed, the script will take care of installing it for you.

2. **Check for Administrative Privileges**: Since installing software requires administrative permissions, the script will check if you’re running it with admin rights. If not, it will prompt you to rerun the script with the necessary permissions.

3. **Install or Upgrade Software Packages**: For each package in the list you provide:

    - The script checks if the package is already installed.

    - If it's installed, it upgrades the package to the latest version.

    - If it’s not installed, it installs it from scratch.

## Key Features

- **Automatic Chocolatey Setup**: If you don’t have Chocolatey installed, the script installs it automatically so you don’t have to thereby ensuring Chocolatey is available for package management.

- **Admin Check**: It makes sure you’re running the script with the right permissions.

- **Smart Package Management**: The script checks each package’s status and either installs or upgrades it as needed.

## Prerequisites

- A Windows machine with PowerShell.

- Admin rights to install or update software.

- Internet access to download Chocolatey and the packages you want to install.

## How to Use the Script

1. Open PowerShell as an Administrator.

2. Run the script and pass the names of the software packages you want to install or upgrade. For example:

```powershell
./install_software.ps1 git nodejs python
```

## Error Handling

1. If the script can’t install Chocolatey for some reason, it will stop and let you know.

2. If any package fails to install or update, the script will display an error message but continue to process the remaining packages.