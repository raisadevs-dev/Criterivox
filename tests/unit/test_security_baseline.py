from pathlib import Path


def test_env_file_is_gitignored():
    gitignore = Path(".gitignore").read_text(encoding="utf-8")

    assert ".env" in gitignore