"""Load Robot Framework variables from config.yaml."""
from pathlib import Path
import yaml

def get_variables(config_path="config.yaml"):
    path = Path(__file__).parent / config_path
    with path.open("r", encoding="utf-8") as f:
        config = yaml.safe_load(f)

    return {
        "BASE_URL": config["env"]["url"],
        "BROWSER": config["env"].get("browser", "chrome"),
        "HEADLESS": bool(config["env"].get("headless", False)),
        "IMPLICIT_WAIT": config["timeout"].get("implicit_wait", "10s"),
        "EXPLICIT_WAIT": config["timeout"].get("explicit_wait", "15s"),
        "STANDARD_USER": config["default_user"]["standard"],
        "LOCKED_USER": config["default_user"]["locked"],
        "DEFAULT_PASSWORD": config.get("default_password", "secret_sauce"),
    }
