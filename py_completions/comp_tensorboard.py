from zcompy import Command, Completion, Default, Files, Option


BOOL_VALUES = ("true", "false", "True", "False", "1", "0")
LOAD_FAST_VALUES = ("auto", "true", "false")
GRPC_CREDS_TYPES = ("local", "ssl", "ssl_dev")
RELOAD_TASK_TYPES = ("auto", "process", "blocking")
GENERIC_DATA_TYPES = ("auto", "true", "false")
COMMON_HOSTS = ("localhost", "127.0.0.1", "0.0.0.0")


def random_available_ports():
    import random
    import socket

    ports = set()
    attempts = 0
    while len(ports) < 5 and attempts < 100:
        attempts += 1
        port = random.randint(10001, 65535)
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
                sock.bind(("127.0.0.1", port))
        except OSError:
            continue
        ports.add(port)

    for port in sorted(ports):
        print(port)


def tensorboard_options():
    return [
        Option(("-h", "--help"), "Show help"),
        Option("--helpfull", "Show full help"),
        Option("--logdir", "TensorBoard log directory", complete_func=Files(dir_only=True)),
        Option("--logdir_spec", "Named log directory specification", complete_func=Default("logdir spec")),
        Option("--host", "Host to listen on", complete_func=Completion(func=COMMON_HOSTS)),
        Option("--bind_all", "Listen on all public interfaces"),
        Option("--port", "Port to serve TensorBoard on", complete_func=Completion(func=random_available_ports, ignore_exception=True)),
        Option("--reuse_port", "Enable SO_REUSEPORT", complete_func=Completion(func=BOOL_VALUES)),
        Option("--load_fast", "Fast data loading mode", complete_func=Completion(func=LOAD_FAST_VALUES)),
        Option("--extra_data_server_flags", "Extra data server flags", complete_func=Default("flags")),
        Option("--grpc_creds_type", "gRPC credentials type", complete_func=Completion(func=GRPC_CREDS_TYPES)),
        Option("--grpc_data_provider", "gRPC data provider port", complete_func=Default("port")),
        Option("--purge_orphaned_data", "Purge orphaned data", complete_func=Completion(func=BOOL_VALUES)),
        Option("--db", "SQL database URI", complete_func=Files()),
        Option("--db_import", "Import event files into DB"),
        Option("--inspect", "Inspect event files"),
        Option("--version_tb", "Print TensorBoard version"),
        Option("--tag", "Tag to query with inspect", complete_func=Default("tag")),
        Option("--event_file", "Event file to inspect", complete_func=Files()),
        Option("--path_prefix", "URL path prefix", complete_func=Default("path prefix")),
        Option("--window_title", "Browser window title", complete_func=Default("title")),
        Option("--max_reload_threads", "Maximum reload threads", complete_func=Completion(func=("1", "2", "4", "8"))),
        Option("--reload_interval", "Reload interval seconds", complete_func=Completion(func=("0", "1", "5", "10", "30", "60"))),
        Option("--reload_task", "Background reload task", complete_func=Completion(func=RELOAD_TASK_TYPES)),
        Option("--reload_multifile", "Poll multiple event files", complete_func=Completion(func=BOOL_VALUES)),
        Option(
            "--reload_multifile_inactive_secs",
            "Inactive event file threshold seconds",
            complete_func=Completion(func=("0", "3600", "86400", "-1")),
        ),
        Option("--generic_data", "Generic data provider mode", complete_func=Completion(func=GENERIC_DATA_TYPES)),
        Option(
            "--samples_per_plugin",
            "Plugin sample limits",
            complete_func=Completion(func=("scalars=1000", "images=10", "histograms=500")),
        ),
        Option("--detect_file_replacement", "Detect replaced event files", complete_func=Completion(func=BOOL_VALUES)),
    ]


def make_tensorboard_command() -> Command:
    cmd = Command("tensorboard", "TensorBoard visualization server")
    cmd.add_options(tensorboard_options())

    serve_cmd = Command("serve", "Start local TensorBoard server")
    serve_cmd.add_options(tensorboard_options())

    cmd.add_sub_commands([serve_cmd])
    return cmd


if __name__ == "__main__":
    cmd = make_tensorboard_command()
    print(cmd.complete_source(as_file=True, sort_completion=False))
