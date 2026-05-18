from __future__ import annotations

from zcompy import Command, Completion, Default, Files, Option
from zcompy.action import GitBranches, GitCommits, OSEnv, URLs


def list_profiles():
    import os
    from pathlib import Path

    try:
        import tomllib

        config_path = Path(os.environ.get("CODEX_HOME", "~/.codex")).expanduser() / "config.toml"
        with config_path.open("rb") as f:
            config = tomllib.load(f)
    except Exception:
        return

    profiles = config.get("profiles", {})
    if not isinstance(profiles, dict):
        return
    for name in profiles:
        print(name)


def list_mcp_servers():
    import os
    from pathlib import Path

    try:
        import tomllib

        config_path = Path(os.environ.get("CODEX_HOME", "~/.codex")).expanduser() / "config.toml"
        with config_path.open("rb") as f:
            config = tomllib.load(f)
    except Exception:
        return

    servers = config.get("mcp_servers", {})
    if not isinstance(servers, dict):
        return
    for name, config in servers.items():
        desc = ""
        if isinstance(config, dict):
            desc = config.get("url") or " ".join(config.get("command", [])[:1])
        print(f"{name} {desc}".rstrip())


def list_plugin_marketplaces():
    import json
    import os
    from pathlib import Path

    config_path = Path(os.environ.get("CODEX_HOME", "~/.codex")).expanduser() / "plugins" / "marketplace.json"
    if not config_path.exists():
        return
    try:
        data = json.loads(config_path.read_text())
    except Exception:
        return

    marketplaces = data.get("marketplaces", data)
    if isinstance(marketplaces, dict):
        for name in marketplaces:
            print(name)
    elif isinstance(marketplaces, list):
        for item in marketplaces:
            if isinstance(item, str):
                print(item)
            elif isinstance(item, dict):
                name = item.get("name") or item.get("id")
                if name:
                    print(name)


def list_sessions():
    import json
    import os
    from pathlib import Path

    sessions_dir = Path(os.environ.get("CODEX_HOME", "~/.codex")).expanduser() / "sessions"
    if not sessions_dir.exists():
        return

    for session_file in sorted(sessions_dir.rglob("*.jsonl"), reverse=True):
        session_id = ""
        desc = ""
        fallback_desc = ""
        try:
            with session_file.open() as f:
                for line in f:
                    event = json.loads(line)
                    payload = event.get("payload") or {}

                    if event.get("type") == "session_meta":
                        meta = payload or event.get("session_meta") or {}
                        session_id = meta.get("id") or session_file.stem.removeprefix("rollout-")
                        cwd = meta.get("cwd") or ""
                        timestamp = meta.get("timestamp") or event.get("timestamp") or ""
                        fallback_desc = " ".join(x for x in (timestamp, cwd) if x)
                        continue

                    if payload.get("type") == "user_message":
                        message = payload.get("message") or ""
                    elif payload.get("type") == "message" and payload.get("role") == "user":
                        parts = payload.get("content") or []
                        message = " ".join(
                            part.get("text", "") for part in parts
                            if isinstance(part, dict) and part.get("type") == "input_text"
                        )
                    else:
                        continue

                    message = " ".join(message.split())
                    if (
                        message
                        and not message.startswith("<environment_context>")
                        and not message.startswith("# AGENTS.md instructions")
                    ):
                        desc = message
                        break
        except Exception:
            pass
        if session_id:
            print(f"{session_id} {desc or fallback_desc}".rstrip())


def list_features():
    try:
        import subprocess

        output = subprocess.check_output(
            ["codex", "features", "list"],
            stderr=subprocess.DEVNULL,
            text=True,
            timeout=2,
        )
    except Exception:
        return

    for line in output.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith(("Feature", "-", "[")):
            continue
        feature = stripped.split()[0]
        if feature not in {"Name", "Key"}:
            print(stripped)


MODEL_CHOICES = (
    "gpt-5.5",
    "gpt-5.4",
    "gpt-5.4-mini",
    "gpt-5.3-codex",
    "gpt-5.3-codex-spark",
    "gpt-5.2",
    "o3",
    "o4-mini",
)

SANDBOX_CHOICES = ("read-only", "workspace-write", "danger-full-access")
APPROVAL_CHOICES = ("untrusted", "on-request", "on-failure", "never")
LOCAL_PROVIDER_CHOICES = ("lmstudio", "ollama")
COLOR_CHOICES = ("always", "never", "auto")
SHELL_CHOICES = ("bash", "elvish", "fish", "powershell", "zsh")
WS_AUTH_CHOICES = ("capability-token", "signed-bearer-token")

