# Path_Finding
 Recherche du plus cours chemin dans le cadre du cours de Xavier Grandibleu Projet d'informatique scientifique par Lana Gomes.

# Organisation
Dans ce dossier se trouve :
 * Un dossier "code" permettant de mettre en place différentes stratégie de path finding
 * Un dossier "data" contenant plusieurs instances de carte en fichier .map
 * Un dossier "doc" contenant le fichier "plutoL3.pdf" listant les différents attendus de ce projet et un rapport contenant la comparaison de trois instance faces aux différentes approches de path finding
 * Un dossier "output" contenant les solutions des instances demandés par l'utilisateur
 * Un fichier README.md, le document que vous être en train de lire
 * Un fichier "main.jl" vous permettant de tester les différentes recherches du plus court chemin

# Utilisation

Une fois dans le dossier "Path_Finding", taper dans votre terminal la commande julia, puis "include("main.jl")"
Une fois la compilation effectuer vous pouver choisir à la fois l'instance que vous voulez tester avec un point de départ et d'arrivé sous cette forme :
algoNom(fname, D, A)

algoNom doit être :
* algoBFS
* algoDijkstra
* algoAStar
* algoGlouton

fname doit être un nom de fichier disponible dans le dossier data par exemple :
* Didactic_0_16.map
* Berlin_0_256.map
Veuillez à bien mettre le nom du fichier avec l'extension et entre guillemet ""

D et A sont des coordonées en 2D entières compris entre 0 et b le nombre le plus à droite du nom - 1 :
* D = (0,11) et A = (1,8) 
* D = (245,11) et A = (1,255)
Il est autorisé de démarrer sur un mur (ou arbre) mais en revanche il n'est pas autorisé d'arriver sur un mur (ou arbre) à moins qu'il s'agissent du départ

Exemple complet :
*algoBFS("Didatic_0.map", (2,11), (1,8))

# Remarque
Vous pouvez vous même créer vos fichier .map dans le dossier data veillez à ce que la forme indiqué soit bien respecté :

type octile
height 16
width 16
map
.......T.......
...............
......@@@@@@@..
............@..
............@..
...SSS......@..
............@..
............@..
............@..
......W.....@..
............@..
.......W....@..
....@@@@@@@@@..
...............
...............

Les quatres premières lignes sont très importantes veillez à bien renseigner height (hauteur) et width (largeur) tel que marqué et dans l'ordre indiqué. Veuillez aussi conserver les lignes "type octile" et "map".
* height et width sont très important car vous ne pouver fixer des coordonnée que entre 1 et height -1 et 1 et width - 1
Ensuite, libre cours à votre imagination tout en respectant bien la hauteur et la largueur renseignées :
* . représente un sol marchable     (cout de 1)
* S représente du sable             (cout de 5)
* W représente de l'eau             (cout de 8)
* T représente un arbre             (infranchissable)
* @ représente un mur               (infranchissable)
* Tout autre symbole que vous rajouterez dans cette liste sera considéré comme infranchissable

# Sortie 

La sortie sera écrite comme telle :

* Une ligne représentant la situation de départ avec le point D (départ) et A (arrivée)
Starting situation :
. . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . 
. . A . . . @ @ @ @ @ @ @ . . 
. . . . . . . . . . . . @ . . 
. . . . . . . . . . . . @ . . 
. . . . . . T . . . . . @ . . 
. . . . . . . . . . . . @ . . 
. . . . . T . . . . . . @ . . 
. . . . . . . . . D . . @ . . 
. . . . . . . . . . . . W . . 
. . . . . . . . . . . . . . . 
. . . . . . . . . . . . @ . . 
. . . . S S S S S S S S S . . 
. . . . . . . T . . . . . . . 
. . . . . . . . . . . . . . . 

* Une ligne précisant le nom de l'algrithme
BFS algorithm :

* Une représentation graphique du chemin sur la map renseignée
. . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . 
. . A       @ @ @ @ @ @ @ . . 
. . . . .           . . @ . . 
. . . . . . . . .   . . @ . . 
. . . . . . T . .   . . @ . . 
. . . . . . . . .   . . @ . . 
. . . . . T . . .   . . @ . . 
. . . . . . . . . D . . @ . . 
. . . . . . . . . . . . W . . 
. . . . . . . . . . . . . . . 
. . . . . . . . . . . . @ . . 
. . . . S S S S S S S S S . . 
. . . . . . . T . . . . . . . 
. . . . . . . . . . . . . . . 
Remarque cette représentation graphique ne sera pas affichée si il y a impossibilité de rejoindre l'arrivée
Bonus : Dans le cas où il existe bien un chemin entre le point D et le point A,
un fichier txt sera enregistrer avec cette map sous le nom du fichier originale, du point D, du point A et du nom de l'algorithme
Exemple : situation3_(9, 10)_(3, 3)_BFS.txt

* Une ligne précisant la distance entre le point D et le point A
Distance D -> A : 13
Remarque cette ligne ne sera pas affiché dans le cas d'une impossibilité de rejoindre l'arrivé que ce soit 
parce que l'arrivée était sur un mur (ou un arbre) ou qu'une barrière les séparaient

* Une ligne avec le nombre de cases évaluées
Number of states evaluated : 161

* Une ligne avec le chemin du point D A
Path D -> A : (9, 10) -> (8, 10) -> (7, 10) -> (6, 10) -> (5, 10) -> (4, 10) -> (4, 9) -> (4, 8) -> (4, 7) -> (4, 6) -> (3, 6) -> (3, 5) -> (3, 4) -> (3, 3)
Remarque cette ligne s'affichera comme telle dans le cas d'une impossibilit de rejoindre l'arrivé
Path D -> A : Il n'y pas de trajet possible

* Une ligne représentant le temps de calculs de l'algorithme
 CPUtime (s) : 0.00790095329284668

