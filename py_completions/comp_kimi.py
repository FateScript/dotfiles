from zcompy import Command, Completion, Default, Files, Option

LOG_LEVELS = ("fatal", "error", "warn", "info", "debug", "trace", "silent")
OUTPUT_FORMATS = ("text", "stream-json")
COMMON_HOSTS = ("127.0.0.1", "0.0.0.0", "localhost")
LOGIN_REGIONS = ("mainland-cn", "global")


def list_sessions():
    import json
    from pathlib import Path

    try:
        index = Path("~/.kimi-code/session_index.jsonl").expanduser()
        lines = index.read_text().splitlines()
    except Exception:
        return

    home = str(Path.home())
    seen = set()
    count = 0
    for line in reversed(lines):  # most recent first
        if count >= 100:
            break
        try:
            rec = json.loads(line)
        except Exception:
            continue
        sid = rec.get("sessionId")
        if not sid or sid in seen:
            continue
        seen.add(sid)
        count += 1

        work_dir = rec.get("workDir", "")
        if work_dir.startswith(home):
            work_dir = "~" + work_dir[len(home) :]

        prompt = ""
        session_dir = rec.get("sessionDir")
        if session_dir:
            try:
                state = json.loads((Path(session_dir) / "state.json").read_text())
                prompt = state.get("lastPrompt", "") or ""
            except Exception:
                pass
        prompt = " ".join(prompt.split())[:60]

        desc = f"{work_dir}  {prompt}".strip()
        desc = desc.split("\n")[0].replace(":", "\\:")
        print(f"{sid} {desc}" if desc else sid)


def list_models():
    import tomllib
    from pathlib import Path

    try:
        with Path("~/.kimi-code/config.toml").expanduser().open("rb") as f:
            data = tomllib.load(f)
    except Exception:
        return

    for alias, info in data.get("models", {}).items():
        name = info.get("display_name", "") if isinstance(info, dict) else ""
        name = name.split("\n")[0].replace(":", "\\:")
        print(f"{alias} {name}" if name else alias)


def list_providers():
    import tomllib
    from pathlib import Path

    try:
        with Path("~/.kimi-code/config.toml").expanduser().open("rb") as f:
            data = tomllib.load(f)
    except Exception:
        return

    for pid in data.get("providers", {}):
        print(pid.replace(":", "\\:"))


def list_agents():
    from pathlib import Path

    seen = set()
    for name, desc in (
        ("coder", "Builtin: general software engineering agent"),
        ("explore", "Builtin: fast read-only codebase exploration"),
        ("plan", "Builtin: read-only implementation planning"),
    ):
        seen.add(name)
        print(f"{name} {desc}")

    roots = [
        Path("~/.kimi-code/agents").expanduser(),
        Path("~/.agents/agents").expanduser(),
    ]
    cwd = Path.cwd()
    for parent in (cwd, *cwd.parents):
        if (parent / ".git").exists():
            roots.append(parent / ".kimi-code" / "agents")
            roots.append(parent / ".agents" / "agents")
            break

    for root in roots:
        try:
            files = sorted(root.rglob("*.md"))
        except Exception:
            continue
        for f in files:
            name, desc = f.stem, ""
            try:
                text = f.read_text(errors="ignore")
            except Exception:
                continue
            if text.startswith("---"):
                for line in text.splitlines()[1:30]:
                    stripped = line.strip()
                    if stripped == "---":
                        break
                    if stripped.startswith("name:"):
                        name = stripped.split(":", 1)[1].strip().strip("\"'")
                    elif stripped.startswith("description:"):
                        desc = stripped.split(":", 1)[1].strip().strip("\"'")
            if not name or name in seen:
                continue
            seen.add(name)
            desc = desc.split("\n")[0].replace(":", "\\:")[:80]
            print(f"{name} {desc}" if desc else name)


def help_options():
    return [Option(("-h", "--help"), "Show help")]


def web_options(remote_control=False):
    """Options shared by `kimi web` and `kimi rc|remote`."""
    opts = [
        Option("--port", "Bind port (default 58627)", complete_func=Default("port")),
        Option(
            "--host",
            "Bind host (optional value)",
            complete_func=Completion(func=COMMON_HOSTS),
        ),
        Option(
            "--allowed-host",
            "Extra allowed Host header",
            complete_func=Default("host"),
            allow_repeat=True,
        ),
        Option("--insecure-no-tls", "Allow non-loopback bind without TLS proxy"),
        Option("--allow-remote-shutdown", "Keep remote shutdown route enabled"),
        Option("--dangerous-bypass-auth", "Disable bearer-token auth on all routes"),
        Option(
            "--log-level", "Server log level", complete_func=Completion(func=LOG_LEVELS)
        ),
        Option("--debug-endpoints", "Mount /api/v1/debug/* routes"),
        Option(
            "--web-title",
            "Custom browser tab title",
            complete_func=Default("title"),
        ),
        Option("--no-open", "Do not open the web UI in the browser"),
    ]
    if not remote_control:
        opts.append(
            Option(
                ("--rc", "--remote-control"),
                "Expose the web UI through Kimi Remote Control",
            )
        )
    return opts


