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
$i

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
$Vendors = @("Juniper", "Cisco","F5")
$Vendors | ForEach-Object{
$outPut = $devices.Vendor | Where-Object {$_ -match $Vendors[$_]}
$i = 0
$outPut | foreach {$i++}
WriteLog "$i + $_"
}

$outPut










# Get End Time
$endDTM = WriteLog (Get-Date)

# Echo Time elapsed
WriteLog "Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds"

