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
  local -r subcommand="$1"
  if [ -z "$subcommand" ]; then
    __nav_print_help
    return 1
  fi
  case "$subcommand" in
    add)
      __nav_print_help_add "${@:2}"
      ;;
    update)
      __nav_print_help_update "${@:2}"
      ;;
    remove)
      __nav_print_help_remove "${@:2}"
      ;;
    list)
      __nav_print_help_list "${@:2}"
      ;;
    to)
      __nav_print_help_to "${@:2}"
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
    echo "$(basename "$1") -> $(realpath "$1")"
  done
}

__nav_cmd_to() {
  local -r shortcut="$1"
  if [ -z "$shortcut" ]; then
    echo "Please provide a shortcut."
    __nav_print_help_to
    return 1
  fi
  local -r dst="$(realpath "$NAV_PATH/$shortcut")"
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
  local -r shortcut="$1"
  if [ -z "$shortcut" ]; then
    echo "Please provide a shortcut."
    __nav_print_help_remove
    return 1
  fi

  local -r symlink="$NAV_PATH/$shortcut"
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
  local -r shortcut="$1"
  local -r directory="$2"
  if [ -z "$shortcut" ] || [ -z "$directory" ]; then
    echo "Please provide a shortcut and a directory."
    __nav_print_help_add
    return 1
  fi

  local -r src="$(realpath "$directory")"
  if [ $? -ne 0 ]; then
    echo "Error: could not resolve the absolute path for $directory."
    return 1
  fi
  if [ ! -d "$src" ]; then
    echo "Error: $directory is not a directory."
    return 1
  fi

  local -r dst="$NAV_PATH/$shortcut"
  if [ -e "$shortcut" ]; then
    echo "Error: $shortcut already exists."
    return 1
  fi

  mkdir -p "$NAV_PATH" &>/dev/null

  ln -s "$src" "$dst"
  local -r rv="$?"
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
  local -r subcommand="$1"
  if [ -z "$subcommand" ]; then
    __nav_print_help
    return 1
  fi
  case "$subcommand" in
    add)
      __nav_cmd_add "${@:2}"
      ;;
    update)
      __nav_cmd_update "${@:2}"
      ;;
    remove)
      __nav_cmd_remove "${@:2}"
      ;;
    list)
      __nav_cmd_list "${@:2}"
      ;;
    to)
      __nav_cmd_to "${@:2}"
      ;;
    help)
      __nav_cmd_help "${@:2}"
      ;;
    *)
      echo "Unrecognized command: $subcommand."
      __nav_print_help
      return 1
      ;;
  esac
  return "$?"
}
