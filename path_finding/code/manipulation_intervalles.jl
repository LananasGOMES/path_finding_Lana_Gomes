#=  Ce fichier contient les méthodes pour manipuler des intervalles, configurations et etats
    Inspiré du document SSIP mis en ligne sur MADOC    
    Ecrit par Lana GOMES
=# 

include("manip.jl")

# Suite_Inter représente une suite d'intervalles de disponibilité d'une case
    # [] : pas de disponibilité
    # [(1,-1)]  : disponibilité tout le temps
    # [...(x, -1)] : intervalle jusqu'à l'infini
    # -1 agit comme une borne infini comme le temps étant strictement positif dans ce projet
Suite_Inter = Vector{Tuple{Int64,Int64}}

#  Etat représente l'associatation la position d'une case et un intervalle de sureté (aucune colision possible dans cette intervalle)
struct Etat 
    state::Tuple{Int64,Int64}
    interv::Tuple{Int64,Int64}
end

# Config représente l'association d'un Etat et d'un temps t pour lequelle l'état est accéssible à partir du temps t
struct Config 
    state::Tuple{Int64,Int64}
    t::Int64
    interv::Tuple{Int64,Int64}
end

# Consigne_AMR représente les instructions qui doivent être suivis par un AMR son départ, son arrivée et son temps de départ
struct Consigne_AMR
    nom::String
    dep::Tuple{Int64,Int64}
    arr::Tuple{Int64,Int64}
    date_depart::Int64
end

# Fonction permettant de chercher dans un fichier donnés, les consignes d'AMR pour les utiliser dans la suite
function parseConsigne(nomFichierConsigne::String)
    # Ouverture d'un fichier en lecture
    f::IOStream = open(nomFichierConsigne,"r")

    # Lecture des premières lignes pour extraire le nombre d'AMR à prendre
    s::String = readline(f) # lecture d'une ligne et stockage dans une chaîne de caractères
    nb_amrs::Int64 = conv_String_Int(s)
    # c_amrs va stocker toutes les Consigne_AMR afin de les retourner sous un format utilisable par le code du projet
    c_amrs::Vector{Consigne_AMR} = []

    # Recopie les élèments du fichier .map dans la matrice map
    for i in 1:nb_amrs
        s = readline(f)
        # On cherche le patern demandé pour une consigne et on en extrait les informations recherchés:
        # S'il est correcte on l'enregistre, sinon on affiche un message à l'utilisateur
        m = match(r"(?<nom>.*) : \((?<dep_1>\d+),(?<dep_2>\d+)\)->\((?<arr_1>\d+),(?<arr_2>\d+)\),t=(?<time>\d+)",s)
        if typeof(m) == Nothing
            println("Problème de lecture avec la consigne $i. Veuillez utiliser le format demandé.")
        else
            nom = String(m[:nom])
            dep_1 = conv_String_Int(String(m[:dep_1]))
            dep_2 = conv_String_Int(String(m[:dep_2]))
            arr_1 = conv_String_Int(String(m[:arr_1]))
            arr_2 = conv_String_Int(String(m[:arr_2]))
            time = conv_String_Int(String(m[:time]))
            push!(c_amrs, Consigne_AMR(nom, (dep_1,dep_2), (arr_1,arr_2), time))
        end
    end

    # Fermeture du fichier
    close(f)
    # Retour des consignes
    return c_amrs
end

# Fonction permettant de creer une matrice de sureté avec pour seule contrainte : l'accessibilité de la case (mur, ...)
function create_matrice_surete(map:: Matrix{Char})
    matrice_surete::Matrix{Suite_Inter} = Matrix{Suite_Inter}(undef,size(map,1),size(map,2))
    for i in 1:size(map,1)
        for j in 1:size(map,2)
            # Si l'obstacle est pas franchissable
            if cout(map,(i,j)) != -1
                matrice_surete[i,j] = [(1,-1)]
            else
                matrice_surete[i,j] = []
            end
        end
    end
    return matrice_surete
end

