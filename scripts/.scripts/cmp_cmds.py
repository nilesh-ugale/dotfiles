
import os
import json
import subprocess
import click

def _get_src_file(compile_args):
    source_index = compile_args.index('-c') + 1
    source_file = compile_args[source_index]

    return source_file


def _strip_external(arg):
    if 'external' in arg:
        index = arg.find('C:')
        return arg[index:]


def _get_header(compile_args):
    header = []
    for arg in compile_args:
        if arg.startswith('-I'):
            if not 'bazel' in arg:
                header.append('-isystem')
                header.append(arg[2:])
    return header

def _get_compile_cmd(compile_args):
    src_file = _get_src_file(compile_args)
    compile_command = []
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
    compile_commands = []
    for item in keys['actions']:
        compile_commands.append({
            "file" : _get_src_file(item['arguments']),
            "arguments" : [_strip_external(item['arguments'][0])] + _get_header(item['arguments']) + _get_compile_cmd(item['arguments']),
            "directory" : os.getcwd()
        })

    with open('compile_commands.json', 'w') as output_file:
        json.dump(
            compile_commands,
            output_file,
            indent=2, # Yay, human readability!
            check_circular=False # For speed.
        )

if __name__ == "__main__":
    main()
