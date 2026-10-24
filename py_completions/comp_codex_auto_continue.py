from __future__ import annotations

from zcompy import Command, Default, DependentCompletion, Files, Option


def list_session_ids(codex_home):
    """Complete titled thread IDs from the selected Codex home."""
    import json
    import os
    import sqlite3
    from pathlib import Path

    home = Path(codex_home or os.environ.get("CODEX_HOME", "~/.codex")).expanduser()
    sessions_dir = home / "sessions"
    if not sessions_dir.exists():
        return

    titles = {}
    updated_at = {}
    try:
        database = sqlite3.connect(f"file:{home / 'state_5.sqlite'}?mode=ro", uri=True)
        try:
            rows = database.execute(
                """
                SELECT
                    id,
                    COALESCE(NULLIF(name, ''), title),
                    COALESCE(NULLIF(updated_at_ms, 0), updated_at * 1000)
                FROM threads
                """
            )
            for session_id, title, timestamp in rows:
                titles[session_id] = title or ""
                updated_at[session_id] = timestamp or 0
        finally:
            database.close()
    except Exception:
        pass

    try:
        index_lines = (
            (home / "session_index.jsonl").read_text(encoding="utf-8").splitlines()
        )
    except Exception:
        index_lines = []

    indexed = set()
    for line in reversed(index_lines):
        try:
            record = json.loads(line)
        except Exception:
            continue
        session_id = record.get("id")
        if session_id and session_id not in indexed:
            titles[session_id] = record.get("thread_name") or ""
            indexed.add(session_id)

    sessions = {}
    for session_file in sessions_dir.rglob("rollout-*.jsonl"):
        session_id = session_file.stem.removeprefix("rollout-")
        try:
            with session_file.open(encoding="utf-8") as stream:
                for line in stream:
                    event = json.loads(line)
                    payload = event.get("payload") or {}
                    if event.get("type") == "session_meta":
                        session_id = (
                            payload.get("id")
                            or event.get("session_meta", {}).get("id")
                            or session_id
                        )
                        break
        except Exception:
            continue

        try:
            modified_at = int(session_file.stat().st_mtime * 1000)
        except OSError:
            modified_at = 0
        previous = sessions.get(session_id)
        if previous is None or modified_at > previous:
            sessions[session_id] = modified_at

    ordered_sessions = sorted(
        sessions,
        key=lambda session_id: (
            updated_at.get(session_id, sessions[session_id]),
            session_id,
        ),
        reverse=True,
    )
    for session_id in ordered_sessions:
        title = " ".join(titles.get(session_id, "").split())[:100]
        title = title.replace(":", "\\:")
        print(f"{session_id} {title}".rstrip())


def make_codex_auto_continue_command() -> Command:
    cmd = Command("codex-auto-continue", "在 Codex 限额重置后发送继续")
    cmd.add_options(
        [
            Option(
                "--thread-id",
                "目标 Codex thread ID",
                complete_func=DependentCompletion(
                    list_session_ids,
                    depends_on="--codex-home",
                    ignore_exception=True,
                ),
            ),
            Option("--cwd", "用于自动选择会话的工作目录", complete_func=Files(dir_only=True)),
            Option("--codex-home", "Codex 数据目录", complete_func=Files(dir_only=True)),
            Option("--message", "要发送的消息", complete_func=Default()),
            Option("--grace-seconds", "重置后额外等待秒数", complete_func=Default()),
            Option("--max-retries", "限额重试次数", complete_func=Default()),
            Option("--dry-run", "只读取信息，不发送消息"),
            Option("--send-now", "不等待限额，立即发送消息"),
            Option(
                "--app-server-command",
                "启动 app-server 的命令参数",
                complete_func=Default(),
                allow_repeat=True,
            ),
            Option(("-h", "--help"), "显示帮助"),
        ]
    )
    return cmd


if __name__ == "__main__":
    cmd = make_codex_auto_continue_command()
    try:
        source = cmd.complete_source(as_file=True, sort_completion=False)
    except TypeError:
        source = cmd.complete_source(as_file=True)
        source = source.replace(
            "#compdef codex-auto-continue",
            "#compdef codex-auto-continue\n"
            "zstyle ':completion:*:codex-auto-continue:*' sort false",
            1,
        )
    print(source)
