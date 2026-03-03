#=  Ce fichier contient les methodes de path finding appelable par l'utilisateur
    Ecrit par Gomes Lana 
=# 

include("code/manip.jl")
include("code/bfs.jl")
include("code/dijkstra.jl")
include("code/a*.jl")
include("code/glouton.jl")
include("code/visualisation.jl")

# Fonction résolvant le problème avec la méthode BFS
function algoBFS(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    t = time()
    map = parseFichier("data/" * fname)
    ((trajet, dist), nb_bfs) = algo_BFS(map,D, A)
    
    println("Starting situation :")
    aff_map(da(map, D, A))
    println("\nBFS algorithm :")
    (res, path) = aff_trajet(map, trajet, D, A)
    
    if trajet != []
        aff_map(res)
        println("Distance D -> A : ", dist)
        create("output/" * fname[1:length(fname)-4]*"_$(D)_$(A)_BFS.txt", res)
    end
        println("Number of states evaluated : ", nb_bfs, "\nPath D -> A : ")
        println(path)
        println(" CPUtime (s) : ", time() - t)
end

# Fonction résolvant le problème avec la méthode Dijkstra
function algoDijkstra(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    t = time()
    map = parseFichier("data/" * fname)
    (trajet, dist), nb_dij = algo_dij(map,D,A)
    
    println("Starting situation :")
    aff_map(da(map, D, A))
    println("Dijkstra algorithm :")
    (res, path) = aff_trajet(map, trajet, D, A)

    if trajet != [] 
        aff_map(res)
        println("Distance D -> A : ", dist)
        create("output/" * fname[1:length(fname)-4]*"_$(D)_$(A)_Dijkstra.txt", res)
    end
    print("Number of states evaluated : ", nb_dij, "\nPath D -> A : ")
    println(path)
    println(" CPUtime (s) : ", time() - t)
end

# Fonction résolvant le problème avec la méthode A*
function algoAStar(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    t = time()
    map = parseFichier("data/" * fname)
    ((trajet, dist), nb_astar) = algo_AStar(map,D,A)
    
    println("Starting situation :")
    println("A* algorithm :")
    (res , path) = aff_trajet(map, trajet, D, A)
    aff_map(res)
        
    if trajet != [] 
        aff_map(res)
        println("Distance D -> A : ", dist)
        create("output/" * fname[1:length(fname)-4]*"_$(D)_$(A)_A*.txt", res)
    end
    print("Number of states evaluated : ", nb_astar, "\nPath D -> A : ")
    println(path)
    println(" CPUtime (s) : ", time() - t)
end

# Fonction résolvant le problème avec la méthode Glouton
function algoGlouton(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    t = time()
    map = parseFichier("data/" * fname)
    ((trajet, dist), nb_glouton) = algo_glouton(map,D,A)
    
    println("Starting situation :")
    println("\nGlouton algorithm :")
    (res, path) = aff_trajet(map, trajet, D, A)

    if trajet != []
        aff_map(res)
        println("Distance D -> A : ", dist)
        create("output/" * fname[1:length(fname)-4]*"_$(D)_$(A)_Glouton.txt", res)
    end
    print("Number of states evaluated : ", nb_glouton, "\nPath D -> A : ")
    println(path)
    println(" CPUtime (s) : ", time() - t)
end