model_completion = Completion(MODEL_CHOICES)
profile_completion = Completion(list_profiles, ignore_exception=True)
feature_completion = Completion(list_features, ignore_exception=True)
mcp_server_completion = Completion(list_mcp_servers, ignore_exception=True)
marketplace_completion = Completion(list_plugin_marketplaces, ignore_exception=True)
session_completion = Completion(list_sessions, ignore_exception=True)
task_completion = Default()


def common_options(include_version: bool = False) -> list[Option]:
    options = [
        Option(
            ("-c", "--config"),
            "Override a configuration value from config.toml",
            complete_func=Default(),
            allow_repeat=True,
        ),
        Option("--enable", "Enable a feature", complete_func=feature_completion, allow_repeat=True),
        Option("--disable", "Disable a feature", complete_func=feature_completion, allow_repeat=True),
        Option(("-h", "--help"), "Print help"),
    ]
    if include_version:
        options.append(Option(("-V", "--version"), "Print version"))
    return options


def agent_options() -> list[Option]:
    return [
        Option(("-i", "--image"), "Attach image to the initial prompt", complete_func=Files(), allow_repeat=True),
        Option(("-m", "--model"), "Model the agent should use", complete_func=model_completion),
        Option("--oss", "Use open-source provider"),
        Option("--local-provider", "Specify local OSS provider", complete_func=Completion(LOCAL_PROVIDER_CHOICES)),
        Option(("-p", "--profile"), "Configuration profile", complete_func=profile_completion),
        Option(("-s", "--sandbox"), "Sandbox policy", complete_func=Completion(SANDBOX_CHOICES)),
        Option("--dangerously-bypass-approvals-and-sandbox", "Skip approvals and sandboxing"),
        Option(("-C", "--cd"), "Working root", complete_func=Files(dir_only=True)),
        Option("--add-dir", "Additional writable directory", complete_func=Files(dir_only=True), allow_repeat=True),
        Option(("-a", "--ask-for-approval"), "Approval policy", complete_func=Completion(APPROVAL_CHOICES)),
        Option("--search", "Enable live web search"),
        Option("--no-alt-screen", "Disable alternate screen mode"),
        Option("--remote", "Remote app-server websocket endpoint", complete_func=URLs()),
        Option("--remote-auth-token-env", "Bearer token environment variable", complete_func=OSEnv()),
    ]


def exec_options() -> list[Option]:
    return [
        *agent_options(),
        Option("--skip-git-repo-check", "Allow running outside a Git repository"),
        Option("--ephemeral", "Run without persisting session files"),
        Option("--ignore-user-config", "Do not load user config.toml"),
        Option("--ignore-rules", "Do not load execpolicy rules"),
        Option("--output-schema", "Path to JSON Schema output file", complete_func=Files()),
        Option("--color", "Output color setting", complete_func=Completion(COLOR_CHOICES)),
        Option("--json", "Print events as JSONL"),
        Option(("-o", "--output-last-message"), "File for last agent message", complete_func=Files()),
    ]


def make_exec_command(name: str = "exec") -> Command:
    cmd = Command(name, "Run Codex non-interactively")
    cmd.add_options([*common_options(include_version=True), *exec_options()])
    cmd.add_positional_args(Default())

    resume = Command("resume", "Resume a previous non-interactive session")
    resume.add_options([*common_options(), Option("--last", "Resume the most recent session")])
    resume.add_positional_args(session_completion)

    review = Command("review", "Run a code review against the current repository")
    review.add_options(common_options())
    review.add_positional_args(Default())

    cmd.add_sub_commands([resume, review])
    return cmd


def make_review_command() -> Command:
    cmd = Command("review", "Run a code review non-interactively")
    cmd.add_options([
        *common_options(),
        Option("--uncommitted", "Review staged, unstaged, and untracked changes"),
        Option("--base", "Review changes against base branch", complete_func=GitBranches(remote=True)),
        Option("--commit", "Review changes introduced by commit", complete_func=GitCommits(num_commits=40)),
        Option("--title", "Review title", complete_func=Default()),
    ])
    cmd.add_positional_args(Default())
    return cmd


def make_login_command() -> Command:
    cmd = Command("login", "Manage login")
    cmd.add_options([
        *common_options(),
        Option("--with-api-key", "Read API key from stdin"),
        Option("--with-access-token", "Read access token from stdin"),
        Option("--device-auth", "Use device authentication"),
    ])
    status = Command("status", "Show login status")
    status.add_options(common_options())
    cmd.add_sub_commands(status)
    return cmd


