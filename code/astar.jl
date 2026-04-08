#=  Ce fichier contient les méthodes afin de rechercher le plus cours chemin selon la méthode A*
    Ecrit par Lana GOMES
=# 

# Permet d'utiliser la structure de file
using DataStructures
# Permet d'accéder à toutes les méthodes communes aux recherches du plus court chemin
include("manip.jl")

# Fonction principale du fichier directement appelé du main.jl 
function algo_AStar(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64})
    # Si le départ et l'arrivée sont les mêmes, on s'arrête
    if dep == arr 
        return ([dep], 0), 1 
    end
    cameFrom, nb_astar = parcours_AStar(map,dep,arr) 
    if cameFrom[arr[1], arr[2]] != (-1,-1)
        return chemin_AStar(map, dep, arr, cameFrom), nb_astar
    end
    return (Vector{Tuple{Int64,Int64}}(undef,0), -1), nb_astar
end

#=  Fonction implémentant une fonction très proche de la vidéo mise en ligne sur madoc
    https://www.youtube.com/watch?v=aKYlikFAV4k =# 
function parcours_AStar(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64})
    # Permet de compter le nombre de cases analysées 
    nb_astar = 0
    # Indique la liste des (i,j) qu'on doit calculer
    openSet::PriorityQueue{Tuple{Int64,Int64}, Int64} = PriorityQueue{Tuple{Int64,Int64}, Int64}() 
    # Matrice indiquant d'où la case (i,j) avec la meilleure distance
    cameFrom::Matrix{Tuple{Int64, Int64}} = Matrix{Tuple{Int64, Int64}}(undef, size(map,1), size(map,2))
    # Matrice indiquant la distance de la case (i,j) par rapport au départ 
    gScore::Matrix{Int64} = Matrix{Int64}(undef, size(map,1), size(map,2))
    # Matrice indiquant une estimation de la distance de la case (i,j) par rapport aà l'arrivé
    fScore::Matrix{Int64} = Matrix{Int64}(undef, size(map,1), size(map,2))
    # Matrice permettant de retrouver si la case est dans le openSet ou le closeSet
    # La case vaut 1 si elle est dans le openSet, -1 si elle est dans le closeSet, 0 sinon
    inWich::Matrix{Int64} = zeros(Int64,size(map))

    # Initialisation des variables 
    for i in 1:size(map,1)
        for j in 1:size(map,2)
            cameFrom[i,j] = (-1,-1)
            gScore[i,j] = -1
            fScore[i,j] = -1  
        end
    end
    inWich[dep[1],dep[2]] = 1
    gScore[dep[1], dep[2]] = 0
    fScore[dep[1], dep[2]] = heuristique(dep,arr)
    enqueue!(openSet, dep, fScore[dep[1],dep[2]])
    nb_astar = nb_astar + 1

    while !(isempty(openSet))
        # On cherche celui qui semble être le plus proche de l'arrivée qu'on doit traité 
        current = dequeue!(openSet)
        nb_astar = nb_astar + 1
        # Si c'est l'arrrivée on retourne ce qu'on a besoin
        if current == arr
            return cameFrom, nb_astar
        end
        inWich[current[1],current[2]] = -1
        S = successeur(map,current)
        # Pour chaque voisins possible de current 
        for s in S
            # Si il n'est pas dans la liste des traités, on met à jour son estimation de distance de l'arrivée
            if inWich[s[1],s[2]] != -1
                tentative_gScore = gScore[current[1], current[2]] + cout(map,current)
                # S'il n'est pas dans la liste à traité on le rajoute 
                if inWich[s[1],s[2]] != 1
                    enqueue!(openSet, s, tentative_gScore + heuristique(current, arr))
                    inWich[s[1],s[2]] = 1
                end
                # Si l'estimation de la distance avec l'arrivée + la distance réeele avec le départ est meilleure on change de chemin
                if (tentative_gScore < gScore[s[1], s[2]]) || (gScore[s[1], s[2]] == -1)
                    cameFrom[s[1], s[2]] = current
                    gScore[s[1], s[2]] = tentative_gScore
                    fScore[s[1], s[2]] = tentative_gScore + heuristique(current,arr)  
                    openSet[s] = fScore[s[1],s[2]]  
                end
            end
        end
    end
    return cameFrom, nb_astar
end  

#= Fonction permettant de retracer l'un des trajets possibles à partir d'une matrice cameFrom
     et calcule la distance du trajet 
=# 
function chemin_AStar(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64}, cameFrom::Matrix{Tuple{Int64,Int64}})
    trajet::Vector{Tuple{Int64,Int64}}  = [arr] 
    dist = cout(map,arr) 
    u = cameFrom[arr[1], arr[2]]
    while u != dep
        dist = dist + cout(map,u)
        trajet = push!(trajet, u)
        u = cameFrom[u[1], u[2]]
    end
    trajet = push!(trajet, u)
    return trajet, dist
end

# Fonction heuristique utilisé pour estimer la distance "à vol d'oiseau" avec l'arrivée
function heuristique(dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64})
    return abs(dep[1] - arr[1]) + abs(dep[2] - arr[2])
end

# Recherche le plus petit fScore dans les "à traité"
function lowest_fScore(openSet::Vector{Tuple{Int64,Int64}},fScore::Matrix{Int64})
    min = -1
    min_t = openSet[1]  
    for t in openSet
        if fScore[t[1], t[2]] < min || min == -1
            min = fScore[t[1], t[2]]
            min_t = t
        end 
    end
    return min_t
end
