
#Cette fonction permet de tester si une page web au choix est active ou non en retournant un TRUE ou FALSE.
#Cette fonction 
#Exemple de comment lancer la commande: Test-WebsiteStatus -URL "https://google.com"
function Test_WebsiteStatus {
    param (
        [string]$URL #Déclaration de la variable URL qui va contenir un string de type https://google.com
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
  
  _    _ _______ _______ _____    ___   ___   ___                 _   _  __ 
 | |  | |__   __|__   __|  __ \  |__ \ / _ \ / _ \      /\       | | (_)/ _|
 | |__| |  | |     | |  | |__) |    ) | | | | | | |    /  \   ___| |_ _| |_ 
 |  __  |  | |     | |  |  ___/    / /| | | | | | |   / /\ \ / __| __| |  _|
 | |  | |  | |     | |  | |       / /_| |_| | |_| |  / ____ \ (__| |_| | |  
 |_|  |_|  |_|     |_|  |_|      |____|\___/ \___/  /_/    \_\___|\__|_|_|  
                                                                            
                                                                            
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
 
  _    _ _______ _______ _____    ______                            ___   ___   ___  
 | |  | |__   __|__   __|  __ \  |  ____|                          |__ \ / _ \ / _ \ 
 | |__| |  | |     | |  | |__) | | |__   _ __ _ __ ___ _   _ _ __     ) | | | | | | |
 |  __  |  | |     | |  |  ___/  |  __| | '__| '__/ _ \ | | | '__|   / /| | | | | | |
 | |  | |  | |     | |  | |      | |____| |  | | |  __/ |_| | |     / /_| |_| | |_| |
 |_|  |_|  |_|     |_|  |_|      |______|_|  |_|  \___|\__,_|_|    |____|\___/ \___/ 
                                                                                     
                                                                                     
"
        Write-Output "Latence: $Latency ms"
        Write-Output "Temps de chargement de la page: Non disponible"
        return $false
    }
}




function WebsiteStatus_ToCSV {
    param (
        [string[]]$Websites, #Paramètre qui va nous permettre de lister les pages webs désirés sous forme d'un string 
        [string]$LogFile = "C:\Logs\WebsiteStatus.csv"
    )

    # Create log folder if it doesn't exist
    $logFolder = Split-Path $LogFile
    if (-not (Test-Path $logFolder)) {
        New-Item -ItemType Directory -Path $logFolder -Force | Out-Null #Creation du fichier Logs sous C:\Logs s'il n'existe pas.
    }

    foreach ($site in $Websites) { #Boucle qui passe par chaque page web listé pour avoir son status (200,300,400)
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $status = "ERROR"

        try {
            $Headers = @{
                "User-Agent" = "Mozilla/5.0" #Si je ne me fait pas passer par un faux moteur de recherche sur mon laptop, je n'est aucune donnée. Ceci m'a été recommandé par ChatGPT.
            }
            #Invoke-WebRequest envoie une requete HTTP GET à l'URL dans $site. -Headers inclus le faux moteur de recherche si-haut et -TimeoutSec 5 retourne un "Error" si la page web ne répond pas après 5 secondes.
            $response = Invoke-WebRequest -Uri $site -Headers $Headers -TimeoutSec 5 
            $status = $response.StatusCode
        }
        catch {
            
        }

        #"$timestamp,$site,$status" vont être les titres de chaques colonne dans le fichier CSV. 
        "$timestamp,$site,$status" | Out-File -Append -FilePath $LogFile
    }

    Write-Output "Monitoring terminé. Résultats dans le fichier Logs dans C:\Logs"
}

function Start_MonitoringLoop {
    param (
        [string[]]$Websites, #Déclaration de la variable Website qui va contenir un string de type https://google.com
        [int]$IntervalMinutes = 5, #Déclaration de la variable IntervalMinutes qui va contenir un nombre (Int) pour 5 minutes.
        [string]$LogFile = "C:\Logs\WebsiteStatus.csv"
    )

    #Création du fichier logs s'il n'éxiste pas.
    $logFolder = Split-Path $LogFile
    if (-not (Test-Path $logFolder)) {
        New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
    }

    #Création de l'en-tête du fichier CSV s'il n'éxiste pas déjà. 
    if (-not (Test-Path $LogFile)) {
        "Temps,URL,Statut" | Out-File -FilePath $LogFile -Encoding UTF8
    }

    #Message d'avertissement qui indique le scan commence et que nous pouvons faire CTRL+C pour arrêter le scan.
    Write-Host "Démarrage du monitoring toutes les $IntervalMinutes minute(s)... Appuyez sur CTRL+C pour arrêter."

    #Commencement de la boucle à l'infini jusqu'à ce que l'on fasse CTRL+C
    while ($true) {
        foreach ($site in $Websites) { #Boucle while qui passe par les sites webs prédéfinis à chaque 2 minutes et attache la date et l'heure exacte au fichier CSV.
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $status = "ERROR"

            try {
                $Headers = @{ "User-Agent" = "Mozilla/5.0" } #Requete pour avoir les informations en utilisant Invoke-WebRequest
                $response = Invoke-WebRequest -Uri $site -Headers $Headers -UseBasicParsing -TimeoutSec 5
                $status = $response.StatusCode
            } catch {
                # Keep "ERROR" if request fails
            }

            "$timestamp,$site,$status" | Out-File -Append -FilePath $LogFile -Encoding UTF8
        }

        Start-Sleep -Seconds ($IntervalMinutes * 60)
    }
}

function Show-WebsiteStatusSummary {
    param (
        [string]$LogFile = "C:\Logs\WebsiteStatus.csv"
    )

    if (-not (Test-Path $LogFile)) {
        Write-Host "Fichier de log introuvable : $LogFile" -ForegroundColor Red
        return
    }

    $data = Import-Csv -Path $LogFile

    $summary = $data | Group-Object -Property URL | ForEach-Object {
        $url = $_.Name
        $total = $_.Group.Count
        $success = ($_.Group | Where-Object { $_.Statut -eq "200" }).Count
        $fail = $total - $success

        [PSCustomObject]@{
            Site = $url
            Vérifications = $total
            Succès = $success
            Échecs = $fail
        }
    }

    $summary | Format-Table -AutoSize
}


