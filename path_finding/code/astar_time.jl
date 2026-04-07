using DataStructures

include("manip.jl")
include("intervalles.jl")

function algo_AStar(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64}, date_debut, intervalles, amrs)
    # Si le départ et l'arrivée sont les mêmes, on s'arrête
    cameFrom, config = parcours_AStar(map,dep,arr, date_debut, intervalles, amrs) 
    if config != Config((-1,-1),-1,(-1,0))
        return chemin_AStar(map, dep, config, cameFrom)
    end
end

function parcours_AStar(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64}, date_debut, intervalles, amrs)
    # Indique la liste des (i,j) qu'on doit calculer
    openSet::PriorityQueue{Config, Int64} = PriorityQueue{Tuple{Int64,Int64}, Int64}() 
    # Matrice indiquant d'où la case (i,j) avec la meilleure distance
    cameFrom::Dict{CFG, Tuple{Int64,Config}} = Dict{CFG, Tuple{Int64,Config}}()

    current = Config(dep,date_debut,check_possible(intervalles,dep, date_debut))
    enqueue!(openSet, current, heuristique(current,arr))

    while !(isempty(openSet))
        # On cherche celui qui semble être le plus proche de l'arrivée qu'on doit traité 
        current = dequeue!(openSet)
        # Si c'est l'arrrivée on retourne ce qu'on a besoin
        if current.state == arr
            return cameFrom, current
        end
        
        S = successors_time(map, current, intervalles, amrs)
        # Pour chaque voisins possible de current 
        for s in S
            time, prec = get(cameFrom, CFG(s.state, s.interv), (Inf, Config((-1,-1),-1,(-1,0))))
            if time == Inf || time > s.t
                cameFrom[CFG(s.state,s.interv)] = (s.t,current)
                openSet[s] = s.t + heuristique(s,arr)
            end
        end
    end
    return cameFrom, Config((-1,-1),-1,(-1,0))
end

# Fonction heuristique utilisé pour estimer la distance "à vol d'oiseau" avec l'arrivée
function heuristique(dep, arr::Tuple{Int64,Int64})
    return abs(dep.state[1] - arr[1]) + abs(dep.state[2] - arr[2])
end

function chemin_AStar(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Config, cameFrom)
    trajet = []
    current = arr
    while current.state != dep
        push!(trajet, current)
        current = (cameFrom[CFG(current.state, current.interv)])[2]
    end
    push!(trajet, current)
    return reverse(trajet)
end

# map = parseFichier("data/t.map")
# interv = create_intervalle(map)
# amr1 = algo_AStar(map, (2,1), (2,3), interv, [])
# interv = add_amr(interv, amr1)
# amr2 = algo_AStar(map, (1,2),(3,2), interv, [amr1])
# interv = add_amr(interv,amr2)
# affiche_chemin(map, [amr1,amr2])