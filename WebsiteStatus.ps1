#Projet pour le cours CR431 à remettre le 11 avril 2025

#Ce projet à pour but de monitorer les pages webs désirées pour avoir leur statuts en ligne. Je suis technicien informatique et je dois souvent garder un oeil sur certaines pages
#webs qui sont reliés ou en parties reliés à mon travail. Je pense que ce projet va grandement m'aider à automatiser le tout pour ne pas être constament entrain d'utiliser des sites comme 
#https://www.isitdownrightnow.com/ ou même être toujours entrain d'envoyer des pings pour savoir si le problème viens de notre côté ou si c'est la page web qui est innacessible.

#Cette fonction permet de tester si une page web au choix est active ou non en retournant un TRUE ou FALSE.
#Cette fonction 
#Exemple de comment lancer la commande: Test-WebsiteStatus -URL "https://google.com"
function Test_WebsiteStatus {
    param (
        [string]$URL #Déclaration de la variable URL qui va contenir un string de type https://google.com
    )

    $StartTime = Get-Date #Démarre le temps avec la variable Get-Date qui nous donne l'heure et la date
    $Latency = "N/A" #Déclaration de la variable Latency à N/A
    $PageLoadTime = "N/A" #Déclaration de la variable PageLoadTime à N/A

    try {
        
        #Définition du Header HTTP 'User-Agent' pour simuler un navigateur Chrome réel
        #Ceci permet d'éviter d'être bloqué par certains sites web qui filtrent les requêtes automatiques
        #Demandé l'aide du prof pour cette section
        $Headers = @{
            "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }

        
        $RequestStart = Get-Date #Lancement du chronomètre pour mesurer la latence du serveur
        $Response = Invoke-WebRequest -Uri $URL -Headers $Headers -UseBasicParsing -TimeoutSec 5 #Envoie de la requête HTTP au site web spécifié
        $RequestEnd = Get-Date #Fin du chronomètre après avoir reçus la réponse

        $Latency = ($RequestEnd - $RequestStart).TotalMilliseconds  #Calcul de latence entre l'envoi et la réception de réponse
        $PageLoadTime = ($RequestEnd - $StartTime).TotalMilliseconds  #Temps total pour ouvrir la page web si active

        if ($Response.StatusCode -eq 200) { #Si le code HTTP returné est 200 qui signifie un succès, alors on affiche un message en ASCII

            #Imprime écran des résultats avec une écriture en art ASCII que j'ai fais sur https://patorjk.com
            Write-Output "
  
  _    _ _______ _______ _____    ___   ___   ___                 _   _  __ 
 | |  | |__   __|__   __|  __ \  |__ \ / _ \ / _ \      /\       | | (_)/ _|
 | |__| |  | |     | |  | |__) |    ) | | | | | | |    /  \   ___| |_ _| |_ 
 |  __  |  | |     | |  |  ___/    / /| | | | | | |   / /\ \ / __| __| |  _|
 | |  | |  | |     | |  | |       / /_| |_| | |_| |  / ____ \ (__| |_| | |  
 |_|  |_|  |_|     |_|  |_|      |____|\___/ \___/  /_/    \_\___|\__|_|_|  
                                                                            
                                                                            
"
            Write-Output "Latence: $Latency ms" #Affiche la lentence en millisecondes
            Write-Output "Temps de chargement de la page: $PageLoadTime ms" #Affiche le temps total de chargement
            return $true #Retourne VRAI pour indiquer que le site web est en ligne
        }
    }
    catch { #Si la requête échoue alors...
        $RequestEnd = Get-Date                                    #}
                                                                    #Enregistre le moment de l'échec et calcul la latence jusqu'à l'erreur
        $Latency = ($RequestEnd - $StartTime).TotalMilliseconds   #}

        #Imprime écran des résultats avec une écriture en art ASCII que j'ai fais sur https://patorjk.com
        Write-Output "
 
  _    _ _______ _______ _____    ______                            ___   ___   ___  
 | |  | |__   __|__   __|  __ \  |  ____|                          |__ \ / _ \ / _ \ 
 | |__| |  | |     | |  | |__) | | |__   _ __ _ __ ___ _   _ _ __     ) | | | | | | |
 |  __  |  | |     | |  |  ___/  |  __| | '__| '__/ _ \ | | | '__|   / /| | | | | | |
 | |  | |  | |     | |  | |      | |____| |  | | |  __/ |_| | |     / /_| |_| | |_| |
 |_|  |_|  |_|     |_|  |_|      |______|_|  |_|  \___|\__,_|_|    |____|\___/ \___/ 
                                                                                     
                                                                                     
