#=  Ce fichier contient une fonction permettant d'enregistrer le chemin dans un fichier txt
    Ecrit par Gomes Lana 
=# 
function create(nom, map)
    open(nom, "w") do io
        for i in 1:size(map,1)
            for j in 1:size(map,2)
                if j < size(map,2)
                    print(io,map[i,j])
                else 
                    print(io,map[i,j], "\n")
                end
            end
        end
    end
end