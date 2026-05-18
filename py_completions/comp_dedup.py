from __future__ import annotations

import sys
from importlib.machinery import SourceFileLoader
from importlib.util import module_from_spec, spec_from_loader
from pathlib import Path

from zcompy import Command, Completion, Option
from zcompy.action import Default, Files
from zcompy.parser_command import ParserCommand

SCRIPT_PATH = Path(__file__).resolve().parent.parent / "scripts" / "dedup"
SIZE_VALUES = ("0", "512K", "1M", "10M", "100M", "1G")
CHUNK_SIZE_VALUES = ("64K", "256K", "1M", "4M", "16M")
JOB_VALUES = ("1", "2", "4", "8", "16")


def load_dedup_parser():
    loader = SourceFileLoader("dedup_script", str(SCRIPT_PATH))
    spec = spec_from_loader(loader.name, loader)
    module = module_from_spec(spec)
    sys.modules[loader.name] = module
    spec.loader.exec_module(module)
    return module.build_parser()


def set_option_type(cmd: Command, option_name: str, option_type: str) -> None:
    for option in cmd.options:
        names = {option.names} if isinstance(option.names, str) else set(option.names)
        if option_name in names:
            option.type = option_type
            return


def make_dedup_command() -> Command:
    parser = load_dedup_parser()
    parser_cmd = ParserCommand(parser)
    parser_cmd.add_action_for_options(
        "-e",
        "--exclude",
        "-i",
        "--include",
        "--exclude-dir",
        action=Default("glob pattern"),
    )
    parser_cmd.add_action_for_options(
        "--min-size",
        action=Completion(func=SIZE_VALUES),
    )
    parser_cmd.add_action_for_options(
        "--chunk-size",
        action=Completion(func=CHUNK_SIZE_VALUES),
    )
    parser_cmd.add_action_for_options(
        "-j",
        "--jobs",
        action=Completion(func=JOB_VALUES),
    )
    parser_cmd.add_action_for_options(
        "--prefer",
        action=Files(dir_only=True),
    )

    cmd = parser_cmd.to_command()
    cmd.options.insert(0, Option(("-h", "--help"), "Show help"))
    set_option_type(cmd, "--min-size", "Size")
    set_option_type(cmd, "--chunk-size", "Size")
    cmd.repeat_pos_args = Files()
    return cmd


if __name__ == "__main__":
    cmd = make_dedup_command()
    print(cmd.complete_source(as_file=True, sort_completion=False))
