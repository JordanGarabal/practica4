#!/bin/bash

# Comprobación para saber con que usuario entro!!
usuario=$(whoami)
#echo $usuario

#iniciamos a variable para que se vaia incrementando dentro del bucle.
indice=0

# Antes de nada comprobamos que seas root para poder ejecutar el script, sino sale.

if [[ $usuario == "root" ]];
then
    #con el IFS marcamos cual va a ser el delimitador y ponemos el nombre de como se van llamar las variables.
    while IFS=":" read paquete accion ;
    do  
        #Guartamos las variables en vectores.
        Vpaquete[${indice}]=$paquete
        Vaccion[${indice}]=$accion

        #Si en Vaccion la accion es eliminar, elimina el programa
       if [[ ${Vaccion[$indice]} == "remove" || ${Vaccion[$indice]} == "r" ]];
       then
            # contamos las lineas de las rutas de instalación, si es 0 está sin instalar, si es uno esta instaldada.
            borrar=$(whereis ${Vpaquete[$indice]} | grep bin | wc -l)
            if [[ $borrar == 1 ]];
            then
                sudo apt remove ${Vpaquete[$indice]}
                sudo apt purge ${Vpaquete[$indice]}
            fi
        #si la opcion es añadir, mira que no esté instalada previamente.
       elif [[ ${Vaccion[$indice]} == "add" || ${Vaccion[$indice]} == "a" ]];
       then
            #contamos las líneas de la ruta de instalación, si está instalado será mayor que uno.
            instalar=$(whereis ${Vpaquete[$indice]} | grep bin | wc -l)
            if [[ $instalar == 0 ]];
            then
                #como chrome no está en el repositorio de apt, ponemos los comandos para poder instalarlo
                if [[ ${Vpaquete[$indice]} == "google-chrome" ]];
                then 
                    wget -c htttps://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
                    apt-get install libappindicator1
                    sudo dpkg -i google-chrome-stable_current_amd64.deb
                #En caso de atom, ponemos también la forma de instalarlo.
                elif [[ ${Vpaquete[$indice]} == "atom" ]];
                then
                    #los comandos necesarios para atom
                    sudo dpkg -i atom-amd64.deb
                    #con esta comando comprobamos que teña todas as dependencias.
                    sudo apt -f install
                #Gdebi tendría que instalarlo automaticamente, pero a mi no me lo hizo de primeras, por lo que pongo aqui la forma de instalarlo.
                elif [[ ${Vpaquete[$indice]} == "gdebi" ]];
                then
                    #los comandos necesarios gdebi.
                    sudo apt install gdebi
                fi

                sudo apt install -y ${Vpaquete[$indice]}
            fi
       else
            # Facemos a comprobacion de si está instalada para a opcion status. que  sería a que falta.
            whereis ${Vpaquete[$indice]} | grep bin | wc -l
            if [[ $? -eq 0 ]];
            then
                echo "paquete no instalado" ${Vpaquete[$indice]}
            else
                echo "paquete instalado" ${Vpaquete[$indice]}
            fi
       fi
       #para que vaia leendo o fichero imos incrementando a variable indice.
       (( indice++ ))
    done < paquetes.txt 
else
    # Se non eres root  mostrache o seguinte aviso.
    echo "Non tes permisos, USO EXCLUSIVO DE ROOT."
fi

