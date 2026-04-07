include("astar_time.jl")

function ssip(fichier_map, fichier_consigne_amrs)
    map = parseFichier("data/" * fichier_map)
    consigne_amrs = parseConsigne("commandes/" * fichier_consigne_amrs)
    interv = create_intervalle(map)
    amrs = []
    for c in consigne_amrs
        amr = algo_AStar(map, c.dep, c.arr, c.date_depart, interv, amrs)
        push!(amrs, amr)
        interv = add_amr(interv, amr)
    end 
    affiche_chemin(map, amrs)
end

# c_amr1 = Consigne_AMR((2,1), (2,3), 2)
# c_amr2 = Consigne_AMR((1,2), (3,2), 1)

# ssip("t.map", [c_amr1, c_amr2])