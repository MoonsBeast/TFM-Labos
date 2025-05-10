#!/usr/bin/python
import typer
from Yalm_handler import Yalm_handler as YML
import os
import platform
import subprocess

class ExecInfo:
    def __init__(self, data:dict={}):
        
        if data != {}:
            self.containers = data["images"]
            self.templates = data["templates"]
        else:
            self.containers = []
            self.templates = {}

def open_terminal(command: str = None):
    """
    Open a terminal and runs a command if provided.
    Cross-platform support for Windows and Linux.
    """

    system = platform.system()

    if system == "Windows":
        # Windows terminal options
        if os.path.exists(r"C:\Windows\System32\WindowsTerminal.exe"):
            terminal_cmd = ["wt.exe"]
        else:
            terminal_cmd = ["cmd.exe", "/c", "start", "cmd.exe", "/k"]
        
        cmd = terminal_cmd + [command] if command else terminal_cmd
    
    else:
        # Linux terminal options
        if os.path.exists('/usr/bin/gnome-terminal'):
            terminal_cmd = ['gnome-terminal', '--']
        elif os.path.exists('/usr/bin/konsole'):
            terminal_cmd = ['konsole', '-e']
        elif os.path.exists('/usr/bin/xterm'):
            terminal_cmd = ['xterm', '-e']
        else:
            terminal_cmd = ['x-terminal-emulator', '-e']

        cmd = terminal_cmd + ['bash', '-c', f'{command}; exec bash'] if command else terminal_cmd

    try:
        subprocess.Popen(cmd, shell=(system == "Windows"))
    except subprocess.SubprocessError as e:
        raise RuntimeError(f"Failed to open terminal: {str(e)}")


app = typer.Typer()

@app.command()
def config(path: str =typer.Option("src/containers", help="Path to the containers directory")):

    """
    Configure the containers to use and add templates.
    """

    from InquirerPy import inquirer
    
    info = ExecInfo()
    while True:

        info.containers = inquirer.fuzzy(
            message="Select containers to use:",
            choices=[nombre for nombre in os.listdir(path) if os.path.isdir(os.path.join(path, nombre))],
            multiselect=True,
            validate=lambda result: len(result) > 0,
            invalid_message="Choose at least 1",
            transformer=lambda result: f"Containers selected: {', '.join(result)}"
        ).execute()

        while True:
            add_template = inquirer.confirm(
                message=f"Want to add a template? Templates: {info.templates}",
                default=False
            ).execute()

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
    
    data = {"containers": info.containers}
    if info.templates:
        data["templates"] = info.templates
        
    YML.write(
        path="config.yml",
        data=data
    )
    typer.echo("Configuration saved to config.yml")

@app.command()
def start(path: str = typer.Option("./config.yml", help="Path to the YAML file")):
    """
    Runs based on the YAML config file provided or the default value.
    """
    from rich.console import Console
    from rich.panel import Panel
    from rich.progress import Progress, SpinnerColumn, TextColumn
    
    console = Console()
    
    # Read config file
    with console.status("[bold blue]Reading configuration file...") as status:
        config_data = YML.read(path)
    
    if not config_data or 'containers' not in config_data:
        console.print(Panel("[bold red]Error: Invalid config file or no containers specified", 
                          title="Configuration Error"))
        return
    
    console.print(Panel(
        f"[green]Found {len(config_data['containers'])} containers to start", 
        title="Configuration Loaded"
    ))
    
    command = ["docker-compose"]
    valid_containers = []
    
    # Validate compose files exist
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console
    ) as progress:
        for container in config_data['containers']:
            task = progress.add_task(f"[blue]Checking {container}...", total=None)
            compose_path = f"src/containers/{container}/docker-compose.yml"
            
            if not os.path.exists(compose_path):
                progress.update(task, description=f"[red]❌ {container}: docker-compose.yml not found")
                continue
                
            command += ["-f", compose_path]
            valid_containers.append(container)
            progress.update(task, description=f"[green]✓ {container}: Found")
    
    if not valid_containers:
        console.print(Panel("[bold red]No valid containers found to start", 
                          title="Error"))
        return
        
    command += ["up", "-d"]

    # Start containers
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console
    ) as progress:
        try:
            task = progress.add_task("[yellow]Starting containers...", total=None)
            subprocess.run(command, check=True, capture_output=True)
            progress.update(task, description="[green]✓ All containers started successfully!")
            
        except subprocess.CalledProcessError as e:
            progress.update(task, description="[red]❌ Error starting containers")
            console.print(Panel(f"[red]Error: {str(e)}\n{e.stderr.decode()}", 
                              title="Docker Error"))

