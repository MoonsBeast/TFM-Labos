import yaml

class Yalm_handler:

    @staticmethod
    def read(path: str) -> dict:
        with open(path, "r") as file:
            return yaml.safe_load(file)
        
    @staticmethod
    def write(path: str, data: dict, flow_style=False) -> None:
        with open(path, "w") as file:
            yaml.dump(data, file, default_flow_style=flow_style)
