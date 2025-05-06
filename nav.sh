# shellcheck shell=sh

if [ -z "$NAV_PATH" ]; then
  NAV_PATH="$HOME/.config/nav"
fi

__nav_print_help() {
  cat <<EOM
usage: nav <command> [<args>]

A tool for managing shortcuts to frequently visited directories.

These are the available commands:

    add         Add a new shortcut to a directory
    update      Update an existing shortcut to a different directory
    remove      Remove an existing shortcut
    list        List all the shortcuts
    to          Navigate to a directory using the provided shortcut
    help        Output additional information about a specific command

See 'nav help <command>' to read about a specific command.
EOM
}

__nav_print_help_add() {
  cat <<EOM
usage: nav add <shortcut> <directory>

Add a new shortcut to the provided directory.
EOM
}

__nav_print_help_update() {
  cat <<EOM
usage: nav update <shortcut> <directory>

Update an existing shortcut to the provided directory.
EOM
}

__nav_print_help_remove() {
  cat <<EOM
usage: nav remove <shortcut>

Remove an existing shortcut.
EOM
}

__nav_print_help_list() {
  cat <<EOM
usage: nav list

Output all of the shortcuts.
EOM
}

__nav_print_help_to() {
  cat <<EOM
usage: nav to <shortcut>

Navigate to the directory under the provided shortcut.
EOM
}

__nav_cmd_help() {
  subcommand="$1"
  if [ -z "$subcommand" ]; then
    __nav_print_help
    return 1
  fi
  shift
  case "$subcommand" in
    add)
      __nav_print_help_add "$@"
      ;;
    update)
      __nav_print_help_update "$@"
      ;;
    remove)
      __nav_print_help_remove "$@"
      ;;
    list)
      __nav_print_help_list "$@"
      ;;
    to)
      __nav_print_help_to "$@"
      ;;
    *)
      echo "Unrecognized command: $subcommand."
      __nav_print_help
      return 1
      ;;
  esac
}

__nav_cmd_list() {
  if [ ! -e "$NAV_PATH" ]; then
    return 0
  fi
  find "$NAV_PATH" -maxdepth 1 -type l | sort -n | while read -r shortcut; do
    echo "$(basename "$shortcut") -> $(realpath "$shortcut")"
  done
}

__nav_cmd_to() {
  shortcut="$1"
  if [ -z "$shortcut" ]; then
    echo "Please provide a shortcut."
    __nav_print_help_to
    return 1
  fi
  dst="$(realpath "$NAV_PATH/$shortcut")"
  if [ ! -e "$dst" ]; then
    echo "Shortcut '$shortcut' not found."
    return 1
  fi
  if [ ! -d "$dst" ]; then
    echo "Error: $dst is not a directory."
    return 1
  fi
  cd "$dst"
}

__nav_cmd_remove() {
  shortcut="$1"
  if [ -z "$shortcut" ]; then
    echo "Please provide a shortcut."
    __nav_print_help_remove
    return 1
  fi

  symlink="$NAV_PATH/$shortcut"
  if [ ! -e "$symlink" ]; then
    echo "$shortcut is not a shortcut."
    return 1
  fi
  if [ ! -L "$symlink" ]; then
    echo "Error: $symlink is not a symlink."
    return 1
  fi

  rm "$symlink"
}

__nav_cmd_update() {
  echo "not implemented"
  return 1
}

__nav_cmd_add() {
  shortcut="$1"
  directory="$2"
  if [ -z "$shortcut" ] || [ -z "$directory" ]; then
    echo "Please provide a shortcut and a directory."
    __nav_print_help_add
    return 1
  fi

  src="$(realpath "$directory")"
  if [ $? -ne 0 ]; then
    echo "Error: could not resolve the absolute path for $directory."
    return 1
  fi
  if [ ! -d "$src" ]; then
    echo "Error: $directory is not a directory."
    return 1
  fi

  dst="$NAV_PATH/$shortcut"
  if [ -e "$dst" ]; then
    echo "Error: $shortcut already exists."
    return 1
  fi

  mkdir -p "$NAV_PATH" >/dev/null 2>&1

  ln -s "$src" "$dst"
  rv="$?"
  if [ $rv -ne 0 ]; then
    echo "Error: unable to add a shortcut from $shortcut to $directory."
    return 1
  fi
  echo "Added a shortcut from $shortcut to $src!"
}

nav() {
  if [ -z "$NAV_PATH" ]; then
    echo "Error: NAV_PATH is not set."
    return 1
  fi
  subcommand="$1"
  if [ -z "$subcommand" ]; then
    __nav_print_help
    return 1
  fi
  shift
  case "$subcommand" in
    add)
      __nav_cmd_add "$@"
      ;;
    update)
      __nav_cmd_update "$@"
      ;;
    remove)
      __nav_cmd_remove "$@"
      ;;
    list)
      __nav_cmd_list "$@"
      ;;
    to)
      __nav_cmd_to "$@"
      ;;
    help)
      __nav_cmd_help "$@"
      ;;
    *)
      echo "Unrecognized command: $subcommand."
      __nav_print_help
      return 1
      ;;
  esac
  return "$?"
}