def make_mcp_command() -> Command:
    cmd = Command("mcp", "Manage external MCP servers")
    cmd.add_options(common_options())

    list_cmd = Command("list", "List configured MCP servers")
    list_cmd.add_options(common_options())

    get = Command("get", "Show an MCP server configuration")
    get.add_options([*common_options(), Option("--json", "Output as JSON")])
    get.add_positional_args(mcp_server_completion)

    add = Command("add", "Add an MCP server")
    add.add_options([
        *common_options(),
        Option("--env", "Environment variable", complete_func=Default(), allow_repeat=True),
        Option("--url", "Streamable HTTP MCP server URL", complete_func=URLs()),
        Option("--bearer-token-env-var", "Bearer token environment variable", complete_func=OSEnv()),
    ])
    add.add_positional_args(Default())
    add.repeat_pos_args = Default()

    remove = Command("remove", "Remove an MCP server")
    remove.add_options(common_options())
    remove.add_positional_args(mcp_server_completion)

    login = Command("login", "Authenticate with an MCP server")
    login.add_options([*common_options(), Option("--scopes", "OAuth scopes", complete_func=Default())])
    login.add_positional_args(mcp_server_completion)

    logout = Command("logout", "Deauthenticate an MCP server")
    logout.add_options(common_options())
    logout.add_positional_args(mcp_server_completion)

    cmd.add_sub_commands([list_cmd, get, add, remove, login, logout])
    return cmd


def make_plugin_command() -> Command:
    cmd = Command("plugin", "Manage Codex plugins")
    cmd.add_options(common_options())

    marketplace = Command("marketplace", "Manage plugin marketplaces")
    marketplace.add_options(common_options())

    add = Command("add", "Add a plugin marketplace")
    add.add_options([
        *common_options(),
        Option("--ref", "Git ref", complete_func=GitBranches(tags=True)),
        Option("--sparse", "Sparse path", complete_func=Files(dir_only=True)),
    ])
    add.add_positional_args(Files(dir_only=True))

    upgrade = Command("upgrade", "Upgrade plugin marketplaces")
    upgrade.add_options(common_options())

    remove = Command("remove", "Remove a plugin marketplace")
    remove.add_options(common_options())
    remove.add_positional_args(marketplace_completion)

    marketplace.add_sub_commands([add, upgrade, remove])
    cmd.add_sub_commands(marketplace)
    return cmd


def make_app_server_command() -> Command:
    cmd = Command("app-server", "Run the app server or related tooling")
    cmd.add_options([
        *common_options(),
        Option("--listen", "Transport endpoint URL", complete_func=Default()),
        Option("--analytics-default-enabled", "Enable analytics by default"),
        Option("--ws-auth", "Websocket auth mode", complete_func=Completion(WS_AUTH_CHOICES)),
        Option("--ws-token-file", "Capability token file", complete_func=Files()),
        Option("--ws-token-sha256", "Capability token SHA-256", complete_func=Default()),
        Option("--ws-shared-secret-file", "JWT shared secret file", complete_func=Files()),
        Option("--ws-issuer", "JWT issuer", complete_func=Default()),
        Option("--ws-audience", "JWT audience", complete_func=Default()),
        Option("--ws-max-clock-skew-seconds", "JWT max clock skew seconds", complete_func=Default()),
    ])
    for name, desc in [
        ("proxy", "Proxy stdio bytes to the app-server control socket"),
        ("generate-ts", "Generate TypeScript bindings"),
        ("generate-json-schema", "Generate JSON Schema"),
    ]:
        sub = Command(name, desc)
        sub.add_options(common_options())
        cmd.add_sub_commands(sub)
    return cmd


def make_sandbox_command() -> Command:
    cmd = Command("sandbox", "Run commands within a Codex sandbox")
    cmd.add_options(common_options())
    for name, desc in [
        ("linux", "Run a command under the Linux sandbox"),
        ("macos", "Run a command under Seatbelt"),
        ("windows", "Run a command under Windows restricted token"),
    ]:
        sub = Command(name, desc)
        sub.add_options([
            *common_options(),
            Option("--permissions-profile", "Named permissions profile", complete_func=Default()),
            Option(("-C", "--cd"), "Working directory", complete_func=Files(dir_only=True)),
            Option("--include-managed-config", "Include managed requirements"),
        ])
        sub.repeat_pos_args = Default()
        cmd.add_sub_commands(sub)
    return cmd


def make_debug_command() -> Command:
    cmd = Command("debug", "Debugging tools")
    cmd.add_options(common_options())
    models = Command("models", "Render the raw model catalog as JSON")
    models.add_options(common_options())
    prompt_input = Command("prompt-input", "Render model-visible prompt input as JSON")
    prompt_input.add_options(common_options())
    app_server = Command("app-server", "Debug app server")
    app_server.add_options(common_options())
    send_message = Command("send-message-v2", "Send an app-server message")
    send_message.add_options(common_options())
    app_server.add_sub_commands(send_message)
    cmd.add_sub_commands([models, app_server, prompt_input])
    return cmd


