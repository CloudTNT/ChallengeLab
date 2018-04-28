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
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}
$Logfile = "C:\code\automation-201-master\ChallengeLab\output.txt"
# Get Start Time
$startDTM = LogWrite (Get-Date)

#Import CSV file
$devices = Import-Csv "C:\code\automation-201-master\ChallengeLab\data.csv"

#URL that will be used for restCalls
$report	= "http://192.168.99.100:3000/records"
$db 	= "http://192.168.99.100:3000/db"



$ImportedCSV = Import-Csv "C:\code\automation-201-master\ChallengeLab\datav1.csv"
$NewCSV = Foreach ($Entry in $ImportedCsv) {

    Switch ($Entry."Hostname") {
        $_ {$Entry."Hostname" = $_ += "-"+ ([char[]]([char]'a'..[char]'z') + 0..9 | sort {get-random})[0..15] -join '' -replace '\s',''}
        $_ {$Entry."Hostname" = $_.substring(0, [System.Math]::Min(16, $_.Length))}
        default {Write-Error "$($Entry."Branch Number") has unexpected value for Available Person"}
    }
    $Entry
}
$NewCSV | Export-CSV "C:\code\automation-201-master\ChallengeLab\datav2.csv" -NoTypeInformation
$ImportedNewCSV = Import-Csv "C:\code\automation-201-master\ChallengeLab\datav2.csv"
LogWrite $ImportedNewCSV.Hostname



# Get End Time
$endDTM = LogWrite (Get-Date)

# Echo Time elapsed
LogWrite "Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds"