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
$ImportedNewCSV.Hostname