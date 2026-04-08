#=  Ce fichier contient les methodes de path finding appelable par l'utilisateur
    Ecrit par Gomes Lana 
=# 

include("code/manip.jl")
include("code/bfs.jl")
include("code/dijkstra.jl")
include("code/astar.jl")
include("code/glouton.jl")

# Fonction résolvant le problème avec la méthode BFS
function algoBFS(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    t = time()
    map = parseFichierMap("data/" * fname)
    ((trajet, dist), nb_bfs) = algo_BFS(map,D, A)
    
    println("Starting situation :")
    aff_map(da(map, D, A))
    println("\nBFS algorithm :")
    (res, path) = aff_trajet(map, trajet, D, A)
    
    if trajet != []
        aff_map(res)
        println("Distance D -> A : ", dist)
    end
        println("Number of states evaluated : ", nb_bfs, "\nPath D -> A : ")
        println(path)
        println(" CPUtime (s) : ", time() - t)
end

# Fonction résolvant le problème avec la méthode Dijkstra
function algoDijkstra(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    t = time()
    map = parseFichierMap("data/" * fname)
    ((trajet, dist), nb_dij) = algo_dij(map,D,A)
    
    println("Starting situation :")
    aff_map(da(map, D, A))
    println("Dijkstra algorithm :")
    (res, path) = aff_trajet(map, trajet, D, A)

    if trajet != [] 
        aff_map(res)
        println("Distance D -> A : ", dist, " ", size(trajet,1))
    end
    print("Number of states evaluated : ", nb_dij, "\nPath D -> A : ")
    println(path)
    println(" CPUtime (s) : ", time() - t)
end

# Fonction résolvant le problème avec la méthode A*
function algoAStar(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    t = time()
    map = parseFichierMap("data/" * fname)
    ((trajet, dist), nb_astar) = algo_AStar(map,D,A)
    
    println("Starting situation :")
    aff_map(da(map, D, A))
    println("A* algorithm :")
    (res , path) = aff_trajet(map, trajet, D, A)
        
    if trajet != [] 
        aff_map(res)
        println("Distance D -> A : ", dist)
    end
    print("Number of states evaluated : ", nb_astar, "\nPath D -> A : ")
    println(path)
    println(" CPUtime (s) : ", time() - t)
end

# Fonction résolvant le problème avec la méthode Glouton
function algoGlouton(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    t = time()
    map = parseFichierMap("data/" * fname)
    ((trajet, dist), nb_glouton) = algo_glouton(map,D,A)
    
    println("Starting situation :")
    aff_map(da(map, D, A))
    println("\nGlouton algorithm :")
    (res, path) = aff_trajet(map, trajet, D, A)

    if trajet != []
        aff_map(res)
        println("Distance D -> A : ", dist)
    end
    print("Number of states evaluated : ", nb_glouton, "\nPath D -> A : ")
    println(path)
    println(" CPUtime (s) : ", time() - t)
end