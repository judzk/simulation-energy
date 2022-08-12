<#
.SYNOPSIS
	Cet outil a été conçu pour simuler differents tarifs électriques en fonction des données rééls de votre habitation, si vous hesitez a passer en HP/HC ou si vous voulez voir la différence avoir les tarifs d'un autre fournisseur
.PARAMETER files
	Nom du fichier où récupérer les données
.PARAMETER hphc
	Spécifie que vous souhaitez utiliser les heures creuses
.PARAMETER month
	Spéficie les mois sur lesquels vous voulez une estimation du coût ( il faut lister tout les mois désirés )
.EXAMPLE
	# Calcul de la conso pour les mois de mai et juin en HP/HC
	.\compare.ps1 -file .\Enedis_Conso_Heure_20210801-20220806_01445007189250.csv -month "05-06" -hphc
.NOTES
AUTHOR: JuDzk
#>

[CmdletBinding(SupportsShouldProcess = $true)]
Param(
	[String]$file,
	[Switch]$hphc = $False,
	[String]$month
)
###################### Variable
$tarifHP = "0.1306" 					# Tarif HP, mettre un point (.) pour séparer les unitées
$tarifHC = "0.1149" 					# Tarif HC, mettre un point (.) pour séparer les unitées
$plagehphc1 = "01:00-07:30"				# Première plage d'heures creuses
$plagehphc2 = "13:00-14:30"				# Deuxième plage d'heures creuses
$abo = "9.68"							# Tarif de l'abonnement mensuel, mettre un point (.) pour séparer les unitées
###################### Ne rien modifier plus bas
$consoParJour = @()
$data = import-csv $file -Delimiter ';'
$nbrOfMonth = ($data | ForEach-Object {([datetime]($_.horodate)).ToString('MM');} | get-unique).Length
if ($hphc){
	$min1 = Get-Date $plagehphc1.Split("-")[0]
	$max1 = Get-Date $plagehphc1.Split("-")[1]
	$min2 = Get-Date $plagehphc2.Split("-")[0]
	$max2 = Get-Date $plagehphc2.Split("-")[1]
	$data | ForEach-Object {
		if ($month -ne ''){
			$currentmonth = ([datetime]($_.horodate)).ToString('MM');
			$myobj1 = $_
			$month.Split("-") |ForEach-Object {
				if ($currentmonth -eq $_){
					$conso += @([PSCustomObject]@{
						jour = ([datetime]($myobj1.horodate)).ToString('MM/dd/yyyy');
						heure = ([datetime]($myobj1.horodate)).ToString('HH:mm');
						conso = $myobj1.Valeur;
						hphc = $(
							if ($min1.TimeOfDay -le ([datetime]($myobj1.horodate)).ToString('HH:mm') -and $max1.TimeOfDay -ge ([datetime]($myobj1.horodate)).ToString('HH:mm') -OR $min2.TimeOfDay -le ([datetime]($myobj1.horodate)).ToString('HH:mm') -and $max2.TimeOfDay -ge ([datetime]($myobj1.horodate)).ToString('HH:mm')) {"HC"} else {"HP"}
							);
					})
				}
			}
		} else {
			$conso += @([PSCustomObject]@{
				jour = ([datetime]($_.horodate)).ToString('MM/dd/yyyy');
				heure = ([datetime]($_.horodate)).ToString('HH:mm');
				conso = $_.Valeur;
				hphc = $(
					if ($min1.TimeOfDay -le ([datetime]($_.horodate)).ToString('HH:mm') -and $max1.TimeOfDay -ge ([datetime]($_.horodate)).ToString('HH:mm') -OR $min2.TimeOfDay -le ([datetime]($_.horodate)).ToString('HH:mm') -and $max2.TimeOfDay -ge ([datetime]($_.horodate)).ToString('HH:mm')) {"HC"} else {"HP"}
					);
			})
		}
	}
	$consoParJour = $conso | where-object { $_.hphc -eq "HP"} | group-object { $_.jour} | Select-Object @{n='Jour';e={$_.Group | Select-object -Expand Jour -First 1}},
	@{n='Valeur';e={($_.Group | Measure-Object conso -Sum).Sum/1000/2}},
	@{n='Cout';e={(($_.Group | Measure-Object conso -Sum).Sum/1000/2)*$tarifHP}}
	$consoParJour += $conso | where-object { $_.hphc -eq "HC"} | group-object { $_.jour} | Select-Object @{n='Jour';e={$_.Group | Select-object -Expand Jour -First 1}},
	@{n='Valeur';e={($_.Group | Measure-Object conso -Sum).Sum/1000/2}},
	@{n='Cout';e={(($_.Group | Measure-Object conso -Sum).Sum/1000/2)*$tarifHC}}
	$coutConsoTotal = (($consoParJour.Cout | Measure-Object -Sum).Sum)
} else {
	$data | ForEach-Object {
		if ($month -ne ''){
			$currentmonth = ([datetime]($_.horodate)).ToString('MM');
			$myobj1 = $_
			$month.Split("-") |ForEach-Object {
				if ($currentmonth -eq $_){
					$conso += @([PSCustomObject]@{
						jour = ([datetime]($myobj1.horodate)).ToString('MM/dd/yyyy');
						heure = ([datetime]($myobj1.horodate)).ToString('HH:mm');
						conso = $myobj1.Valeur;
					})
				}
			}
		} else {
			$conso += @([PSCustomObject]@{
				jour = ([datetime]($_.horodate)).ToString('MM/dd/yyyy');
				heure = ([datetime]($_.horodate)).ToString('HH:mm');
				conso = $_.Valeur;
			})
		}
	}
	$consoParJour = $conso | group-object { $_.jour} | Select-Object @{n='Jour';e={$_.Group | Select-object -Expand Jour -First 1}},
	@{n='Valeur';e={($_.Group | Measure-Object conso -Sum).Sum/1000/2}},@{n='Cout';e={(($_.Group | Measure-Object conso -Sum).Sum/1000/2)*[decimal]$tarifHP}}
	$coutConsoTotal = ($consoParJour.Cout | Measure-Object -Sum).Sum
}
if ($month -eq $null){
	$coutAbo = [decimal]$abo * $nbrOfMonth
} else {
	$coutAbo = [decimal]$abo * $month.Split("-").Length
}
Write-Host "Cout Conso : $([math]::Round($coutConsoTotal,2))€"
write-host "Cout Abonnement : $([math]::Round($coutAbo,2))€"
write-host "Cout Total $([math]::Round( $coutAbo + $coutConsoTotal,2))€"