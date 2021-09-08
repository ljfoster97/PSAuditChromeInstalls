# Script to audit installed version of Google Chrome, OS version and last logon date of all AD machines. 
# lyndon@veritechcorp.com.au

$Computers = Get-Adcomputer -Filter * -Properties lastlogondate, operatingsystem
    foreach ($Computer in $Computers) {
        $lastlogon = $computer.lastlogondate
        $OS = $computer.operatingsystem
        $PC = $computer.dnshostname
        $online = $false
        $ver = ''
        if (Test-Connection $pc -Count 1 -Quiet -BufferSize 1) {
            $online = $true
            $exe = "\\$pc\c$\Program Files*\Google\Chrome\Application\chrome.exe"
            if (Test-Path $exe) {
                $path = (Resolve-Path $exe).ProviderPath
                $ver = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($path).FileVersion
            }
        }
        [pscustomobject]@{
            ComputerName = $PC.split('.', 2)[0]
            OS = $OS
            Online = $online
            ChromeVersion = $ver
            Logon = $lastlogon
        } | epcsv C:\temp\AdChromeVersions$(Get-Date -Format yyyy-MM-dd_HH).csv -Append -NoTypeInformation 
    }