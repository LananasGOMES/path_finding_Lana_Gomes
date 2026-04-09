#=  Ce fichier contient des fonctions utiles à chaque méthode de path_finding
    Ecrit par Gomes Lana 
    et inspiration du cours de Recherche Operationnelle à l'université de Nantes 
    pour la fonction parseFichierMap à l'aide du fichier SCP.jl
=# 

#=  Fonction qui parse un fichier (au format de l'ORLib) afin d'en extraire une matrice utilisable pour la suite :
    Inspiré par le cours de Recherche Opérationnelle (fichier SCP) et adapté par Lana GOMES 
=#
function parseFichierMap(nomFichier::String)
    # Ouverture d'un fichier en lecture
    f::IOStream = open(nomFichier,"r")

    # Lecture des premières lignes pour extraire les hauteurs et largeurs
    s::String = readline(f) # lecture d'une ligne et stockage dans une chaîne de caractères
    s = readline(f)
    height = conv_String_Int(s[8:length(s)]) - 1
    s = readline(f)
    width = conv_String_Int(s[7:length(s)]) - 1
    s = readline(f)

    # Allocation mémoire pour la matrice de caractère
    map::Matrix{Char} = Matrix{Char}(undef,height,width)
    
    # Recopie les élèments du fichier .map dans la matrice map
    for i in 1:height
        s = readline(f)
        for j in 1:width
            map[i,j] = s[j]    
        end
    end

    # Fermeture du fichier
    close(f)

    return map
end

#   Fonction permettant d'afficher une matrice
function aff_map(map::Matrix{Char})
    for i in 1:size(map,1)
        s = ""
        for j in 1:size(map,2)
            print(map[i,j]," ")
        end
        println("")
    end
end


#=  Fonction de convertir une chaine de caractaire avec des entier en nombre
    renvoie un ArgumentError: invalid base 10 digit 'caractère'
    si vous n'avez pas renseigné un nombre dans le fichier .map pour la hauteur et la largeur
 =# 
function conv_String_Int(str::String)
    nb = 0
    puissance = 1
    for i in length(str):-1:1
        nb = nb + parse(Int64,str[i])*puissance 
        puissance = puissance * 10    
    end
    return nb
end

#   Fonction qui modifie la matrice map pour afficher les points de départ et d'arrivé
function da(map::Matrix{Char}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64})
    map[dep[1], dep[2]] = 'D'
    map[arr[1], arr[2]] = 'A'
    return map
end

#   Fonction permettant d'obtenir la liste des voisins possibles dans un ordre défini dans le fichier plutoL3.pdf 
function successeur(map::Matrix{Char}, u::Tuple{Int64,Int64})
    S::Vector{Tuple{Int64,Int64}} = []
    # Voisin du haut
    if (u[1] - 1 >= 1) && (cout(map,(u[1] - 1, u[2])) != -1)
        push!(S, (u[1] - 1, u[2]))
    end
    # Voisin de droite
    if (u[2] + 1 <= size(map,2)) && (cout(map,(u[1], u[2] + 1)) != -1)
        push!(S, ((u[1], u[2] + 1)))
    end
    # Voisin du bas 
    if (u[1] + 1 <= size(map,1)) && (cout(map,(u[1] + 1, u[2])) != -1)
        push!(S, ((u[1] + 1, u[2])))
    end
    # Voisin de gauche 
    if (u[2] - 1 >= 1) && (cout(map,(u[1], u[2] - 1)) != -1)
        push!(S, ((u[1], u[2] - 1)))
    end

    return S
end

#   Fonction retournant le coup d'une case sur une map précisée
function cout(map::Matrix{Char},u::Tuple{Int64,Int64})
    if map[u[1], u[2]] == '.' # Si c'est un terrain normal 
        return 1
    elseif map[u[1], u[2]] == 'S' # Si c'est du sable 
        return 5
    elseif map[u[1], u[2]] == 'W' # Si c'est de l'eau 
        return 8
    end
    return -1 # Si c'est autre chose non-franchissable comme un mur '@' ou un arbre 'T' 
end

# Fonction permettant d'enlever un élèment d'une liste sans son indice
function enlever(L_n_perm, u)
    i = 1
    while (i <= size(L_n_perm,1)) && (L_n_perm[i] != u)
        i = i + 1
    end
    if i <= size(L_n_perm,1) && (L_n_perm[i] == u )
        deleteat!(L_n_perm, i)
    end
    return L_n_perm
end



#=  Fonction qui affiche un trajet à la fois comme une suite 
    mais aussi le chemin représenté par des espaces ' ' sur la map
    Affiche si le trajet n'est pas possible si le trajet est vide
=# 
function aff_trajet(map::Matrix{Char}, trajet::Vector{Tuple{Int64,Int64}}, dep::Tuple{Int64,Int64}, arr::Tuple{Int64,Int64})
    aff::String = ""
    if trajet == []
        return [],"Il n'y pas de trajet possible"
    else   
        for i in (size(trajet)[1]):(-1):2
            aff = aff * "$(trajet[i])" * " -> "
            map[trajet[i][1], trajet[i][2]] = ' ' 
        end
        map[trajet[1][1], trajet[1][2]] = ' '
        aff = aff * "$(trajet[1])"
        map = da(map, dep, arr)
        return map, aff
    end
end