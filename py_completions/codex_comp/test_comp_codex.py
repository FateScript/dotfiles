import json

import comp_codex


def test_list_sessions_uses_session_id_and_first_user_prompt(tmp_path, monkeypatch, capsys):
    codex_home = tmp_path / "codex-home"
    sessions_dir = codex_home / "sessions" / "2026" / "05" / "14"
    sessions_dir.mkdir(parents=True)
    session_file = sessions_dir / "rollout-2026-05-14T15-04-15-019e254c-de83-79b3-9b2d-b3ec884b4a33.jsonl"
    records = [
        {
            "timestamp": "2026-05-14T07:04:15.235Z",
            "type": "session_meta",
            "payload": {
                "id": "019e254c-de83-79b3-9b2d-b3ec884b4a33",
                "timestamp": "2026-05-14T07:04:15.235Z",
                "cwd": "/home/wangfeng02/moon_utils",
            },
        },
        {
            "timestamp": "2026-05-14T07:04:15.235Z",
            "type": "response_item",
            "payload": {
                "type": "message",
                "role": "user",
                "content": [{"type": "input_text", "text": "<environment_context>\n</environment_context>"}],
            },
        },
        {
            "timestamp": "2026-05-14T07:04:15.735Z",
            "type": "response_item",
            "payload": {
                "type": "message",
                "role": "user",
                "content": [
                    {
                        "type": "input_text",
                        "text": "# AGENTS.md instructions for /repo\n<INSTRUCTIONS>\n...\n</INSTRUCTIONS>",
                    }
                ],
            },
        },
        {
            "timestamp": "2026-05-14T07:04:16.235Z",
            "type": "event_msg",
            "payload": {
                "type": "user_message",
                "message": (
                    "参考 lpc_tweak 里面的 comp_tweak.py 和 completions 下面的文件夹的各种comp.py，"
                    "以 /home/wangfeng02/zcompy 为base，写一下codex的comp ，命名为comp_codex.py"
                ),
            },
        },
    ]
    session_file.write_text("\n".join(json.dumps(record) for record in records) + "\n")
    monkeypatch.setenv("CODEX_HOME", str(codex_home))

    comp_codex.list_sessions()

    output = capsys.readouterr().out.strip()
    assert output == (
        "019e254c-de83-79b3-9b2d-b3ec884b4a33 "
        "参考 lpc_tweak 里面的 comp_tweak.py 和 completions 下面的文件夹的各种comp.py，"
        "以 /home/wangfeng02/zcompy 为base，写一下codex的comp ，命名为comp_codex.py"
    )
