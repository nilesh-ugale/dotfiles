
import os
import json
import subprocess
import click
import copy

def _get_src_file(compile_args):
    source_index = compile_args.index('-c') + 1
    source_file = compile_args[source_index]
    if 'external' in source_file:
        return None
    return source_file

def _strip_external(arg):
    if 'external' in arg:
        index = arg.find('C:')
        return arg[index:]

def _get_header(compile_args):
    header = []
    for arg in compile_args:
        if arg.startswith('-I'):
            if not 'bazel' in arg and not 'external' in arg:
                # header.append('-isystem')
                header.append('-I')
                header.append(arg[2:])
        if arg.startswith('-D'):
            if not 'bazel' in arg:
                header.append('-D')
                header.append(arg[2:])
    return header

def _get_compile_cmd(compile_args):
    src_file = _get_src_file(compile_args)
    compile_command = []
    if src_file:
        compile_command.append('-c')
        compile_command.append(src_file)
        compile_command.append('-o')
        compile_command.append(src_file.replace('.c', '.o'))
    return compile_command

@click.command()
@click.argument(
    'target',
    type = click.STRING,
)
@click.option(
    '-pf', '--platform',
    type = click.STRING,
    required = False,
    default = None,
    help = 'C/C++ cross tool to use'
)
def main(target, platform):
    keys = ''
    command = [
        'bazel-7.0.0.exe',
        '--bazelrc=bazel.rc',
        'aquery',
    ]

    command.append(f"mnemonic('(Objc|Cpp)Compile',deps('{target}'))")
    command.append('--include_artifacts=false')
    command.append('--output=jsonproto')
    if platform:
        command.append(f'--platforms={platform}')
    result = subprocess.run(
        command,
        stdout=subprocess.PIPE
    )

    keys = json.loads(result.stdout.decode())
    compile_commands_wsl = []
    compile_commands_windows = []
    wsl_passed = True
    for item in keys['actions']:
        src_file = _get_src_file(item['arguments'])
        if src_file:
            compile_command = {
                "file" : src_file,
                "arguments" : [_strip_external(item['arguments'][0])] + _get_header(item['arguments']) + _get_compile_cmd(item['arguments']),
                "directory" : os.getcwd()
            }
            compile_commands_wsl.append(copy.deepcopy(compile_command))
            
            try:
                wsl_path = compile_command["directory"]
                compile_command["directory"] = subprocess.check_output(
                    ["wslpath", "-m", wsl_path]
                ).decode().strip()
                compile_commands_windows.append(compile_command)
            except:
                wsl_passed = False

    with open('compile_commands.json', 'w') as output_file:
        json.dump(
            compile_commands_wsl,
            output_file,
            indent=2, # Yay, human readability!
            check_circular=False # For speed.
        )

    if wsl_passed:
        file_path = ".cache/compile_commands.json"
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, 'w') as output_file:
            json.dump(
                compile_commands_windows,
                output_file,
                indent=2, # Yay, human readability!
                check_circular=False # For speed.
            )

if __name__ == "__main__":
    main()
