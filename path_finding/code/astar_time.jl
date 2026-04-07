#=  Ce fichier contient l'adaptation de la méthode A* (dans le fichier astar.jl) avec le temps disponible
    Inspiré du document SSIP mis en ligne sur MADOC   
    Ecrit par Lana GOMES
=# 

using DataStructures

include("manip.jl")
include("manipulation_intervalles.jl")

function algo_AStar(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64}, date_debut::Int64, matrice_surete::Matrix{Suite_Inter}, amrs::Vector{Vector{Config}})
    cameFrom, config = parcours_AStar(map,dep,arr, date_debut, matrice_surete, amrs) 
    # Si on a trouvé un chemin
    if config.interv != (0,0)
        return chemin_AStar(map, dep, config, cameFrom)
    end
    # Sinon on retourne l'erreur observé
    return [config]
end

function parcours_AStar(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64}, date_debut::Int64, matrice_surete::Matrix{Suite_Inter}, amrs::Vector{Vector{Config}})
    # Indique la liste des configuration par ordre d'une heuristique
    openSet::PriorityQueue{Config, Int64} = PriorityQueue{Tuple{Int64,Int64}, Int64}() 
    # Entregistre quel est le meilleur prédécesseur pour arriver à un temps t d'un Etat par un autre atteint au temps t (Config)
    cameFrom::Dict{Etat, Tuple{Int64,Config}} = Dict{Etat, Tuple{Int64,Config}}()

    # On enregistre la première configuration, si l'AMR ne peut pas entrer au temps indiquer, son parcours s'arrête là
    current = Config(dep,date_debut,check_possible(matrice_surete,dep, date_debut))
    if current.interv == (0,0)
        return cameFrom, Config((-1,-1),0,(0,0))
    end

    enqueue!(openSet, current, 0 + heuristique(current,arr))

    while !(isempty(openSet))
        # On cherche celui qui semble être le plus proche de l'arrivée qu'on doit traité 
        # Proximité expliqué par la méthode A*
        current = dequeue!(openSet)
        # Si c'est l'arrrivée on retourne ce qu'on a besoin
        if current.state == arr
            return cameFrom, current
        end
        
        # On prend la liste des successeurs temporelles
        S = successors_time(map, current, matrice_surete, amrs)
        # Pour chaque voisins possible de current 
        for s in S
            time::Int64, prec::Config = get(cameFrom, Etat(s.state, s.interv), (-1, Config((-1,-1),-1,(0,0))))
            # Si le chemin jusqu'à s est meilleur que les autres, ou s'il n'y a pas d'autres
            if time == -1 || time > s.t
                # On enregistre le nouveau maillon du chemin
                cameFrom[Etat(s.state,s.interv)] = (s.t,current)
                openSet[s] = s.t + heuristique(s,arr)
            end
        end
    end
    return cameFrom, Config((-1,-1),-1,(0,0))
end

# Fonction heuristique utilisé pour estimer la distance "à vol d'oiseau" avec l'arrivée
function heuristique(dep::Config, arr::Tuple{Int64,Int64})
    return abs(dep.state[1] - arr[1]) + abs(dep.state[2] - arr[2])
end

# Fonction permettant de retracer le parcours d'un AMR d'une configuration à une autre
function chemin_AStar(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Config, cameFrom)
    trajet::Vector{Config} = []
    current::Config = arr
    # Tant qu'on a pas atteint le départ
    # Bouclerai à l'infini ou planterai dans un autre contexte d'utilisation
    while current.state != dep
        push!(trajet, current)
        current = (cameFrom[Etat(current.state, current.interv)])[2]
    end
    push!(trajet, current)
    return reverse(trajet)
end