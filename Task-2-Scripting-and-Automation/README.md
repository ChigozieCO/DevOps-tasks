# Task

Create a PowerShell script that automates the deployment of a sample web application, including pulling the latest code from GitHub and deploying it to IIS.

# Implementation

For this task I will be using a simple web page I designed, you can find the [application here](https://github.com/ChigozieCO/assignment-02-for-individuals), the powershell script will pull the code from [it's own repo on github](https://github.com/ChigozieCO/DevOps-tasks) and deploy it on the windows server we installed in [Task 1](../Task-1-Environment-Setup/ansible/winplay.yml).

## Powershell Script Key Features

1. **Runs with Admin Rights**: I tried to cover all bases with the logic for this script, the script will first check to see if the user is running with administrative privileges as the installation of software and configuration of firewall rules requires this. This will happen before attempting anything that requires elevated permissions.

- If the user running the script is not running with administrative privileges (-not $isAdmin), the script displays a message asking the user to run the script as an administrator and then returns, effectively halting the script's execution.

2. **Sets Up the Web App Repo**: Immediately after that, the script checks if there is an environment variable that is holding the value of the web application github repo. If there isn't, it asks the user to input the URL and saves it to a variable that the script will use. This is the application that will be deployed.

- This step is implemented early in the script's execution so that the script has all it needs to run early enough and continue the execution uninterrupted.

3. **Installs Git & IIS**: As Git and IIS are essential for this deployment, the script will then check if Git and IIS are installed on the system, and if not, installs them. No need to worry about missing tools.

- I used a $softwareList variable to define the software to be checked and installed, along with the corresponding commands to check if it's installed and to perform the installation.

- The script loops through each software item in the list:
It first checks if the software is already installed using the CheckCommand script block.

- If the software is not installed, it runs the InstallCommand script block to install the software. After the installation, it checks again to verify if the installation was successful.

4. **Configures Firewall Rules**: After ensuring IIS is installed, the script will automatically configure firewall rules to allow HTTP and HTTPS traffic for IIS after a successful installation.

- After installing IIS (Internet Information Services) on a Windows machine, you typically need to configure the Windows Firewall to allow HTTP (port 80) and HTTPS (port 443) traffic. Therefore the script checks if IIS was installed successfully and if so, it adds firewall rules to allow HTTP (port 80) and HTTPS (port 443) traffic. 

5. **Deploys the Web App**: After IIS is installed, the script will then query and retrieve the directory where the web server's default page is stored, delete those files and then clone the web application in that directory. So that IIS can serve our own web application. Essentially, the default IIS page is replaced with the latest version of your web app, which is pulled directly from GitHub.

## Prerequisites

Before you run the script, make sure you’ve the following covered are in place:

- Windows Server: It’s ready and running.

- Admin Rights: You’ll need to run the script as an admin.

- Access to GitHub: The script needs to pull from the GitHub repos for both the web app and deployment tasks.

- PowerShell Execution Policy: Set this to allow script execution by running Set-ExecutionPolicy RemoteSigned.

## How to Use

To run the Script:

- Open PowerShell as an administrator.

- Run the script like this:

```powershell
./powershell-deployment.ps1
```

Provide Web App Repo URL when prompted or save it as an environment variable before you begin the script execution.

- Sit back and let the Script Do Its Magic.