# Path_Finding et SSIP
 Recherche du plus cours chemin avec ou sans contrainte de temps,
 dans le cadre du cours de Xavier Gandibleux : Projet d'informatique scientifique 
 Par Lana Gomes.

# Organisation
Dans ce dossier se trouve :
 * Un dossier "code" permettant de mettre en place différentes stratégie de path finding
 * Un dossier "data" contenant plusieurs instances de carte en fichier .map
 * Un dossier "doc" contenant plusieurs fichiers du module sur madoc utile pour le projet
 * Un dossier "commandes" contenant les instructions de départ des AMRs
 * Un fichier README.md, le document que vous être en train de lire
 * Un fichier "main.jl" vous permettant de tester les différentes recherches du plus court chemin

# Utilisation

Une fois dans le dossier "Path_Finding", taper dans votre terminal la commande julia, puis "include("main.jl")" ou "include("ssip.jl)

# Pour un calcul sans importance du temps
Une fois la compilation effectuer vous pouver choisir à la fois l'instance que vous voulez tester avec un point de départ et d'arrivé sous cette forme :
algoNom(fname, D, A)

algoNom doit être :
* algoBFS
* algoDijkstra
* algoAStar
* algoGlouton

fname doit être un nom de fichier disponible dans le dossier data par exemple :
* theglaive.map
* situation2.map
Veuillez à bien mettre le nom du fichier avec l'extension et entre guillemet ""

D et A sont des coordonées en 2D entières compris entre 0 et b le nombre le plus à droite du nom - 1 :
* D = (0,11) et A = (1,8) 
* D = (245,11) et A = (1,255)
Il n'est pas autorisé de démarrer sur un mur (ou arbre) comme il n'est pas autorisé d'arriver sur un mur (ou arbre).

Exemple complet :
* algoAStar("theglaive.map", (189, 193), (226, 437))

# Pour un calcul dépandant du temps

ssip(fname1, fname2)

* fname1 est un fichier .map dans le dossier data
* fname2 est un fichier .txt dans le dossier commandes

# Remarque
Vous pouvez vous même créer vos fichier .map ou .txt dans le dossier data ou commandes, veillez à ce que la forme soit bien respecté 
(similaires aux autres exemples déjà présent dans le dossier data ou commandes)

# Sortie
L'affichage pourra être à la fois une représentation temps par temps (ou dirrectement final) sur la carte, ou une suite de de position indiquant le chemin.
Certaines informations sur le résultat du calcul ou la performance du calcul pourront aussi être affichées.