#!/usr/bin/python
import typer
from Conductor import ExecInfo, Conductor

app = typer.Typer()

@app.command()
def cli():

    """
    Configure the execution mode and images to use.
    This function will prompt the user to select the execution mode and images to use and templates.
    """

    import Inq_Questions
    from InquirerPy import inquirer

    info = ExecInfo()
    while True:
        info.mode = inquirer.select(
            message="Select execution mode:",
            choices=Inq_Questions.modes,
            cycle=False,
            transformer=lambda result: f"{result} mode selected."
        ).execute()

        info.images = inquirer.fuzzy(
            message="Select images to use:",
            choices=Inq_Questions.images,
            multiselect=True,
            validate=lambda result: len(result) > 0,
            invalid_message="Choose at least 1",
            transformer=lambda result: f"Images selected: {', '.join(result)}"
        ).execute()

        while True:
            add_template = inquirer.confirm(
                message="Want to add a template?",
                default=False
            ).execute()
            
            typer.echo(f"Templates: {info.templates}")

            if not add_template:
                break
                
            key = inquirer.text(
                message="Key:",
                validate=lambda x: len(x) > 0,
                invalid_message="Key cannot be empty"
            ).execute()
            
            value = inquirer.text(
                message="Value:",
                validate=lambda x: len(x) > 0,
                invalid_message="Value cannot be empty"
            ).execute()
            
            info.templates[key] = value

        proceed = inquirer.confirm(message="Proceed?", default=True).execute()

        if proceed: break
    
    conductor = Conductor(info=info)
    conductor.process()

@app.command()
def file(path: str =typer.Option("./images.yml", help="Path to the YAML file")):
    """
    Runs based on the YAML config file provided or the default value.
    """
    conductor = Conductor()
    conductor.read_yaml()
    conductor.process()


@app.command()
def gui(
    num_terminals: int = typer.Option(1, "--terminals", "-t", help="Número de terminales a crear"),
    commands: list[str] = typer.Option(None, "--commands", "-c", help="Comandos a ejecutar en cada terminal")
):
    """
    Open multiple terminal windows and connect to the images.
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

    # Abrir las terminales y ejecutar los comandos
    for i in range(num_terminals):
        cmd = terminal_cmd.copy()
        
        if commands and commands[i]:
            if os.name == 'nt':
                # En Windows, añadir el comando y mantener la terminal abierta
                final_command = f"{commands[i]}; clear"
                cmd.extend(['-Command', final_command])
            else:
                # En Unix, el comando se ejecuta y mantiene la terminal abierta
                final_command = f"{commands[i]}; clear"
                cmd.extend(['bash', '-c', final_command])
        else:
            # Si no hay comando, asegurar que la terminal permanezca abierta
            if os.name != 'nt':  # En Windows, -NoExit ya mantiene la terminal abierta
                cmd.extend(['bash'])
        
        # Usar subprocess.Popen para no bloquear mientras se abren las terminales
        if os.name == 'nt':
            subprocess.Popen(cmd, shell=True)
        else:
            subprocess.Popen(cmd)

if __name__ == "__main__":
    app()