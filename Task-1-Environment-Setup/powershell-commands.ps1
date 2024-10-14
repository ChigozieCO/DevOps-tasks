# Create self signed certificate
New-SelfSignedCertificate -DnsName "<DNS Name>" -CertStoreLocation Cert:\LocalMachine\My

# Create HTTPS Listener
winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="<DNS Name>"; CertificateThumbprint="<ThumbPrint>"}'

# Add a Firewall rule for the HTTPS Listener
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5986

# Set the Service for Basic Authentication to `True` on Windows Server
Set-Item -Force WSMan:\localhost\Service\auth\Basic $true

# Verify that our HTTPS listener was created and the Basic Authentication service is set to true.
winrm e winrm/config/Listener
winrm get winrm/config