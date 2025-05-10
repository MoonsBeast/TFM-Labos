from enum import Enum
from Yalm_handler import Yalm_handler as YML
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.panel import Panel
from rich import print as rprint

console = Console()

class Mode(Enum):
    COMPOSE = "compose"
    BUILD = "build"
    COMPOSE_AND_BUILD = "compose_build"



class Conductor:
    def __init__(self, file_path: str = None, build_path: str = None, info: ExecInfo = None):

        self.file_path = file_path if file_path else "./images.yml"
        self.build_path = build_path if build_path else "./lab_build"
        self.info = info if info else ExecInfo()

    def read_yaml(self):
        data = YML.read(self.file_path)
        if data:
            self.info.mode = data.get("mode", "")
            self.info.images = data.get("images", [])
            self.info.templates = data.get("templates", {})
        else:
            self.info.mode = ""
            self.info.images = []
            self.info.templates = {}

    def process(self, info: ExecInfo = None):
        if info:
            self.info = info
        elif not self.info:
            raise ValueError("Nothing to process.")

        match self.info.mode:
            case Mode.COMPOSE.value:
                self.__compose()
            case Mode.BUILD.value:
                self.__build()
            case Mode.COMPOSE_AND_BUILD.value:
                self.__compose()
                self.__build()
            case _:
                raise ValueError(f"Unknown mode: {self.info.mode}")

    def __compose(self):
        if self.info.mode == "":
            raise ValueError("Mode not selected. Please select a mode before composing.")

        import os
        import yaml
        from pathlib import Path

        console.print(Panel.fit("🚀 Starting Compose Process", style="bold blue"))

        # Create build directory if it doesn't exist
        build_dir = Path(self.build_path)
        build_dir.mkdir(exist_ok=True)

        # Initialize docker-compose structure
        merged_compose = {
            'version': '3',
            'services': {},
            'networks': {
                'lab_network': {
                    'driver': 'bridge',
                    'ipam': {
                        'config': [{'subnet': '100.0.0.0/24'}]
                    }
                }
            }
        }

        with Progress(SpinnerColumn(), TextColumn("[progress.description]{task.description}"), console=console, transient=True) as progress:
            merge_task = progress.add_task("[blue]Processing images...", total=len(self.info.images))
            
            for image in self.info.images:
                progress.update(merge_task, description=f"[blue]Processing {image}")
                compose_path = Path(f"./src/images/{image}/docker-compose.yml")
                
                if not compose_path.exists():
                    console.print(f"[yellow]⚠️ Warning: docker-compose.yml not found for {image}")
                    progress.advance(merge_task)
                    continue

                with open(compose_path, 'r') as f:
                    compose_data = yaml.safe_load(f)
                    if compose_data and 'services' in compose_data:
                        merged_compose['services'].update(compose_data['services'])
                        if 'networks' in compose_data:
                            merged_compose['networks'].update(compose_data['networks'])
                
                progress.advance(merge_task)
                console.print(f"[green]✓ {image} processed")
            
            if self.info.templates:
                template_task = progress.add_task("[blue]Applying templates...", total=len(self.info.templates))
                yaml_str = yaml.dump(merged_compose)
                for key, value in self.info.templates.items():
                    yaml_str = yaml_str.replace(f"<{key}>", str(value))
                    progress.advance(template_task)
                    console.print(f"[green]✓ Template {key} applied")
                merged_compose = yaml.safe_load(yaml_str)

            write_task = progress.add_task("[blue]Writing final docker-compose.yml...", total=1)
            output_path = build_dir / "docker-compose.yml"
            with open(output_path, 'w') as f:
                yaml.dump(merged_compose, f, indent=2, sort_keys=False)
            
            progress.update(write_task, completed=1)
            console.print(f"[green]✓ Docker Compose file generated at {output_path}")

        console.print(Panel.fit("✨ Compose Process Complete!", style="bold green"))

    def __build(self):
        import shutil
        from pathlib import Path

        console.print(Panel.fit("🚀 Starting Build Process", style="bold blue"))

        build_dir = Path(self.build_path)
        build_dir.mkdir(exist_ok=True)
        exclude_files = {'docker-compose.yml', 'Dockerfile'}

        with Progress(SpinnerColumn(), TextColumn("[progress.description]{task.description}"), console=console, transient=True) as progress:
            copy_task = progress.add_task("[blue]Copying files...", total=len(self.info.images))

            for image in self.info.images:
                source_dir = Path(f"./src/images/{image}")
                if not source_dir.exists():
                    console.print(f"[yellow]⚠️ Warning: Source directory not found for {image}")
                    progress.advance(copy_task)
                    continue

                progress.update(copy_task, description=f"[blue]Copying {image} files")
                
                def copy_recursively(src: Path, dst: Path):
                    for item in src.iterdir():
                        if item.name in exclude_files:
                            continue
                        if item.is_file():
                            shutil.copy2(item, dst / item.name)
                        elif item.is_dir():
                            new_dst = dst / item.name
                            new_dst.mkdir(exist_ok=True)
                            copy_recursively(item, new_dst)

                copy_recursively(source_dir, build_dir)
                progress.advance(copy_task)
                console.print(f"[green]✓ {image} files copied")

        console.print(Panel.fit("✨ Build Process Complete!", style="bold green"))

