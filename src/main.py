#!/usr/bin/python
import typer
import Inq_Questions
from InquirerPy import inquirer
from Yalm_handler import Yalm_handler as YML

app = typer.Typer()

class ExecInfo:
    def __init__(self, data:dict={}):

        if data != {}:
            self.mode = data["mode"]
            self.images = data["images"]
            self.templates = data["templates"]
        
        else:

            self.mode = ""
            self.images = []
            self.templates = {}

@app.command()
def cli():

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
            transformer=lambda result: f"Images selected: {", ".join(result)}"
        ).execute()

        proceed = inquirer.confirm(message="Proceed?", default=True).execute()

        if proceed: break

@app.command()
def compose(path: str):
    print(f"File: {path}")

@app.command
def build(path: str):
    pass

@app.command
def compose_build(path: str):
    pass

if __name__ == "__main__":
    app()