def make_export_command() -> Command:
    cmd = Command("export", "Export a session as a ZIP archive")
    cmd.add_options(
        [
            Option(("-o", "--output"), "Output ZIP path", complete_func=Files()),
            Option(("-y", "--yes"), "Skip previous-session confirmation"),
            Option(
                "--no-include-global-log", "Skip bundling the global diagnostic log"
            ),
            *help_options(),
        ]
    )
    cmd.add_positional_args(Completion(func=list_sessions, ignore_exception=True))
    return cmd


def make_fork_command() -> Command:
    cmd = Command("fork", "Fork a session into a new session")
    cmd.add_options(
        [
            Option(
                "--cwd",
                "Working directory used to find the most recent session",
                complete_func=Files(dir_only=True),
            ),
            Option(("-y", "--yes"), "Skip previous-session confirmation"),
            *help_options(),
        ]
    )
    cmd.add_positional_args(Completion(func=list_sessions, ignore_exception=True))
    return cmd


def make_session_command() -> Command:
    session = Command("session", "Manage sessions non-interactively")
    session.add_options(help_options())

    list_cmd = Command("list", "List sessions, most recently updated first")
    list_cmd.add_options(
        [
            Option(
                "--cwd",
                "List sessions of this working directory",
                complete_func=Files(dir_only=True),
            ),
            Option("--all", "List sessions across every workspace"),
            Option("--archived", "Include archived sessions"),
            Option("--limit", "Print at most n sessions", complete_func=Default("n")),
            Option("--json", "Emit the session summaries as JSON"),
            *help_options(),
        ]
    )

    session.add_sub_commands([list_cmd])
    return session


def make_provider_command() -> Command:
    provider = Command("provider", "Manage LLM providers non-interactively")
    provider.add_options(help_options())

    add = Command("add", "Import providers from a custom registry (api.json)")
    add.add_options(
        [
            Option(
                "--api-key",
                "Registry API key (or KIMI_REGISTRY_API_KEY)",
                complete_func=Default("key"),
            ),
            *help_options(),
        ]
    )
    add.add_positional_args(Default("url"))

    remove = Command("remove", "Remove a provider and its model aliases")
    remove.add_options(help_options())
    remove.add_positional_args(Completion(func=list_providers, ignore_exception=True))

    list_cmd = Command("list", "Show configured providers and model counts")
    list_cmd.add_options([Option("--json", "Emit raw config as JSON"), *help_options()])

    catalog = Command("catalog", "Discover providers from the models.dev catalog")
    catalog.add_options(help_options())

    catalog_list = Command("list", "List catalog providers, or models of a provider")
    catalog_list.add_options(
        [
            Option(
                "--filter",
                "Case-insensitive id/name filter",
                complete_func=Default("substring"),
            ),
            Option("--url", "Override catalog URL", complete_func=Default("url")),
            Option("--json", "Emit catalog slice as JSON"),
            *help_options(),
        ]
    )
    catalog_list.add_positional_args(Default("providerId"))

    catalog_add = Command("add", "Import a catalog provider by id")
    catalog_add.add_options(
        [
            Option(
                "--api-key", "API key for the provider", complete_func=Default("key")
            ),
            Option(
                "--default-model",
                "Mark imported model as default_model",
                complete_func=Default("modelId"),
            ),
            Option("--url", "Override catalog URL", complete_func=Default("url")),
            *help_options(),
        ]
    )
    catalog_add.add_positional_args(Default("providerId"))

    catalog.add_sub_commands([catalog_list, catalog_add])
    provider.add_sub_commands([add, remove, list_cmd, catalog])
    return provider


def make_web_command() -> Command:
    web = Command("web", "Run the local Kimi server and open the web UI")
    web.add_options([*web_options(), *help_options()])

    rotate_token = Command("rotate-token", "Generate a new persistent server token")
    rotate_token.add_options(help_options())

    web.add_sub_commands([rotate_token])
    return web


