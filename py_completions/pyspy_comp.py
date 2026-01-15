from zcompy import Command, Completion, Files, Option
from zcompy.action.action import ProcessID

pid_option = Option(
    ("-p", "--pid"), "PID of a running python program to spy on, in decimal or hex",
    complete_func=ProcessID(),
)
full_filenames_option = Option(
    ("--full-filenames",),
    "Show full Python filenames, instead of shortening to show only the package part"
)
rate_option = Option(
    ("-r", "--rate"), "The number of samples to collect per second",
    complete_func=Completion(func=("100", "200", "500", "1000")),
)
subproecss_option = Option(("-s", "--subprocesses"), "Profile subprocesses of the original process")
gil_option = Option(("-g", "--gil"), "Only include traces that are holding on to the GIL")
idle_option = Option(("-i", "--idle"), "Include stack traces for idle threads")
nonblocking_option = Option(
    ("--nonblocking",),
    "Don't pause the python process when collecting samples. Setting this "
    "option will reduce the performance impact of sampling, but may lead to "
    "inaccurate results"
)
help_option = Option(("-h", "--help"), "Print help information")


def create_dump_subcommand() -> Command:
    dump_cmd = Command("dump", "Dumps stack traces for a target program to stdout")

    dump_cmd.add_options([
        pid_option,
        Option(
            ("-c", "--core"),
            "Filename of coredump to display python stack traces from",
            complete_func=Files(),
        ),
        full_filenames_option,
        Option(
            ("-l", "--locals"),
            "Show local variables for each frame. Passing multiple times (-ll) increases verbosity"
        ),
        Option(("-j", "--json"), "Format output as JSON"),
        subproecss_option,
        nonblocking_option,
        help_option,
    ])
    return dump_cmd


def create_top_subcommand() -> Command:
    top_cmd = Command("top", "Displays a top like view of functions consuming CPU")

    top_cmd.add_options([
        pid_option,
        rate_option,
        subproecss_option,
        full_filenames_option,
        gil_option,
        idle_option,
        Option(
            ("--delay",), "Delay between top refreshes",
            complete_func=Completion(func=("1.0", "0.5", "2.0"))
        ),
        nonblocking_option,
        help_option,
    ])
    return top_cmd


def create_record_subcommand() -> Command:
    record_cmd = Command("record", "Records stack trace information to a flamegraph, speedscope or raw file")

    # Add options specific to the 'record' subcommand
    record_cmd.add_options([
        pid_option,
        full_filenames_option,
        Option(("-o", "--output"), "Output filename", complete_func=Files()),
        Option(
            ("-f", "--format"), "Output file format",
            complete_func=Completion(func=("flamegraph", "raw", "speedscope", "chrometrace")),
        ),
        Option(
            ("-d", "--duration"), "The number of seconds to sample for",
            complete_func=Completion(func=("unlimited", "10", "30", "60", "300", "600")),
        ),
        rate_option,
        subproecss_option,
        Option(("-F", "--function"), "Aggregate samples by function's first line number, instead of current line number"),
        Option(("--nolineno",), "Do not show line numbers"),
        Option(("-t", "--threads"), "Show thread ids in the output"),
        gil_option,
        idle_option,
        nonblocking_option,
        help_option,
    ])

    return record_cmd


def create_pyspy_command() -> Command:
    """Create pyspy command with all options and completions."""
    pyspy_cmd = Command("py-spy", "Sampling profiler for Python programs")

    pyspy_cmd.add_options([
        Option(("-V", "--version"), "Print version information"),
        help_option,
    ])

    record_cmd = create_record_subcommand()
    top_cmd = create_top_subcommand()
    dump_cmd = create_dump_subcommand()
    help_cmd = Command("help", "Print this message or the help of the given subcommand(s)")

    pyspy_cmd.add_sub_commands([record_cmd, top_cmd, dump_cmd, help_cmd])
    return pyspy_cmd


if __name__ == "__main__":
    cmd = create_pyspy_command()
    print(cmd.complete_source(as_file=True, sort_completion=False))
