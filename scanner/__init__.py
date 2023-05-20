import os
import toml

def getConfig():
    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(script_dir, './config.toml')
    config = toml.load(file_path)
    return config
