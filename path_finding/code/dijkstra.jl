#=  Ce fichier contient les méthodes afin de rechercher le plus cours chemin selon la méthode Dijkstra
    Ecrit par Lana GOMES
=# 

# Permet d'accéder à toutes les méthodes communes aux recherches du plus court chemin 
include("manip.jl")

# Fonction principale du fichier directement appelé du main.jl 
function algo_dij(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64})
    # Si le départ et l'arrivée sont les mêmes, on s'arrête
    if dep == arr 
        return ([dep], 0), 1 
    end
    distance, cameFrom, nb_dij = parcours_dij(map,dep,arr)
    if distance[arr[1], arr[2]] != -1
        return (chemin_dij(dep, arr, cameFrom), distance[arr[1], arr[2]],distance[arr[1], arr[2]]), nb_dij
    end
    return (Vector{Tuple{Int64,Int64}}(undef,0), -1), nb_dij
end

# Fonction implémentant la logique indiqué dans le fichier plutoL3.pdf 
function parcours_dij(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64})
    # Permet de compter le nombre de cases analysées 
    nb_dij = 0
    # Adaptation où L ne stocke que les non permanant 
    L_n_perm::Vector{Tuple{Int64,Int64}} = []
    # Matrice indiquant la distance de la case (i,j) par rapport au départ 
    distance::Matrix{Int64} = Matrix{Int64}(undef,size(map))
    #  Matrice indiquant d'où la case (i,j) a été atteinte avec la meilleure distance
    cameFrom::Matrix{Tuple{Int64,Int64}} = Matrix{Tuple{Int64,Int64}}(undef,size(map))
    # Matrice indiquant de manière simple si la case (i,j) est permanante 
    permanant::Matrix{Bool} = Matrix{Bool}(undef,size(map))
    
    # Initialisation des variables 
    for i in 1:size(map,1), j in 1:size(map,2)
        distance[i,j] = -1
        cameFrom[i,j] = (-1,-1)
        # On ne calculera que les cases qui sont atteignable par leurs statuts 
        if cout(map, (i,j)) != -1
            permanant[i,j] = false
            
        else 
           permanant[i,j] = true
        end
        push!(L_n_perm,(i,j)) 
    end
    distance[dep[1],dep[2]] = 0
    
    while size(L_n_perm,1) != 0
        u = plus_proche_sommet_non_permanant_L(map, L_n_perm, distance) 
        permanant[u[1], u[2]] = true 
        L_n_perm = enlever(L_n_perm, u)
        nb_dij = nb_dij + 1
        # Si c'est l'arrrivée on retourne ce qu'on a besoin
        if u == arr
            return distance, cameFrom, nb_dij
        end
        S = succ_non_permanant_L(map,permanant,u)
        # Pour chaque voisin s non permanant de u
        for v in S
            distance_avant = distance[v[1], v[2]]
            # Si  il n'a pas de distance, on la lui calcule
            if distance[v[1], v[2]] == -1
                distance[v[1], v[2]] = distance[u[1], u[2]] +  cout(map, v)
            else
            # Sinon on prend la meilleure distance
                distance[v[1], v[2]] = min( distance[v[1], v[2]],
                                            distance[u[1], u[2]] +  cout(map, v))
            end
            # Si la distance a été mis à jour, on change aussi d'où l'on vient 
            if distance[v[1], v[2]] != distance_avant
                cameFrom[v[1], v[2]] = u
            end
        end
    end
    return distance, cameFrom, nb_dij
end

#= Fonction permettant de retracer l'un des trajets possibles à partir d'une matrice cameFrom
     et calcule la distance du trajet 
=# 
function chemin_dij(dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64}, cameFrom::Matrix{Tuple{Int64,Int64}})
    trajet::Vector{Tuple{Int64,Int64}}  = [arr]  
    u = cameFrom[arr[1], arr[2]]
    while u != dep
        trajet = push!(trajet, u)
        u = cameFrom[u[1], u[2]]
    end
    trajet = push!(trajet, u)
    return trajet
end

#   Fonction permettant de trouver la liste des voisins de u qui sont permanant 
function succ_non_permanant_L(map::Matrix{Char}, permanant::Matrix{Bool}, u::Tuple{Int64,Int64})
    S = successeur(map, u) 
    res::Vector{Tuple{Int64,Int64}} = []  
    for s in S
        if !permanant[s[1], s[2]] 
            push!(res,s)
        end
    end
    return res
end

#   Fonction cherchant le plus proche sommet du départ non permanant
function plus_proche_sommet_non_permanant_L(map::Matrix{Char}, L_n_perm::Vector{Tuple{Int64,Int64}}, distance::Matrix{Int64})
    min = L_n_perm[1] 
    for u in L_n_perm 
        if (((distance[u[1], u[2]] < distance[min[1], min[2]] )
            || distance[min[1], min[2]] == - 1)
            && (distance[u[1], u[2]] != -1 ))
            min = u
        end
    end
    return min
end  

#   Fonction permettant d'enlever une valeur dans un tableau
function enlever(L_n_perm::Vector{Tuple{Int64,Int64}}, u::Tuple{Int64,Int64})
    i = 1
    while (i <= size(L_n_perm,1)) && (L_n_perm[i] != u)
        i = i + 1
    end
    if i <= size(L_n_perm,1) && (L_n_perm[i] == u )
        deleteat!(L_n_perm, i)
    end
    return L_n_perm
end

# Fonction permettant d'afficher la matrice cameFrom pour des vérifications et tests
function aff_cameFrom(t::Matrix{Tuple{Int64,Int64}})
    println(" ")
    for i in 1:size(t,1)
        for j in 1:size(t,2)
            if t[i,j] != (-1,-1) 
                print(t[i,j], " ")
            else 
                print("  .  ")
            end
        end
        print("\n")
    end
end
            