def make_rc_commands() -> list:
    rc = Command(
        "rc",
        "Run the Kimi server and open the web UI through Remote Control",
    )
    rc.add_options([*web_options(remote_control=True), *help_options()])

    remote = Command("remote", "Alias of rc")
    remote.add_options([*web_options(remote_control=True), *help_options()])
    return [rc, remote]


def make_server_command() -> Command:
    server = Command("server", "Deprecated; use kimi web instead")
    server.add_options(help_options())

    kill = Command(
        "kill", "Stop a background server started by a version before 0.28.0"
    )
    kill.add_options(help_options())

    server.add_sub_commands([kill])
    return server


def make_vis_command() -> Command:
    vis = Command("vis", "Launch the session visualizer in your browser")
    vis.add_options(
        [
            Option(
                "--port",
                "Port to bind (default: auto-pick)",
                complete_func=Default("number"),
            ),
            Option(
                "--host",
                "Host to bind (default: 127.0.0.1)",
                complete_func=Completion(func=COMMON_HOSTS),
            ),
            Option("--no-open", "Do not open the browser automatically"),
            *help_options(),
        ]
    )
    vis.add_positional_args(Completion(func=list_sessions, ignore_exception=True))
    return vis


def make_acp_command() -> Command:
    acp = Command("acp", "Run as an ACP server over stdio")
    acp.add_options(
        [
            Option("--login", "Run device-code login flow then exit"),
            Option(
                "--region",
                "Login region used together with --login",
                complete_func=Completion(func=LOGIN_REGIONS),
            ),
            *help_options(),
        ]
    )
    return acp


def make_kimi_command() -> Command:
    cmd = Command("kimi", "The Starting Point for Next-Gen Agents")
    cmd.add_options(
        [
            Option(("-V", "--version"), "Output the version number"),
            Option(
                ("-S", "--session", "-r", "--resume"),
                "Resume a session (optional id; without id, pick interactively)",
                complete_func=Completion(func=list_sessions, ignore_exception=True),
            ),
            Option(
                ("-c", "--continue"), "Continue the previous session for this directory"
            ),
            Option(("-y", "--yolo"), "Start in Ask When Needed mode"),
            Option("--auto", "Start in Never Ask mode"),
            Option(
                ("-m", "--model"),
                "LLM model alias to use",
                complete_func=Completion(func=list_models, ignore_exception=True),
            ),
            Option(
                ("-p", "--prompt"),
                "Run one prompt non-interactively",
                complete_func=Default("prompt"),
            ),
            Option(
                "--output-format",
                "Output format for prompt mode",
                complete_func=Completion(func=OUTPUT_FORMATS),
            ),
            Option(
                "--skills-dir",
                "Load skills from this directory",
                complete_func=Files(dir_only=True),
                allow_repeat=True,
            ),
            Option(
                "--agent",
                "Agent profile to start the new session with",
                complete_func=Completion(func=list_agents, ignore_exception=True),
            ),
            Option(
                "--agent-file",
                "Load an agent definition from a Markdown file",
                complete_func=Files(pattern="*.md"),
            ),
            Option(
                "--add-dir",
                "Add an additional workspace directory",
                complete_func=Files(dir_only=True),
                allow_repeat=True,
            ),
            Option("--plan", "Start in plan mode"),
            *help_options(),
        ]
    )

    doctor = Command("doctor", "Validate Kimi Code configuration files")
    doctor.add_options(help_options())
    for name in ("config", "tui"):
        sub = Command(name, f"Validate {name}.toml")
        sub.add_options(help_options())
        sub.add_positional_args(Files())
        doctor.add_sub_commands(sub)

    login = Command("login", "Authenticate via the device-code flow")
    login.add_options(help_options())

    migrate = Command("migrate", "Migrate data from legacy kimi-cli")
    migrate.add_options(help_options())

    upgrade = Command("upgrade", "Upgrade Kimi Code to the latest version")
    upgrade.add_options(help_options())
    update = Command("update", "Alias of upgrade")
    update.add_options(help_options())

    cmd.add_sub_commands(
        [
            make_export_command(),
            make_fork_command(),
            make_provider_command(),
            make_session_command(),
            make_acp_command(),
            make_web_command(),
            *make_rc_commands(),
            make_server_command(),
            make_vis_command(),
            login,
            doctor,
            migrate,
            upgrade,
            update,
        ]
    )
    return cmd


if __name__ == "__main__":
    cmd = make_kimi_command()
    print(cmd.complete_source(as_file=True, sort_completion=False))
