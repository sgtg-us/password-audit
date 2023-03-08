# password-audit
Powershell script to export hashed creds and user info from Active Directory

# Prerequisites
1. Run the script on a domain controller that has Powershell 3 or higher.
2. Copy script and DSInternals folder to a domain controller Desktop.
3. Open Powershell as administrator.
4. Run "Set-ExecutionPolicy Unrestricted" on Domain Controller prior to running the script.


# Post script Cleanup:
1. Change owner of company-delete folder to logged in user. Make sure to check "Replace owner on subcontainers and objects" and "Replace all child object permission entries with inheritable permission entires from this object."
2. Delete the company-delete and DSInternals folders.
3. Delete the company-output folder.

# Troubleshooting:
Try to run the below command in that powershell window. Maybe something is blocking the DSInternals import. 
Import-Module .\DSInternals\DSInternals.psd1

If that fails, run this command to see what powershell version you have.
$PSVersionTable.PSVersion

If it's Powershell 2, you'll need to upgrade to 3 at minimum.

If it’s Powershell 5+, run this and see if it installs.
Install-Module DSInternals

If that works, comment the below line in the script.
Import-Module .\DSInternals\DSInternals.psd1
