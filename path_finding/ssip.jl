#=  Ce fichier contient les methodes de path finding dépendante du temps par l'utilisateur
    Ecrit par Gomes Lana 
=# 

include("code/astar_time.jl")

# Fonction résolvant le problème avec la méthode SSIP
function ssip(fichier_map::String, fichier_consigne_amrs::String)
    # On charge les données données par l'utilisateurs
    map::Matrix{Char} = parseFichierMap("data/" * fichier_map)
    consigne_amrs::Vector{Consigne_AMR} = parseConsigne("commandes/" * fichier_consigne_amrs)
    sort!(consigne_amrs, by=x->x.date_depart)

    # On créer nos ressources communes à tout les AMRs
    matrice_surete::Matrix{Suite_Inter} = create_matrice_surete(map)
    amrs::Vector{Vector{Config}} = []
    # Pour chaque consigne correctement répétoriée,
    # On calcule le meilleurs chemin, et on met à jour la matrice de sureté
    for c in consigne_amrs
        amr::Vector{Config} = algo_AStar(map, c.dep, c.arr, c.date_depart, matrice_surete, amrs)
        push!(amrs, amr)
        if amr[1].interv != (0,0)
            matrice_surete = add_amr(matrice_surete, amr)
        end
    end 
    # Affichage des résultats
    affiche_chemin(map, amrs)
    affiche_final(consigne_amrs, amrs)
end