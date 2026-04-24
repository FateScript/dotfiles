from importlib.machinery import SourceFileLoader
from importlib.util import module_from_spec, spec_from_loader
from pathlib import Path

from zcompy.action import Default, Files
from zcompy.parser_command import ParserCommand

SCRIPT_PATH = Path(__file__).resolve().parent.parent / "scripts" / "dir_diff"


def load_dir_diff_parser():
    loader = SourceFileLoader("dir_diff_script", str(SCRIPT_PATH))
    spec = spec_from_loader(loader.name, loader)
    module = module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.build_parser()


def make_command():
    parser = load_dir_diff_parser()
    parser_cmd = ParserCommand(parser)
    parser_cmd.add_action_for_options("-o", "--output", action=Files())
    parser_cmd.add_action_for_options(
        "-e", "--exclude", "-i", "--include",
        action=Default(),
    )
    parser_cmd.add_action_for_options("--exclude-dir", action=Files(dir_only=True))
    cmd = parser_cmd.to_command()
    cmd.add_positional_args([Files(dir_only=True), Files(dir_only=True)])
    return cmd


if __name__ == "__main__":
    cmd = make_command()
    print(cmd.complete_source(as_file=True, sort_completion=False))