@app.command()
def stop(
    path: str = typer.Option("./config.yml", help="Path to the YAML file"),
    remove: bool = typer.Option(False, "--remove", "-r", "-rmi", help="Remove containers and images after stopping")
):
    """
    Stops containers and optionally removes images.
    """
    from rich.console import Console
    from rich.panel import Panel
    from rich.progress import Progress, SpinnerColumn, TextColumn
    
    console = Console()
    
    # Read config file
    with console.status("[bold blue]Reading configuration file...") as status:
        config_data = YML.read(path)
    
    if not config_data or 'containers' not in config_data:
        console.print(Panel("[bold red]Error: Invalid config file or no containers specified", 
                          title="Configuration Error"))
        return
    
    console.print(Panel(
        f"[yellow]Found {len(config_data['containers'])} containers to stop", 
        title="Configuration Loaded"
    ))
    
    command = ["docker-compose"]
    valid_containers = []
    
    # Validate compose files exist
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console
    ) as progress:
        for container in config_data['containers']:
            task = progress.add_task(f"[blue]Checking {container}...", total=None)
            compose_path = f"src/containers/{container}/docker-compose.yml"
            
            if not os.path.exists(compose_path):
                progress.update(task, description=f"[red]❌ {container}: docker-compose.yml not found")
                continue
                
            command += ["-f", compose_path]
            valid_containers.append(container)
            progress.update(task, description=f"[green]✓ {container}: Found")
    
    if not valid_containers:
        console.print(Panel("[bold red]No valid containers found to stop", 
                          title="Error"))
        return

    # Stop containers
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console
    ) as progress:
        try:
            # Stop containers
            task = progress.add_task("[yellow]Stopping containers...", total=None)
            stop_command = command + ["down"]
            if remove:
                stop_command += ["--rmi", "all", "-v"]
            
            subprocess.run(stop_command, check=True, capture_output=True)
            
            if remove:
                progress.update(task, description="[green]✓ All containers stopped and removed!")
            else:
                progress.update(task, description="[green]✓ All containers stopped!")
            
        except subprocess.CalledProcessError as e:
            progress.update(task, description="[red]❌ Error stopping containers")
            console.print(Panel(f"[red]Error: {str(e)}\n{e.stderr.decode()}", 
                              title="Docker Error"))

@app.command()
def terminal(
    path: str = typer.Option("./config.yml", help="Path to the config file"),
    exclude: list[str] = typer.Option(None, "--exclude", "-e", help="Containers to exclude")
):
    """
    Open multiple terminal windows and connect to the containers.
    """
    import yaml
    from rich.console import Console
    from rich.panel import Panel
    from rich.progress import Progress, SpinnerColumn, TextColumn
    from Yalm_handler import Yalm_handler as YML
    from pathlib import Path

    console = Console()
    exclude = exclude or []

    # Get container names from docker-compose.yml
    with console.status("[bold blue]Reading configuration file...") as status:
        if not Path(path).exists():
            console.print(Panel("[bold red]Error: Config file not found", title="Error"))
            return

        config_data = YML.read(str(path))
        if not config_data or 'containers' not in config_data:
            console.print(Panel("[bold red]Error: Invalid config file", title="Error"))
            return

    # Process each container
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console
    ) as progress:
        task = progress.add_task("[blue]Processing containers...", total=len(config_data['containers']))
        
        for container in config_data['containers']:
            if container in exclude:
                progress.update(task, advance=1, description=f"[yellow]Skipping {container} (excluded)")
                continue

            compose_path = f"src/containers/{container}/docker-compose.yml"
            
            if not os.path.exists(compose_path):
                progress.update(task, advance=1, description=f"[red]❌ {container}: docker-compose.yml not found")
                continue

            try:
                with open(compose_path, 'r') as f:
                    compose_data = yaml.safe_load(f)

                # Extract container names from services
                for service_data in compose_data.get('services', {}).values():
                    container_name = service_data.get('container_name')
                    if container_name:
                        progress.update(task, description=f"[blue]Opening terminal for {container_name}")
                        open_terminal(f"docker exec -it {container_name} /bin/bash")

            except Exception as e:
                progress.update(task, advance=1, description=f"[red]❌ Error processing {container}: {str(e)}")
                continue

            progress.update(task, advance=1, description=f"[green]✓ Processed {container}")

    console.print(Panel("[green]All terminals opened successfully!", title="Complete"))

if __name__ == "__main__":
    app()