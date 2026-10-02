import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path

import pytest
import tomllib
from ruamel.yaml import YAML

SCRIPT = Path(__file__).resolve().parents[1] / "dot_local/bin/executable_ashkelon-setup"
loader = importlib.machinery.SourceFileLoader("ashkelon_setup", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
setup = importlib.util.module_from_spec(spec)
loader.exec_module(setup)


def existing(home, name, content):
    path = home / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    return path


@pytest.mark.parametrize("provider", ["openai", "ashkelon", "ashkelon-api"])
def test_routes_codex_without_changing_model_auth_or_tools(tmp_path, provider):
    config = existing(tmp_path, ".codex/config.toml", f'''
model = "chosen-model"
model_provider = "{provider}"
service_tier = "priority"
# Preserve this setting.
[mcp_servers.local]
command = "my-server"
[shell_environment_policy.set]
EXISTING = "kept"
''')
    setup.configure(tmp_path)
    result = tomllib.loads(config.read_text())
    expected = "ashkelon" if provider == "openai" else provider
    assert result["model_provider"] == expected
    assert result["model"] == "chosen-model"
    assert result["service_tier"] == "priority"
    assert result["mcp_servers"]["local"]["command"] == "my-server"
    assert result["shell_environment_policy"]["set"]["EXISTING"] == "kept"
    assert result["shell_environment_policy"]["set"]["ORI_OPENROUTER_BASE_URL"].endswith("/openrouter/api/v1")
    assert result["model_providers"]["ashkelon"]["requires_openai_auth"] is True
    assert result["model_providers"]["ashkelon-api"]["env_key"] == "OPENAI_API_KEY"
    assert "# Preserve this setting." in config.read_text()


@pytest.mark.parametrize("filename", ["opencode.json", "opencode.jsonc"])
def test_routes_opencode_while_preserving_provider_credentials_and_mcp(tmp_path, filename):
    path = existing(tmp_path, f".config/opencode/{filename}", '''{
      // A configured client.
      "mcp": {"local": {"type": "local", "command": ["server"]}},
      "provider": {"openrouter": {"options": {"apiKey": "fixture-key"}}}
    }''')
    setup.configure(tmp_path)
    result = json.loads(path.read_text())
    assert result["mcp"]["local"]["command"] == ["server"]
    assert result["provider"]["openrouter"]["options"]["apiKey"] == "fixture-key"
    assert result["provider"]["openrouter"]["options"]["baseURL"].endswith("/openrouter/api/v1")


@pytest.mark.parametrize("provider,key,mode", [
    ("anthropic", "ANTHROPIC_API_KEY", "anthropic_messages"),
    ("openrouter", "OPENROUTER_API_KEY", "chat_completions"),
])
def test_hermes_uses_api_key_provider_and_preserves_gateway_settings(tmp_path, provider, key, mode, monkeypatch):
    monkeypatch.delenv(key, raising=False)
    path = existing(tmp_path, ".hermes/config.yaml", f'''
model:
  provider: {provider}
  default: chosen-model
gateway:
  existing: true
providers: {{}}
''')
    credential = existing(tmp_path, ".hermes/.env", f"{key}=fixture-key\nSLACK_BOT_TOKEN=fixture-slack\n")
    assert setup.configure(tmp_path) is True
    result = YAML().load(path.read_text())
    assert result["model"]["default"] == "chosen-model"
    assert result["model"]["provider"] == "ashkelon-relay"
    assert result["providers"]["ashkelon-relay"]["key_env"] == key
    assert result["providers"]["ashkelon-relay"]["api_mode"] == mode
    assert result["gateway"]["existing"] is True
    assert "fixture-key" not in path.read_text()
    assert credential.read_text() == f"{key}=fixture-key\nSLACK_BOT_TOKEN=fixture-slack\n"


def test_hermes_missing_api_key_does_not_switch_authentication(tmp_path, monkeypatch):
    monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)
    path = existing(tmp_path, ".hermes/config.yaml", "model:\n  provider: anthropic\n")
    with pytest.raises(ValueError, match="ANTHROPIC_API_KEY"):
        setup.configure(tmp_path)
    assert YAML().load(path.read_text())["model"]["provider"] == "anthropic"


def test_native_configs_preserve_existing_tools_models_and_original_backup(tmp_path):
    claude = existing(tmp_path, ".claude/settings.json", '{"model":"chosen-model","permissions":{"allow":["Read"]}}\n')
    original = claude.read_text()
    omp = existing(tmp_path, ".omp/agent/models.yml", "providers:\n  ollama:\n    models:\n      - id: local-model\n")
    goose = existing(tmp_path, ".config/goose/config.yaml", "active_provider: ollama\nGOOSE_MODE: auto\n")
    aider = existing(tmp_path, ".aider.conf.yml", "model: chosen-model\nset-env:\n  - EXISTING=kept\n")
    cursor = existing(tmp_path, ".cursor/cli-config.json", '{"network":{"useHttp1ForAgent":false,"existing":true},"selectedModel":{"modelId":"chosen-model"}}')
    setup.configure(tmp_path)
    setup.configure(tmp_path)
    assert json.loads(claude.read_text())["permissions"]["allow"] == ["Read"]
    assert json.loads(claude.read_text())["model"] == "chosen-model"
    assert YAML().load(omp.read_text())["providers"]["ollama"]["models"] == [{"id": "local-model"}]
    assert YAML().load(omp.read_text())["providers"]["ollama"]["discovery"]["type"] == "ollama"
    assert YAML().load(goose.read_text())["active_provider"] == "ollama"
    aider_result = YAML().load(aider.read_text())
    assert aider_result["model"] == "chosen-model"
    assert "EXISTING=kept" in aider_result["set-env"]
    assert "ANTHROPIC_API_BASE=http://127.0.0.1:8484/anthropic" in aider_result["set-env"]
    cursor_result = json.loads(cursor.read_text())
    assert cursor_result["network"] == {"useHttp1ForAgent": True, "existing": True}
    assert cursor_result["selectedModel"]["modelId"] == "chosen-model"
    backup = tmp_path / ".local/state/ashkelon-setup/backups/.claude/settings.json"
    assert backup.read_text() == original
    assert backup.stat().st_mode & 0o777 == 0o600
    assert (tmp_path / ".config/ashkelon/env.sh").stat().st_mode & 0o777 == 0o600


