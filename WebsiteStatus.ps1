
#Cette fonction permet de tester si une page web au choix est active ou non en retournant un TRUE ou FALSE.
#Cette fonction 
#Exemple de comment lancer la commande: Test-WebsiteStatus -URL "https://google.com"
function Test-WebsiteStatus {
    param (
        [string]$URL
    )

    $StartTime = Get-Date
    $Latency = "N/A"
    $PageLoadTime = "N/A"

    try {
        
        # Set up the request with a fake User-Agent
        $Headers = @{
            "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }

        # Measure request latency
        $RequestStart = Get-Date
        $Response = Invoke-WebRequest -Uri $URL -Headers $Headers -UseBasicParsing -TimeoutSec 5
        $RequestEnd = Get-Date

        $Latency = ($RequestEnd - $RequestStart).TotalMilliseconds  #Temps de reponse pour latence site actif
        $PageLoadTime = ($RequestEnd - $StartTime).TotalMilliseconds  #Temps total pour ouvrir la page web si active

        if ($Response.StatusCode -eq 200) {

            #Imprime ecran des resultats avec une ecriture en art ASCII que j'ai fais sur https://patorjk.com
            Write-Output "
  _   _ _____ _____ ____    ____   ___   ___       _        _   _  __ 
 | | | |_   _|_   _|  _ \  |___ \ / _ \ / _ \     / \   ___| |_(_)/ _|
 | |_| | | |   | | | |_) |   __) | | | | | | |   / _ \ / __| __| | |_ 
 |  _  | | |   | | |  __/   / __/| |_| | |_| |  / ___ \ (__| |_| |  _|
 |_| |_| |_|   |_| |_|     |_____|\___/ \___/  /_/   \_\___|\__|_|_|
"
            Write-Output "Latence: $Latency ms"
            Write-Output "Temps de chargement de la page: $PageLoadTime ms"
            return $true
        }
    }
    catch {
        $RequestEnd = Get-Date
        $Latency = ($RequestEnd - $StartTime).TotalMilliseconds  #Temp de latence pour page web non disponible

        #Imprime ecran des resultats avec une ecriture en art ASCII que j'ai fais sur https://patorjk.com
        Write-Output "
  _   _ _____ _____ ____    _____                       ____   ___   ___  
 | | | |_   _|_   _|  _ \  | ____|_ __ _ __ ___  _ __  |___ \ / _ \ / _ \
 | |_| | | |   | | | |_) | |  _| | '__| '__/ _ \| '__|   __) | | | | | | |
 |  _  | | |   | | |  __/  | |___| |  | | | (_) | |     / __/| |_| | |_| |
 |_| |_| |_|   |_| |_|     |_____|_|  |_|  \___/|_|    |_____|\___/ \___/
"
        Write-Output "Latence: $Latency ms"
        Write-Output "Temps de chargement de la page: Non disponible"
        return $false
    }
}



function Monitor-Websites {
    param (
        [string[]]$Websites,
        [string]$LogFile = "C:\Logs\WebsiteStatus.csv"
    )

    if (!(Test-Path $LogFile)) {
        "Timestamp,Website,Status" | Out-File -FilePath $LogFile
    }

    foreach ($site in $Websites) {
        $status = Test-WebsiteStatus -URL $site
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$timestamp,$site,$status" | Out-File -Append -FilePath $LogFile
    }
}
