param (
  [string]$path = ".\company-delete",
  [string]$hashlist = 'hashcatnt'
  )
new-item $path\..\company-output -itemtype directory
try {
  ntdsutil "activate instance ntds" ifm "create sysvol Full NoDefrag $path" q q q
}
catch {
write-host "Either the path you entered is not empty or does not exist." -ForegroundColor Red
break
}
Import-Module .\DSInternals\DSInternals.psd1
$systempath = Get-ChildItem -Path $path -Recurse -filter system | Select-Object -First 1
$ntdspath = Get-ChildItem -Path $path -Recurse -filter ntds.dit | Select-Object -First 1
$key = Get-BootKey -SystemHivePath $systempath.FullName
if($hashlist.ToLower() -eq "hashcatnt"){
    Get-ADDBAccount -All -DBPath $ntdspath.FullName -BootKey $key.psobject.BaseObject | Format-Custom -View HashcatNT | Out-File ".\hashes.txt" -Encoding ASCII
}
import-module activedirectory
$default_log = '.\user_info.csv'
foreach($domain in (get-adforest).domains){
    #query all users in domain
    get-aduser -LDAPFilter "(sAMAccountType=805306368)" `
    -properties enabled,whencreated,whenchanged,lastlogontimestamp,LockedOut,PwdLastSet,PasswordExpired,PasswordNeverExpires,DistinguishedName,servicePrincipalName `
    -server $domain |`
    select @{name='Domain';expression={$domain}},`
    SamAccountName,`
    @{Name="PwdAge";Expression={if($_.PwdLastSet -ne 0){(new-TimeSpan([datetime]::FromFileTimeUTC($_.PwdLastSet)) $(Get-Date)).days}else{0}}}, `
	@{Name="LockedOut";Expression = {$_.LockedOut}}, `
    enabled,PasswordExpired,PasswordNeverExpires | export-csv $default_log -NoTypeInformation
	}
Add-Content .\output.csv "id,domain,username,ntlmHASH,passwordAge,lockedOut,enabled,expired,neverExpires";
$dataLines = import-csv .\user_info.csv
$hashLines = import-csv .\hashes.txt -Delimiter : -Header hashUserName,ntlmHASH
$counter = 0;
foreach($dataLine in $dataLines){
	$counter++;
	$domain=$dataLine.domain;
	$username=$dataLine.SamAccountName;
	$passwordAge=$dataLine.PwdAge;
	$lockedOut=$dataLine.LockedOut;
	$enabled=$dataLine.enabled;
	$expired=$dataLine.PasswordExpired;
	$neverExpires=$dataLine.PasswordNeverExpires;
		foreach($hashLine in $hashLines)
		{
		$hashUserName=$hashLine.hashUserName;
			if ($username -eq $hashUserName)
			{
				$ntlmHASH=$hashLine.ntlmHASH;
			}
		}
	Add-Content .\output.csv "$counter,$domain,$username,$ntlmHASH,$passwordAge,$lockedOut,$enabled,$expired,$neverExpires";
}
#Get-ChildItem $path -Recurse | Remove-Item -Force -Recurse
Move-Item .\hashes.txt -Destination company-delete\hashes.txt
Move-Item .\user_info.csv -Destination company-delete\user_info.csv
Move-Item .\output.csv -Destination company-output\output.csv
"Export is finished."
