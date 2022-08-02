# nav
Create shortcuts for navigating to specific directories.

## Dependencies
This script requires `realpath` which is usually missing from MacOS.

### Homebrew
```
brew install coreutils
```

## Installation
Note that this script needs to be sourced directly so that it can change your
current working directory.
```bash
$ git clone https://github.com/kaybinwang/nav.git
$ cd nav
$ echo "source $(pwd)/nav.sh" >> ~/.bash_profile
```

## Usage
You can use `nav` to create shortcuts to directories that you visit often.
```bash
$ nav add df ~/personal/projects/dotfiles  # create a new shortcut
$ nav to df                                # navigate to the shortcut
```

You can also manage your shortcuts using `nav update` and `nav remove`
```bash
$ nav update df ~/personal/projects/dotfiles  # update the shortcut
$ nav remove df                               # delete the shortcut
```

Finally, you can see what shortcuts you have defined by using `nav list`.
```bash
$ nav list
```

Please refer to `nav help` for more documentation on the commands.

## Configuration
By default, `nav` stores your shortcuts in `~/.config/nav`. However, you can set
your own custom directory by setting the `NAV_PATH` environment variable. For
example,
```bash
export NAV_PATH=/path/to/shortcuts
source /path/to/nav.sh
```

## Testing
We use `shellspec` for testing. This is because it can execute the tests using
`sh` instead of `bash` which gives us higher confidence in our portability.
Furthermore, the framework lets us directly test shell functions instead of
requiring executable scripts.

You can execute the following command to run tests locally.
```
$ docker run -it --rm -v "$PWD:/src" shellspec/shellspec
```

### ARM Issues
Note that `shellspec` currently doesn't have an ARM image which causes runtime
errors when running the tests. This can be fixed by building the image from
source directly.