# Fonction permettant de changer une suite d'intervalles pour enlever un intervalle précis des disponibilités de la case
function change_inter(prec_interv::Suite_Inter, time_moins::Int64, time_plus::Int64)
    # Représente la nouvelle suite d'intervalle utilisé pour la suite
    new_interv::Suite_Inter = []
    for safe in prec_interv
        # Dans le cas où l'union (time_moins,time_plus) et safe est disjointe
        if (time_plus < safe[1]) || ((time_moins > safe[2]) && (safe[2] != -1))
            push!(new_interv, safe)
        # Dans le cas où (time_moins,time_plus) empiette sur la gauche de safe
        elseif (time_moins <= safe[1]) && ((time_plus < safe[2]) || (safe[2] == -1))
            push!(new_interv, (time_plus + 1, safe[2]))
        # Dans le cas où (time_moins,time_plus) empiette sur la droite de safe
        elseif (time_moins > safe[1]) && ((time_plus >= safe[2]) && (safe[2] != -1))
            push!(new_interv, (safe[1], time_moins - 1))
        # Dans le cas où (time_moins,time_plus) est inclu dans safe
        elseif (time_moins > safe[1]) && ((time_plus < safe[2]) || (safe[2] == -1))
            push!(new_interv, (safe[1], time_moins - 1))
            push!(new_interv, (time_plus + 1, safe[2]))
        end
        # Dans le cas où safe est inclu dans (time_moins, time_plus), safe n'est plus stocké, car plus disponible
    end
    return new_interv
end

# Fonction permettant de mettre à jour la matrice de sureté avec l'ajout du parcours d'un AMR
function add_amr(matrice_surete::Matrix{Suite_Inter}, amr::Vector{Config})
    # Pour chaque présence de l'AMR on met à jour les disponibilités de la case par le temps que l'AMR reste sur cette cas
    for i in 1:(size(amr,1)-1)
        matrice_surete[amr[i].state[1],amr[i].state[2]] = change_inter(matrice_surete[amr[i].state[1],amr[i].state[2]], amr[i].t, amr[i + 1].t - 1)
    end
    # Pour le dernier on ne rend indisponible la case que quand elle est atteinte puis on la rend à nouveau disponible
    matrice_surete[amr[size(amr,1)].state[1], amr[size(amr,1)].state[2]] = change_inter(matrice_surete[amr[size(amr,1)].state[1], amr[size(amr,1)].state[2]], amr[size(amr,1)].t , amr[size(amr,1)].t)
    return matrice_surete
end

# Fonction permettant de savoir l'intervalle de sureté contenant time à la position pos dans la matrice de sureté
function check_possible(matrice_surete::Matrix{Suite_Inter}, pos::Tuple{Int64,Int64}, time::Int64)
    interv::Suite_Inter = matrice_surete[pos[1],pos[2]]
    for inter in interv
        # Si time est inclu dans l'un des intervalles de sureté de la case, on renvoie cette intervalle
        if inter[1] <= time && (inter[2] >= time || inter[2] == -1)
            return inter
        end
    end
    # Dans le cas où la case n'est pas disponible dans au temps donné
    return (0, 0)
end

# Fonction permettant de retirer une position qui ferait intervenir l'échange de positions entre 2 AMR
function filtre(positions::Vector{Config}, current::Config, amrs::Vector{Vector{Config}})
    for amr in amrs
        for i in 1:size(amr,1)
            # Si l'AMR arrive au moment où l'intervalle de sécurité de la configuration courrante finit,
            # On doit empecher l'échange de positions
            if amr[i].t == current.interv[2] + 1
                if i != 1
                    return filter(x->x.state!=amr[i-1], positions)
                # Si l'AMR vient d'arriver sur la map alors, il n'y a pas de soucis
                else
                    return positions
                end
            end
        end
    end
    # Ce cas ne devrait pas arriver car un des AMR arrive sur la case selon les conditions d'appels de cette fonction
    return positions
end

