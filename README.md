# Estimation Consomation Electrique
Cet outil a été conçu pour simuler differents tarifs électriques en fonction des données rééls de votre habitation, si vous hesitez a passer en HP/HC ou si vous voulez voir la différence avoir les tarifs d'un autre fournisseur
## Récupération des données
Deux solutions :
* Depuis le site d'[Enedis](https://mon-compte-particulier.enedis.fr/suivi-de-mesures/), vous pourrez choisir votre plage ainsi que la périodicité. Si vous utilisez les HP/HC, il faudra activer et choisir l'historisation horaire. L'export peut prendre plusieurs jours avant d'être disponible, et n'oubliez pas de supprimer les 2 premiers lignes de l'export
* Un fichier csv maison à construire sous la forme `Horodate;Valeur`

## Configuration du script
Ouvrir le fichier `compare.ps1` et remplir l'encart des variables avec vos données

## Utilisation du script
`file` : Nom du fichier où récupérer les données

`hphc` : Spécifie que vous souhaitez utiliser les heures creuses

`month` : Spéficie les mois sur lesquels vous voulez une estimation du coût

## Exemple
Calcul de la conso pour les mois de mai et juin en HP/HC
```
.\compare.ps1 -file .
\Enedis_Conso_Heure_20210801-20220806_01445007189250.csv -month "05-06" -hphc
output:
Cout Conso : 79.15€
Cout Abonnement : 19.36€
Cout Total 98.51€
```
## A Venir
Export des infos en graphiques
