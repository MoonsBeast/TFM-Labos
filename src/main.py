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
    path: str = typer.Option("./lab_build", help="Path to the lab folder"),
    images: list[str] = typer.Option(None, "--image", "-i", help="Images to to attach to the terminal")
):
    """
    Open multiple terminal windows and connect to the images.
    """
    import os
    import subprocess
    from Yalm_handler import Yalm_handler as YML
    from pathlib import Path

    # Get container names from docker-compose.yml
    compose_path = Path(path) / "docker-compose.yml"
    if not compose_path.exists():
        typer.echo(f"Error: docker-compose.yml not found in {path}")
        return

    compose_data = YML.read(str(compose_path))
    if not compose_data or 'services' not in compose_data:
        typer.echo("Error: Invalid docker-compose.yml file")
        return

    # Get container names for selected images or all services if no images specified
    container_names = []
    for service_name, service_data in compose_data['services'].items():
        if images is None or any(img in service_name.lower() for img in images):
            if 'container_name' in service_data:
                container_names.append(service_data['container_name'])

    if not container_names:
        typer.echo("No matching containers found")
        return

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
    for container_name in container_names:
        cmd = terminal_cmd.copy()
        docker_cmd = f"docker attach {container_name}"
        
        if os.name == 'nt':
            # En Windows, añadir el comando y mantener la terminal abierta
            cmd.extend(['-Command', docker_cmd])
        else:
            # En Unix, el comando se ejecuta y mantiene la terminal abierta
            cmd.extend(['bash', '-c', docker_cmd])
        
        # Usar subprocess.Popen para no bloquear mientras se abren las terminales
        if os.name == 'nt':
            subprocess.Popen(cmd, shell=True)
        else:
            subprocess.Popen(cmd)

if __name__ == "__main__":
    app()