@pytest.mark.parametrize("shell", ["bash", "zsh", "fish"])
def test_shell_environment_reaches_child_processes(tmp_path, shell):
    import subprocess

    setup.configure(tmp_path)
    if shell == "fish":
        command = f"source '{tmp_path}/.config/ashkelon/env.fish'; sh -c 'printf %s $ORI_OPENROUTER_BASE_URL'"
    else:
        command = f"source '{tmp_path}/.config/ashkelon/env.sh'; sh -c 'printf %s $ORI_OPENROUTER_BASE_URL'"
    result = subprocess.run([shell, "-c", command], capture_output=True, text=True, env=os.environ, check=False)
    assert result.returncode == 0, result.stderr
    assert result.stdout == setup.ENVIRONMENT["ORI_OPENROUTER_BASE_URL"]


def test_login_environment_restores_gui_routing(tmp_path):
    import subprocess

    setup.configure(tmp_path)
    login = tmp_path / ".config/ashkelon/login.sh"
    result = subprocess.run(["sh", "-n", str(login)], capture_output=True, text=True, check=False)
    assert result.returncode == 0, result.stderr
    commands = []
    for line in login.read_text().splitlines():
        if line.startswith("/bin/launchctl "):
            commands.append(line.replace("/bin/launchctl ", "printf '%s\\n' ", 1))
    result = subprocess.run(["sh", "-c", "\n".join(commands)], capture_output=True, text=True, check=True)
    args = result.stdout.splitlines()
    restored = dict(zip(args[1::3], args[2::3]))
    assert restored["CODE_ASSIST_ENDPOINT"] == "http://127.0.0.1:8484/google-code-assist"
    assert restored["ORI_OPENROUTER_BASE_URL"] == "http://127.0.0.1:8484/openrouter/api/v1"


def test_binary_replacement_keeps_existing_open_executable(tmp_path):
    old = existing(tmp_path, ".local/bin/ashkelon", "old executable")
    replacement = existing(tmp_path, "replacement", "new executable")
    with old.open() as opened:
        setup.install_binary(tmp_path, replacement)
        assert opened.read() == "old executable"
    assert old.read_text() == "new executable"
    assert old.stat().st_mode & 0o777 == 0o755


@pytest.mark.parametrize("arguments,uses_native_endpoint", [
    (["omp", "prompt with spaces"], True),
    (["--json", "omp", "$(literal)"], True),
    (["--log-level", "debug", "omp"], True),
    (["hermes", "omp"], False),
    (["--human", "codex"], False),
    ([], False),
])
def test_ori_omp_uses_native_provider_settings_without_changing_other_launches(tmp_path, arguments, uses_native_endpoint):
    import subprocess
    import sys

    native = existing(tmp_path, ".local/bin/ori", f'''#!{sys.executable}
import json, os, sys
print(json.dumps({{"arguments":sys.argv[1:],"endpoint":os.environ.get("ORI_OPENROUTER_BASE_URL"),"provider_endpoint":os.environ.get("OPENROUTER_BASE_URL")}}))
''')
    native.chmod(0o700)
    setup.configure(tmp_path)
    env = dict(os.environ, HOME=str(tmp_path))
    source = tmp_path / ".config/ashkelon/env.sh"
    result = subprocess.run(["sh", "-c", f'. "{source}"; exec ori "$@"', "test", *arguments], env=env, capture_output=True, text=True, check=True)
    result = json.loads(result.stdout)
    assert result["arguments"] == arguments
    assert result["endpoint"] == (None if uses_native_endpoint else setup.ENVIRONMENT["ORI_OPENROUTER_BASE_URL"])
    assert result["provider_endpoint"] == setup.ENVIRONMENT["OPENROUTER_BASE_URL"]


@pytest.mark.parametrize("gui_path", ["", "/custom/bin:/usr/bin:/bin"])
def test_login_adapter_path_preserves_existing_or_default_launch_environment(tmp_path, gui_path):
    import subprocess
    import sys

    setup.configure(tmp_path)
    commands = tmp_path / "launchctl-calls.jsonl"
    tool = existing(tmp_path, "launchctl", f'''#!{sys.executable}
import json, os, sys
if sys.argv[1] == "getenv":
    if not os.environ["TEST_GUI_PATH"]:
        sys.exit(1)
    print(os.environ["TEST_GUI_PATH"])
else:
    with open({str(commands)!r}, "a") as out:
        out.write(json.dumps(sys.argv[1:]) + "\\n")
''')
    tool.chmod(0o700)
    login = tmp_path / ".config/ashkelon/login.sh"
    login.write_text(login.read_text().replace("/bin/launchctl", str(tool)))
    env = dict(os.environ, TEST_GUI_PATH=gui_path)
    subprocess.run(["sh", str(login)], env=env, capture_output=True, text=True, check=True)
    calls = [json.loads(line) for line in commands.read_text().splitlines()]
    path = next(call[2] for call in calls if call[1] == "PATH")
    assert path == str(tmp_path / ".config/ashkelon/bin") + ":" + (gui_path or env["PATH"])
