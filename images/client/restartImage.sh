#!/bin/bash

# Nombre del contenedor (ajusta esto si cambias el nombre en docker-compose.yml)
CONTAINER_NAME="docker_ubuntu-client_1"

echo "Deteniendo y eliminando el contenedor..."
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

echo "Eliminando imagen asociada..."
IMAGE_ID=$(docker images -q docker_ubuntu-client)
if [ ! -z "$IMAGE_ID" ]; then
    docker rmi -f $IMAGE_ID
fi

echo "Limpiando volúmenes y caché..."
docker system prune -f

#echo "Reconstruyendo y ejecutando el contenedor..."
#cd docker
#docker-compose up --build -d

echo "Proceso completado."
