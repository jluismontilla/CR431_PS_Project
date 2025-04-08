#Projet pour le cours CR431 à remettre le 11 avril 2025

#Ce projet à pour but de monitorer les pages webs désirées pour avoir leur statuts en ligne. Je suis technicien informatique et je dois souvent garder un oeil sur certaines pages
#webs qui sont reliés ou en parties reliés à mon travail. Je pense que ce projet va grandement m'aider à automatiser le tout pour ne pas être constament entrain d'utiliser des sites comme 
#https://www.isitdownrightnow.com/ ou même être toujours entrain d'envoyer des pings pour savoir si le problème viens de notre côté ou si c'est la page web qui est innacessible.
#Inspiration pour ce projet: https://www.codeproject.com/Articles/1214947/Http-Monitor-using-Powershell

#Cette fonction permet de tester si une page web au choix est active ou non en retournant un TRUE ou FALSE.
#Cette fonction 
#Exemple de comment lancer la commande: Test-WebsiteStatus -URL "https://google.com"
function Up_Or_Down {
    param (
        [string]$URL #Déclaration de la variable URL qui va contenir un string de type https://google.com
    )

    $StartTime = Get-Date #Démarre le temps avec la variable Get-Date qui nous donne l'heure et la date
    $Latency = "N/A" #Déclaration de la variable Latency à N/A
    $PageLoadTime = "N/A" #Déclaration de la variable PageLoadTime à N/A

    try { #Referenceerence  pour Try et Catch: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.5
        
        #Définition du Header HTTP 'User-Agent' pour simuler un navigateur Chrome réel
        #Ceci permet d'éviter d'être bloqué par certains sites web qui filtrent les requêtes automatiques
        #Demandé l'aide du prof pour cette section
        $Headers = @{
            "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }

        
        $RequestStart = Get-Date #Lancement du chronomètre pour mesurer la latence du serveur
        $Response = Invoke-WebRequest -Uri $URL -Headers $Headers -UseBasicParsing -TimeoutSec 5 #Envoie de la requête HTTP au site web spécifié Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.5
        $RequestEnd = Get-Date #Fin du chronomètre après avoir reçus la réponse

        $Latency = ($RequestEnd - $RequestStart).TotalMilliseconds  #Calcul de latence entre l'envoi et la réception de réponse
        $PageLoadTime = ($RequestEnd - $StartTime).TotalMilliseconds  #Temps total pour ouvrir la page web si active

        if ($Response.StatusCode -eq 200) { #Si le code HTTP returné est 200 qui signifie un succès, alors on affiche un message en ASCII Reference: https://www.w3schools.com/tags/ref_httpmessages.asp

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
        [string[]]$URL, #Variable Websites qui va nous permettre de lister les pages webs désirés sous forme d'un string 
        [string]$LogFile #Variable LogFile qui permet de spécifier l'endroit de sauvegarde du fichier CSV
    )

    if (-not ($LogFile -like '*.csv')) { #Vérification que le fichier qui va être enregistré est bel et bien un fichier CSV
        Write-Host "Le parametre -LogFile doit contenir un nom de fichier avec l'extension .csv (ex Logs.csv)" -ForegroundColor Red #Imprime ecran qui alerte l'utilisateur d'un problème avec l'extension du fichier en rouge
        return
    }
    
    $logFolder = Split-Path $LogFile
    if (-not (Test-Path $logFolder)) {
        New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
    }

    if (-not (Test-Path $LogFile)) {  #Ajoute l’en-tête uniquement si le fichier n'existe pas encore
        "Temps,URL,Statut" | Out-File -FilePath $LogFile -Encoding UTF8
    }

    foreach ($site in $URL) { #Boucle qui passe par chaque page web listé pour avoir son status (200,300,400)
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss" #Enregistre la date et l'heure actuelle
        $status = "ERROR" #Variable de statut en vas d'échec

        try { #Reference pour Try, Catch et Finally: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.5

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

    Write-Output "Monitoring terminé. Résultats dans le fichier Logs dans $LogFile" #Message de confirmation dans le termninal une fois la fonction complété avec succès
}

function Start_MonitoringLoop {
    param (
        [string[]]$URL, #Déclaration de la variable Website qui va contenir un string de type https://google.com
        [int]$IntervalMinutes, #Déclaration de la variable IntervalMinutes qui va contenir un nombre (Int) pour x nombres de minutes.
        [string]$LogFile
    )

    
    if (-not ($LogFile -like '*.csv')) { #Vérification que le fichier qui va être enregistré est bel et bien un fichier CSV
        Write-Host "Le parametre -LogFile doit contenir un nom de fichier avec l'extension .csv (ex Logs.csv)" -ForegroundColor Red #Imprime ecran qui alerte l'utilisateur d'un problème avec l'extension du fichier en rouge
        return
    }
    
    $logFolder = Split-Path $LogFile
    if (-not (Test-Path $logFolder)) {
        New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
    }

   
    if (-not (Test-Path $LogFile)) {  #Ajoute l’en-tête uniquement si le fichier n'existe pas encore
        "Temps,URL,Statut" | Out-File -FilePath $LogFile -Encoding UTF8
    }

    $StartTime = Get-Date -Format "dd-MM-yyyy HH:mm:ss"

    #Message d'avertissement qui indique le scan commence et que nous pouvons faire CTRL+C pour arrêter le scan.
    Write-Host "Démarrage du monitoring toutes les $IntervalMinutes minutes... Appuyez sur CTRL+C pour arrêter."
    Write-Host "Début du scan à $startTime" -ForegroundColor Yellow
    

    
    try { #Ce try est simplement là pour que le message ''Monitoring terminé. Résultats dans le fichier...'' puisse s'afficher lorsque l'utilisateur fasse CTRL + C 
        while ($true) { #Tant que l'utilisateur n'arrête pas la boucle alors...
            foreach ($site in $URL) { #Pour chaque site dans la liste d'URL spécifié par l'utilisateur
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss" #Applique la date et l'heure dans timestamp
                $status = "ERROR" #Applique le string erreur à $status au cas ou le site web n'est pas accessible

                try { 
                    #Définition du Header HTTP 'User-Agent' pour simuler un navigateur Chrome réel
                    #Ceci permet d'éviter d'être bloqué par certains sites web qui filtrent les requêtes automatiques
                    #Demandé l'aide du prof pour cette section
                    $Headers = @{"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"} 
                    $response = Invoke-WebRequest -Uri $site -Headers $Headers -UseBasicParsing -TimeoutSec 5 #Envoie la requete HTTP avec un timeout de 5 secondes Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.5
                    $status = $response.StatusCode #Si la requete réussit, alors nous obtenons le code HTTP (200, 300, 400) Reference:https://www.w3schools.com/tags/ref_httpmessages.asp
                } catch {
                    #Le status reste "ERROR" si une erreur survient
                }

                "$timestamp,$site,$status" | Out-File -Append -FilePath $LogFile -Encoding UTF8 #Enregiste le résultat dans le fichier CSV
            }

            Start-Sleep -Seconds ($IntervalMinutes * 60) #Attend le nombre de minutes spécifié avant de refaire une boucle
        }
    }
    finally { #Ceci s'execute lorsque CTRL + C est entré par l'utilisateur
    
        Write-Host "Monitoring terminé. Résultats dans le fichier Logs dans $LogFile" #Message de fin de boucle avec destination du fichier CSV

        #Reference pour Try, Catch et Finally: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.5
    }
}

function Show_WebsiteStatusSummary {
    param (
        [string]$LogFile, #Chemin vers le fichier CSV à analyser
        [int]$MinSuccessRate = 0, #Variable pou afficher seulement 
        [switch]$GridView #Affiche le résumé du fichier CSV dans le terminal

    )

    $data = Import-Csv -Path $LogFile #import les données du fichier CSV dans la variable data

    $summary = $data | Group-Object -Property URL | ForEach-Object { #Enregistre chaque stat sur chaque URL pour ensuite les calculer
        $url = $_.Name
        $total = $_.Group.Count
        $success = ($_.Group | Where-Object { $_.Statut -eq "200" }).Count
        $fail = $total - $success
        $successRate = if ($total -gt 0) { [math]::Round(($success / $total) * 100, 2) } else { 0 } #Reference: https://ss64.com/ps/syntax-math.html

        if ($successRate -gt $MinSuccessRate) {
            [PSCustomObject]@{
                Site = $url
                Verifications = $total
                Succes = $success
                Echecs = $fail
                TauxSucces = "$successRate%"
            }
        }
    } | Where-Object {$_ -ne $null} #Filtre pour garder seulement les objets avec succes

    if ($GridView){
        $summary | Out-GridView -Title "Résumé de l'état des sites web" #Affiche la grille dans le terminal si l'utilisateur l'active avec -GridView
                                                                        #Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-gridview?view=powershell-7.5
    }

    $summary | Format-Table -AutoSize #Imprime le résumé sous forme de tableau dans le terminal
}


