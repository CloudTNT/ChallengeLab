#Function to Invoke-RestMethod
function restCall ($Method, $URI, $Header, $body) {
	$param = @{
		Method 	= $Method;
		Uri 	= $URI;
		Headers	= $header;
		Body	= $body;
	}
	Invoke-RestMethod @param
}

#log function for script
Function WriteLog
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}
$Logfile = "C:\code\automation-201-master\ChallengeLab\output.txt"

# Logging Start Time
WriteLog ($startDTM = (Get-Date))

#Download file from Github and Import CSV file
$Headers = @{“Authorization”=”121e4abd6a6887bc396401c273691fd87a46e269"}
$url = 'https://raw.githubusercontent.com/CloudTNT/ChallengeLab/master/data.csv'
Invoke-WebRequest $url -Headers $Headers -OutFile C:\Users\tejadaj\Downloads\data.csv 
$devices = Import-Csv "C:\Users\tejadaj\Downloads\data.csv" #"C:\code\automation-201-master\ChallengeLab\data.csv"
$devices

#URL that will be used for restCalls and Header
$report	= "http://192.168.99.100:3000/records"
$db 	= "http://192.168.99.100:3000/db"

$restReport = restCall -Method get -URI $report
$restDB     = restCall -Method get -URI $db

$header = @{ "Accept" = "application/json"; "Content-Type" = "application/json"  }

#Pull out the missing devices and store them in a variable. ***confirm difference 
$MissingDevices = Compare-Object -ReferenceObject ($restReport.serial) -DifferenceObject ($devices.serial) -PassThru
#Determin how many devices are missing
$i = 0
$MissingDevices | foreach {$i++}
$i
Writelog ("$i + missing entries")

#Storing list of missing devices with all data
$MissingDeviceTable = @{}
$MissingDevices | foreach {
        $MissingDeviceTable["$_"] += 1
}
#exporting data into CSV readable format to compare files and pull accurate data.
$MissingDeviceTable.GetEnumerator() | select Name | Export-Csv C:\code\automation-201-master\ChallengeLab\MissingSeriallist.csv -NoTypeInformation
$MissingDeviceSerial = Import-Csv C:\code\automation-201-master\ChallengeLab\MissingSeriallist.csv

$addMissingDevices = @()
foreach($i in $MissingDeviceSerial.Name) {
    $MissingDevices = $devices| Where-Object "Serial" -Match "$i"
    $addMissingDevices += $MissingDevices
}

#Extending the name of each device to 16 characters long with "-" in between the name and ramdom characters.
#Then creates new csv file with new names.
$newDeviceList = Foreach ($Entry in $devices) {

    Switch ($Entry."Hostname") {
        $_ {$Entry."Hostname" = $_ += "-"+ ([char[]]([char]'a'..[char]'z') + 0..9 | sort {get-random})[0..15] -join '' -replace '\s',''}
        $_ {$Entry."Hostname" = $_.substring(0, [System.Math]::Min(16, $_.Length))}
        default {Write-Error "Unexpected value for Hostname"}
    }
    $Entry
}
$newDeviceList | Export-CSV "C:\code\automation-201-master\ChallengeLab\datav2.csv" -NoTypeInformation
$newDeviceList = Import-Csv "C:\code\automation-201-master\ChallengeLab\datav2.csv"

#log the Hostname
WriteLog $newDeviceList.Hostname

#Create json file with IPAddress and hostname form ImportedNewCSV
$newDeviceList | select "IP Address",Hostname | ConvertTo-Json | Out-File "C:\code\automation-201-master\ChallengeLab\MissingDevices.json"

#Log count devices broken by vendor.***Figure out how to log HashTable here.
$Vendors = @{}
$devices.Vendor	| foreach {
	$Vendors["$_"] += 1
}
$Vendors.keys	| where {
	$Vendors["$_"] -gt 1
} 
Writelog $Vendors 

#MAC address that contains E1 ***Why can't I get the where-object on one line here??????????
$vendorMAC = @("Juniper", "Cisco","F5")
ForEach ($i in $vendorMAC) {
	$outPut = $devices | Where-Object "Vendor" -eq "$i"
	$outPut1 = $outPut| Where-Object "Mac Address" -Like "*E1*"
	$outPut1
	WriteLog $outPut1
}

#Hostname contains 3 or 5 characters
ForEach($i in $devices.hostname){
    $name = $i | where { 
		$_.length -eq 5 -or $_.length -eq 3}
    WriteLog $name
}

#Add missing info to Rest Server
$addMissingDevices | forEach-object {
$body = @"
{
 "serial"    : "$($_.Serial)",
 "ipAddress" : "$($_."IP Address")"
 }
"@
restCall -Uri $report -Method Post -Header $header -Body $body
}

# Get End Time
writelog ($endDTM = (Get-Date))

# Echo Time elapsed
WriteLog "Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds"