def make_cloud_command() -> Command:
    cmd = Command("cloud", "Browse tasks from Codex Cloud and apply changes locally")
    cmd.add_options(common_options(include_version=True))

    exec_cmd = Command("exec", "Submit a Codex Cloud task")
    exec_cmd.add_options([
        *common_options(),
        Option("--env", "Target environment id", complete_func=Default()),
        Option("--attempts", "Number of assistant attempts", complete_func=Completion(tuple(str(i) for i in range(1, 6)))),
        Option("--branch", "Git branch", complete_func=GitBranches(remote=True)),
    ])
    exec_cmd.add_positional_args(Default())

    list_cmd = Command("list", "List Codex Cloud tasks")
    list_cmd.add_options([
        *common_options(),
        Option("--env", "Filter by environment id", complete_func=Default()),
        Option("--limit", "Maximum tasks to return", complete_func=Completion(tuple(str(i) for i in range(1, 21)))),
        Option("--cursor", "Pagination cursor", complete_func=Default()),
        Option("--json", "Emit JSON"),
    ])

    status = Command("status", "Show Codex Cloud task status")
    status.add_options(common_options())
    status.add_positional_args(task_completion)

    apply = Command("apply", "Apply a Codex Cloud task diff")
    apply.add_options([*common_options(), Option("--attempt", "Attempt number", complete_func=Default())])
    apply.add_positional_args(task_completion)

    diff = Command("diff", "Show a Codex Cloud task diff")
    diff.add_options([*common_options(), Option("--attempt", "Attempt number", complete_func=Default())])
    diff.add_positional_args(task_completion)

    cmd.add_sub_commands([exec_cmd, status, list_cmd, apply, diff])
    return cmd


def make_features_command() -> Command:
    cmd = Command("features", "Inspect feature flags")
    cmd.add_options(common_options())

    list_cmd = Command("list", "List known features")
    list_cmd.add_options(common_options())

    enable = Command("enable", "Enable a feature in config.toml")
    enable.add_options(common_options())
    enable.add_positional_args(feature_completion)

    disable = Command("disable", "Disable a feature in config.toml")
    disable.add_options(common_options())
    disable.add_positional_args(feature_completion)

    cmd.add_sub_commands([list_cmd, enable, disable])
    return cmd


def make_resume_command(name: str = "resume", desc: str = "Resume a previous interactive session") -> Command:
    cmd = Command(name, desc)
    cmd.add_options([
        *common_options(include_version=True),
        Option("--last", "Use most recent session"),
        Option("--all", "Show all sessions"),
        Option("--include-non-interactive", "Include non-interactive sessions"),
        *agent_options(),
    ])
    cmd.add_positional_args(session_completion)
    cmd.add_positional_args(Default())
    return cmd


def make_codex_command() -> Command:
    cmd = Command("codex", "Codex CLI")
    cmd.add_options([*common_options(include_version=True), *agent_options()])
    cmd.add_positional_args(Default())

    logout = Command("logout", "Remove stored authentication credentials")
    logout.add_options(common_options())

    mcp_server = Command("mcp-server", "Start Codex as an MCP server")
    mcp_server.add_options(common_options())

    remote_control = Command("remote-control", "Start a headless app-server with remote control")
    remote_control.add_options(common_options())

    completion = Command("completion", "Generate shell completion scripts")
    completion.add_options(common_options())
    completion.add_positional_args(Completion(SHELL_CHOICES))

    update = Command("update", "Update Codex")
    update.add_options(common_options())

    apply = Command("apply", "Apply the latest diff produced by Codex")
    apply.add_options(common_options())
    apply.add_positional_args(task_completion)

    exec_server = Command("exec-server", "Run the standalone exec-server service")
    exec_server.add_options([
        *common_options(),
        Option("--listen", "Transport endpoint URL", complete_func=Default()),
        Option("--remote", "Remote executor base URL", complete_func=URLs()),
        Option("--executor-id", "Executor id", complete_func=Default()),
        Option("--name", "Executor name", complete_func=Default()),
    ])

    cmd.add_sub_commands([
        make_exec_command(),
        make_review_command(),
        make_login_command(),
        logout,
        make_mcp_command(),
        make_plugin_command(),
        mcp_server,
        make_app_server_command(),
        remote_control,
        completion,
        update,
        make_sandbox_command(),
        make_debug_command(),
        apply,
        make_resume_command(),
        make_resume_command("fork", "Fork a previous interactive session"),
        make_cloud_command(),
        exec_server,
        make_features_command(),
    ])
    return cmd


if __name__ == "__main__":
    cmd = make_codex_command()
    print(cmd.complete_source(as_file=True, sort_completion=False))
