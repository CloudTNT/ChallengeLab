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
# Get Start Time
$startDTM = WriteLog (Get-Date)

#Import CSV file
$devices = Import-Csv "C:\code\automation-201-master\ChallengeLab\data.csv"

#URL that will be used for restCalls
$report	= "http://192.168.99.100:3000/records"
$db 	= "http://192.168.99.100:3000/db"

$restReport = restCall -Method get -URI $report
$restDB     = restCall -Method get -URI $db

#Pull out the missing devices and store them in a variable. 
$MissingDevice = Compare-Object -ReferenceObject ($restReport) -DifferenceObject ($ImportedNewCSV) -PassThru
$i = 0
$MissingDevice | foreach {$i++}
Writelog "$i + "missing entries" "

#Extending the name of each device to 16 characters long with "-" in between the name and ramdom characters. Then creates new csv file with new names.
$NewDeviceList = Foreach ($Entry in $MissingDevice) {

    Switch ($Entry."Hostname") {
        $_ {$Entry."Hostname" = $_ += "-"+ ([char[]]([char]'a'..[char]'z') + 0..9 | sort {get-random})[0..15] -join '' -replace '\s',''}
        $_ {$Entry."Hostname" = $_.substring(0, [System.Math]::Min(16, $_.Length))}
        default {Write-Error "Unexpected value for Hostname"}
    }
    $Entry
}
$NewDeviceList | Export-CSV "C:\code\automation-201-master\ChallengeLab\datav2.csv" -NoTypeInformation
$ImportedNewCSV = Import-Csv "C:\code\automation-201-master\ChallengeLab\datav2.csv"

#log the Hostname
WriteLog $ImportedNewCSV.Hostname

#Create json file with IPAddress and hostname form ImportedNewCSV
$ImportedNewCSV | select "IP Address",Hostname | ConvertTo-Json | Out-File "C:\code\automation-201-master\ChallengeLab\MissingDevices.json"

#Log count devices broken by vendor
$Vendors = @{}
$devices.Vendor | foreach {$Vendors["$_"] += 1}
$Vendors.keys | where {$Vendors["$_"] -gt 1} 
$Vendors 

#MAC address that contains E1
$VendorMax = @("Juniper", "Cisco","F5","Netscout")
ForEach($i in $VendorMax){
$outPut = $devices | Where-Object "Vendor" -eq "$i"
$outPut1 = $outPut| Where-Object "Mac Address" -Like "*E1*"
$outPut1
WriteLog $outPut1
}

#Hostname contains 3 or 5 characters
ForEach($i in $devices.hostname){
    $name = $i | where { $_.length -eq 5 -or $_.length -eq 3}
    Write-Host $name
    WriteLog $name
}

#Add missing IP Address
$header = @{ "Accept" = "application/json"; "Content-Type" = "application/json"  }
$MissingDevice | forEach-object {

$body = @"
{
 "serial"    : "$($_.Serial)",
 "ipAddress" : "$($_."IP Address")"
 }
"@
restCall -Uri $report -Method Post -Header $header -Body $body
}














# Get End Time
$endDTM = WriteLog (Get-Date)

# Echo Time elapsed
WriteLog "Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds"

