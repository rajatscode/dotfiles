test:
    agent-slot -- uv run --with pytest --with pyyaml --with json5 --with ruamel.yaml --with tomlkit python -m pytest tests

lint:
    uv run --with ruff ruff check dot_local/bin/executable_ashkelon-setup tests/test_ashkelon_setup.py dot_local/bin/executable_agent-slot tests/test_agent_slot.py
    bash -n dot_bashrc.d/95-ashkelon.bashrc
    zsh -n dot_config/zsh/95-ashkelon.zsh
    fish -n dot_config/fish/conf.d/95-ashkelon.fish
