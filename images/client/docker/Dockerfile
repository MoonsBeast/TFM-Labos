FROM ubuntu:latest

# Instalar curl y otros paquetes necesarios
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copiar los scripts desde el directorio superior
COPY ../behavior.sh /usr/local/bin/behavior.sh
COPY ../entrypoint.sh /usr/local/bin/entrypoint.sh

# Dar permisos de ejecución a los scripts
RUN chmod +x /usr/local/bin/behavior.sh /usr/local/bin/entrypoint.sh

# Definir el punto de entrada
ENTRYPOINT ["/usr/local/bin/behavior.sh"]