#=
    [] : pas de disponibilité
    [(1,-1)]  : disponibilité tout le temps
    [...(x, -1)] : intervalle jusqu'à l'infini
=#

include("manip.jl")

Inter = Vector{Tuple{Int64,Int64}}

struct Config 
    state::Tuple{Int64,Int64}
    t::Int64
    interv::Tuple{Int64,Int64}
end

struct CFG 
    state::Tuple{Int64,Int64}
    interv::Tuple{Int64,Int64}
end

struct Consigne_AMR
    dep
    arr
    date_depart
end

function create_intervalle(map)
    intervalles = Matrix{Inter}(undef,size(map,1),size(map,2))
    for i in 1:size(map,1)
        for j in 1:size(map,2)
            if cout(map,(i,j)) != -1
                intervalles[i,j] = [(1,-1)]
            else
                intervalles[i,j] = []
            end
        end
    end
    return intervalles
end

function change_inter(interv, time_moins, time_plus)
    res = []
    for safe in interv
        # Si time_moins <= le bord gauche, mais pas le bord droit
        # Si time_plus >= le bord droit, mais pas le bord gauche
        # Si (time_moins, time_plus) dans
        if (time_plus < safe[1]) || ((time_moins > safe[2]) && (safe[2] != -1))
            push!(res, safe)
        elseif (time_moins <= safe[1]) && ((time_plus < safe[2]) || (safe[2] == -1))
            push!(res, (time_plus + 1, safe[2]))
        elseif (time_moins > safe[1]) && ((time_plus >= safe[2]) && (safe[2] != -1))
            push!(res, (safe[1], time_moins - 1))
        elseif (time_moins > safe[1]) && ((time_plus < safe[2]) || (safe[2] == -1))
            push!(res, (safe[1], time_moins - 1))
            push!(res, (time_plus + 1, safe[2]))
        end
    end
    return res
end

function add_amr(intervalles, amr)
    for i in 1:(size(amr,1)-1)
        intervalles[amr[i].state[1],amr[i].state[2]] = change_inter(intervalles[amr[i].state[1],amr[i].state[2]], amr[i].t, amr[i + 1].t - 1)
    end
    intervalles[amr[size(amr,1)].state[1], amr[size(amr,1)].state[2]] = change_inter(intervalles[amr[size(amr,1)].state[1], amr[size(amr,1)].state[2]], amr[size(amr,1)].t , amr[size(amr,1)].t)
    return intervalles
end

function check_possible(intervalles::Matrix{Inter}, pos, time)
    interv = intervalles[pos[1],pos[2]]
    for inter in interv
        if inter[1] <= time && (inter[2] >= time || inter[2] == -1)
            return inter
        end
    end
    return (0, 0)
end

function filtre(S, current, amrs)
    for amr in amrs
        if amr[current.interv[2] + 1] == current.state
            return filter(x->x.state!=amr[current.interv[2]], S)
        end
    end
    return S
end

function successors_time(map,current, intervalles, amrs)
    S = []
    for s in successeur(map, current.state)
        start_t = current.t + 1
        end_t = current.interv[2] + 1
        for safe in intervalles[s[1],s[2]]
            # Si on peut finir la tache après le début de l'intervalle
            # Si on peut finir la tache avant la fin de l'intervalle
            if safe[1] > end_t || safe[2] < start_t
                time = max(start_t, safe[1])
                inter = check_possible(intervalles, s, time)
                if inter != (0,0)
                    cfg = Config(s,time, safe)
                    push!(S, cfg)
                end
                if time - 1 == current.interv[2]
                    S = filtre(S, current, amrs)
                end
            end
        end
    end 
    return S
end

function affiche_chemin(map, amrs)
    map_dessin = copy(map)
    indices::Vector{Int64} = ones(Int64, size(amrs))
    t = 1
    not_end = true
    while not_end
        not_end = false
        for i in 1:size(amrs,1)
            amr = amrs[i]
            if (indices[i] != -1) && indices[i] <= size(amr,1) - 1
                not_end = true
                if amr[indices[i] + 1].t >= t && !(amr[indices[i]].t > t)
                    map_dessin[amr[indices[i]].state[1],amr[indices[i]].state[2]] = "$(Char(96 + i))"[1]
                    if amr[indices[i] + 1].t == t + 1
                        indices[i] = indices[i] + 1
                    end
                end
            elseif (indices[i] != -1)
                map_dessin[amr[indices[i]].state[1],amr[indices[i]].state[2]] = "$(Char(96 + i))"[1]
                indices[i] = - 1
            end
        end
        println("Time : $t")
        aff_map(map_dessin)
        map_dessin = copy(map)
        t = t + 1
    end
end

function parseConsigne(nomFichier::String)
    # Ouverture d'un fichier en lecture
    f::IOStream = open(nomFichier,"r")

    # Lecture des premières lignes pour extraire les hauteurs et largeurs
    s::String = readline(f) # lecture d'une ligne et stockage dans une chaîne de caractères
    nb_amrs = conv_String_Int(s)
    c_amrs = []

    # Recopie les élèments du fichier .map dans la matrice map
    for i in 1:nb_amrs
        s = readline(f)
        m = match(r"\((?<dep_1>\d+),(?<dep_2>\d+)\)->\((?<arr_1>\d+),(?<arr_2>\d+)\),t=(?<time>\d+)",s)
        dep_1 = conv_String_Int(String(m[:dep_1]))
        dep_2 = conv_String_Int(String(m[:dep_2]))
        arr_1 = conv_String_Int(String(m[:arr_1]))
        arr_2 = conv_String_Int(String(m[:arr_2]))
        time = conv_String_Int(String(m[:time]))
        push!(c_amrs, Consigne_AMR((dep_1,dep_2), (arr_1,arr_2), time))
    end

    # Fermeture du fichier
    close(f)
    return c_amrs
end