import os

def modes(_):
    return ["Compose", "Build", "Compose and Build"]

def images(_):
    path = 'src/images'
    return [nombre for nombre in os.listdir(path) if os.path.isdir(os.path.join(path, nombre))]
