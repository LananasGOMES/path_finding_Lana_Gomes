#=  Ce fichier contient les méthodes afin de rechercher le plus cours chemin selon la méthode BFS
    Ecrit par Lana GOMES
=# 

# Permet d'utiliser la structure de file
using DataStructures
# Permet d'accéder à toutes les méthodes communes aux recherches du plus court chemin 
include("manip.jl")

# Fonction principale du fichier directement appelé du main.jl 
function algo_BFS(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64})
    # Si le départ et l'arrivée sont les mêmes, on s'arrête 
    if dep == arr 
        return ([dep], 0), 1 
    end
    # On calcule la valeur du plus cours chemin selon la méthode BFS
    marque, nb_bfs = parcours_BFS(map,dep,arr)
    # Si on a pu atteindre l'arrivée 
    if marque[arr[1],arr[2]] != 0
        # On retrace le plus cours chemin 
        return chemin_BFS(map,marque,dep,arr, marque[arr[1],arr[2]]), nb_bfs
    end
    return (Vector{Tuple{Int64,Int64}}(undef,0), -1), nb_bfs
end

# Fonction implémentant la logique indiqué dans le fichier plutoL3.pdf 
function parcours_BFS(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64})
    # Permet de compter le nombre de cases analysées 
    nb_bfs = 0
    F = Queue{Tuple{Int64,Int64}}()
    enqueue!(F, dep)
    # marque indiquera à combien se trouve telle case par rapport au départ - 1, 0 si non évaluée 
    marque = zeros(Int64,size(map))
    vu = Marque = zeros(Int64,size(map))
    # Ces trois variable garentissent les valeurs marqué dans la matrice marque 
    j = 0 # j est un itérateur qui va de 0 à Nj
    Nj = 1 # nombre d'étape avant d'augmenter i 
    suivj = 0 # Nj pour la prochaine étape une fois que j == Nj
    i = 1 # valeur à placer dans marque qui indiquera i - 1 étape par rapprot au départ
    while !(isempty(F))
        u = first(F) 
        dequeue!(F)
        # Si on ne l'a pas  dejà vu on augmente le nombre de cases croisée
        if marque[u[1], u[2]] == 0
            nb_bfs = nb_bfs + 1
        end
        # Si le j == Nj alors on remet les valeurs à jours afin de commencer la prochaine étape 
        if j == Nj
            i = i + 1
            j = 0
            Nj = suivj
            suivj = 0
        end
        marque[u[1],u[2]] = i
        S = successeur(map, u)
        # Pour chaque voisin possible de la case u 
        for s in S
            # Si on ne l'a pas croisé 
            if marque[s[1],s[2]] == 0
                # Si c'est l'arrivée on marque, augmente le nombre de case analysée et on arrête de chercher
                if (s[1] == arr[1]) && (s[2] == arr[2])
                    nb_bfs = nb_bfs + 1
                    marque[arr[1],arr[2]] = i + 1
                    return marque, nb_bfs
                end
                # Optimisation permettant de ne pas rajouter un element qui est déjà à traiter dans les à traiter
                if vu[s[1], s[2]] == 0
                    vu[s[1],s[2]] = 1
                    suivj = suivj + 1
                    enqueue!(F,s)
                end
            end
        end
        j = j + 1
    end
    return marque, nb_bfs
end

#=   Fonction permettant de retracer l'un des trajets possibles à partir du tableau marque
     et calcule la distance du trajet 
=# 
function chemin_BFS(map::Matrix{Char}, marque::Matrix{Int64}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64}, nb::Int64)
    parcours::Vector{Tuple{Int64,Int64}} = Vector{Tuple{Int64,Int64}}(undef,nb)
    parcours[1] = arr
    dist = cout(map, arr)
    S::Vector{Tuple{Int64,Int64}} = []
    for i in 2:nb
        S = successeur(map, parcours[i-1])
        ind = 1
        while ind <= length(S)
            s = S[ind]
            # Pour chaque voisin on cherche un voisin plus proche du départ 
            if marque[s[1],s[2]] == marque[parcours[i-1][1], parcours[i-1][2]] - 1
                parcours[i] = s
                dist = dist + cout(map, s)
                ind = length(S) + 1
            end
            ind = ind + 1
        end
    end
    return parcours, dist - cout(map,dep)
end

# Fonction permettant d'afficher la matrice marque pour des vérifications et tests
function aff_mat(t::Matrix{Int64})
    println(" ")
    for i in 1:size(t,1)
        for j in 1:size(t,2)
            print(t[i,j], " ")
        end
        print("\n")
    end
end