# Fonction permettant de calculer les successeurs en fonction d'une configuration, 
# Inspiré du document SSIP mis en ligne sur MADOC
function successors_time(map::Matrix{Char}, current::Config, matrice_surete::Matrix{Suite_Inter}, amrs::Vector{Vector{Config}})
    successeurs_temporels::Vector{Config} = []
    successeurs_basique::Vector{Tuple{Int64,Int64}} = successeur(map, current.state)
    danger_echange = false
    for s in successeurs_basique
        start_t = current.t + 1
        end_t = current.interv[2] + 1
        for safe in matrice_surete[s[1],s[2]]
            # Si la tâche est réalisable dans safe
            if safe[1] > end_t || safe[2] < start_t
                # On prends le premier temps où le successeur est accessible
                time = max(start_t, safe[1])
                # On recherche l'intervalle de sécurité contenant time pour savoir pendant combien de temps le successeur est possible
                inter = check_possible(matrice_surete, s, time)
                # inter ne devrait jamais valoir (0,0) avec les calculs précédents et le contexte d'utilisation, mais par mesure de précautions
                if inter != (0,0)
                    cfg = Config(s,time, safe)
                    push!(successeurs_temporels, cfg)
                    # Si la case devient inaccessible après que current soit obligé de bouger alors un AMR arrive
                    # Un échange de positions entre current et un des AMR va se produire
                    if danger_echange == false && time - 1 == current.interv[2]
                        danger_echange = true
                    end
                end
            end
        end
    end 
    # S'il y a un échange de positions possible on retire le successeurs
    if danger_echange
        successeurs_temporels = filtre(successeurs_temporels, current, amrs)
    end
    return successeurs_temporels
end

# Fonction permettant de retracer visuellement sur la map à chaque temps t la position de chaque AMR
function affiche_chemin(map::Matrix{Char}, amrs::Vector{Vector{Config}})
    map_dessin = copy(map)
    # Permet de retracer l'avancement dans les configurations des amrs
    indices::Vector{Int64} = ones(Int64, size(amrs))
    # Représente le temps
    t::Int64 = 1
    not_end::Bool = true
    # Tant qu'un AMR n'a pas finit son chemin
    while not_end
        not_end = false
        for i in 1:size(amrs,1)
            amr = amrs[i]
            # Si l'AMR a eu un soucis on ne veut pas l'afficher
            if amr[1].interv == (0,0)
                indices[i] = -1
            end
            # Si on peut continuer mais qu'on est pas encore à l'arrivé
            if (indices[i] != -1) && indices[i] <= size(amr,1) - 1
                not_end = true
                # Si on est encore dans la même configuration
                if amr[indices[i] + 1].t >= t && !(amr[indices[i]].t > t)
                    map_dessin[amr[indices[i]].state[1],amr[indices[i]].state[2]] = "$(Char(96 + i))"[1]
                    # Si on doit changer de configuration au prochain temps
                    if amr[indices[i] + 1].t == t + 1
                        indices[i] = indices[i] + 1
                    end
                end
            # Cas particulier pour la dernière configuration qu'on affiche qu'une seule foiss
            elseif (indices[i] != -1)
                map_dessin[amr[indices[i]].state[1],amr[indices[i]].state[2]] = "$(Char(96 + i))"[1]
                indices[i] = - 1
            end
        end
        println("\nTime : $t")
        aff_map(map_dessin)
        map_dessin = copy(map)
        t = t + 1
    end
end

# Fonction permettant d'afficher le résumé final
function affiche_final(consigne_amrs::Vector{Consigne_AMR}, amrs::Vector{Vector{Config}})
    # Permet d'afficher le bon temps final en cas de succès
    max_temps::Int64 = 0
    tous_reussi::Bool = true
    
    for i in 1:size(amrs,1)
        print("$(consigne_amrs[i].nom)")
        if amrs[i][1].interv != (0,0)
            println(" (symbole = $(Char(96 + i))) : $(size(amrs[i],1)) pas, coût=$(amrs[i][size(amrs[i],1)].t), commence à t=$(consigne_amrs[i].date_depart)")
            if tous_reussi
                max_temps = max(max_temps, amrs[i][size(amrs[i],1)].t)
            end
        elseif amrs[i][1].t == 0
            println(" : La case de départ de la mission $(consigne_amrs[i].nom) est occupé (départ=$(consigne_amrs[i].dep), t=$(consigne_amrs[i].date_depart))")
            tous_reussi = false
        else
            println(" : Chemin impossible entre $(consigne_amrs[i].dep) et $(consigne_amrs[i].arr)")
            tous_reussi = false
        end
    end
    
    if tous_reussi
        println("Tous les AMR ont atteint leur destination (t=$max_temps)")
    end
end