"
        Write-Output "Latence: $Latency ms" #Affiche la lentence en millisecondes
        Write-Output "Temps de chargement de la page: Non disponible" #Pas de temp de chargement calculable
        return $false #Retourne FAUX pour indiquer une erreur ou un site non-actif
    }
}




function WebsiteStatus_ToCSV {
    param (
        [string[]]$Websites, #Variable Websites qui va nous permettre de lister les pages webs désirés sous forme d'un string 
        [string]$LogFile = "C:\Logs\WebsiteStatus.csv" #Variable LogFile qui montre le chemin vers le fichier CSV
    )

    
    $logFolder = Split-Path $LogFile #On récupère le dossier contenant le fichier log
    if (-not (Test-Path $logFolder)) {
        New-Item -ItemType Directory -Path $logFolder -Force | Out-Null #Création du dossier Logs sous C:\Logs s'il n'existe pas.
    }

    foreach ($site in $Websites) { #Boucle qui passe par chaque page web listé pour avoir son status (200,300,400)
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss" #Enregistre la date et l'heure actuelle
        $status = "ERROR" #Variable de statut en vas d'échec

        try {
            #Définition du Header HTTP 'User-Agent' pour simuler un navigateur Chrome réel
            #Ceci permet d'éviter d'être bloqué par certains sites web qui filtrent les requêtes automatiques
            #Demandé l'aide du prof pour cette section
            $Headers = @{
               "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
            }
            #Invoke-WebRequest envoie une requete HTTP GET à l'URL dans $site. -Headers inclus le faux moteur de recherche si-haut et -TimeoutSec 5 retourne un "Error" si la page web ne répond pas après 5 secondes.
            $response = Invoke-WebRequest -Uri $site -Headers $Headers -TimeoutSec 5 
            $status = $response.StatusCode #Si la requête réussit on obtient le code HTTP
        }
        catch {
                #On garde le statut ERROR en cas d'échec
        }

        #"$timestamp,$site,$status" vont être les titres de chaques colonne dans le fichier CSV. 
        "$timestamp,$site,$status" | Out-File -Append -FilePath $LogFile
    }

    Write-Output "Monitoring terminé. Résultats dans le fichier Logs dans C:\Logs" #Message de confirmation dans le termninal une fois la fonction complété avec succès
}

function Start_MonitoringLoop {
    param (
        [string[]]$Websites, #Déclaration de la variable Website qui va contenir un string de type https://google.com
        [int]$IntervalMinutes = 5, #Déclaration de la variable IntervalMinutes qui va contenir un nombre (Int) pour 5 minutes.
        [string]$LogFile = "C:\Logs\WebsiteStatus.csv"
    )

    
    $logFolder = Split-Path $LogFile #On récupère le dossier contenant le fichier log
    if (-not (Test-Path $logFolder)) { #Création du dossier logs s'il n'éxiste pas.
        New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
    }

    #Création du fichier CSV avec les en-têtes s'il n'éxiste pas déjà. 
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

            "$timestamp,$site,$status" | Out-File -Append -FilePath $LogFile -Encoding UTF8 #Enregistre les résultats dans le fichier CSV
        }

        Start-Sleep -Seconds ($IntervalMinutes * 60) #Pause en secondes avant de recommencer la boucle
    }
}

function Show-WebsiteStatusSummary {
    param (
        [string]$LogFile = "C:\Logs\WebsiteStatus.csv" #Chemin vers le fichier CSV à analyser
    )

    if (-not (Test-Path $LogFile)) { #Si le fichier CSV n'existe pas, on affiche un message d'erreur en couleur rouge
        Write-Host "Fichier de log introuvable : $LogFile" -ForegroundColor Red
        return
    }

    $data = Import-Csv -Path $LogFile #import les données du fichier CSV dans la variable data

    $summary = $data | Group-Object -Property URL | ForEach-Object { #On groupe les entrées du CSV par URL et par groupe
        $url = $_.Name #nom du site web
        $total = $_.Group.Count #Nombre total de vérifications 
        $success = ($_.Group | Where-Object { $_.Statut -eq "200" }).Count #Nombre de vérifications réussies
        $fail = $total - $success #Nombre d'échec, toute autre réponse différent au code HTTP 200

        [PSCustomObject]@{ #Retour d'objet personnalisé qui contient les statistiques par site web
            Site = $url
            Verifications = $total
            Succes = $success
            Echecs = $fail
        }
    }

    $summary | Format-Table -AutoSize #Imprime le résumé sous forme de tableau dans le terminal
}


