class TerminalManager:
    """
    Clase para gestionar la apertura de terminales y la conexión a contenedores Docker.
    """
    @staticmethod
    def open_terminal(self, command: str = None):
        """
        Open a terminal and runs a command if provided.
        """
        import os
        import subprocess

        # Configurar el comando base según el sistema operativo
        if os.name == 'nt':
            terminal_cmd = ['start', 'powershell.exe', '-NoLogo', '-NoExit']
        else:
            # Detectar el terminal disponible en sistemas Unix
            if os.path.exists('/usr/bin/gnome-terminal'):
                terminal_cmd = ['gnome-terminal', '--']
            elif os.path.exists('/usr/bin/xterm'):
                terminal_cmd = ['xterm', '-e']
            else:
                terminal_cmd = ['x-terminal-emulator', '-e']

        # Abrir las terminales y ejecutar docker attach para cada contenedor
        cmd = terminal_cmd.copy()
        
        if command:
            if os.name == 'nt':
                # En Windows, añadir el comando y mantener la terminal abierta
                cmd.extend(['-Command', command])
            else:
                # En Unix, el comando se ejecuta y mantiene la terminal abierta
                cmd.extend(['bash', '-c', command])
        
        # Usar subprocess.Popen para no bloquear mientras se abren las terminales
        if os.name == 'nt':
            subprocess.Popen(cmd, shell=True)
        else:
            subprocess.Popen(cmd)