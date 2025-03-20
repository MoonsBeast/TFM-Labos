import typer

app = typer.Typer()

@app.command()
def cli():
    print("Hello from the CLI")


@app.command()
def compose(file: str = "./compose.yml"):
    print(f"File: {file}")


if __name__ == "__main__":
    app()