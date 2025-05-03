import os
from Conductor import Mode

def modes(_):
    return [mode.value for mode in Mode]

def images(_):
    path = 'src/images'
    return [nombre for nombre in os.listdir(path) if os.path.isdir(os.path.join(path, nombre))]
