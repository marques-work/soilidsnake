#!/bin/bash

# Prevent people from sourcing this file.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
  printf "This file must not be sourced; please execute it with your shell\n" >&2
  return 1
fi

# Fail script on uncaught errors
set -e

function bootstrap() {
  if ! (exist pyenv); then
    install_pyenv
    modified_shell_env="yes"
  fi

  # ensure the correct python version is installed
  pyenv install --skip-existing

  if ! (exist pipenv); then
    install_pipenv
    modified_shell_env="yes"
  fi

  # ensure we install all dependencies
  pipenv sync
}

# installs pyenv by first trying homebrew and falling back to manual
# installation if `brew` is not available
function install_pyenv() {
  if (exist brew); then
    info "Installing pyenv using Homebrew"
    brew install pyenv
  else
    # do it the hard way
    if !(exist git); then
      die "You MUST have \`git\` installed!"
    fi

    if [ -d "$HOME/.pyenv" ]; then
      die "Looks like you've tried to install \`pyenv\` before?\n\nFound an existing directory at: $HOME/.pyenv\n\n" \
        "Please remove (and backup, if you want) this directory and try running this script again."
    fi

    info "Cloning the \`pyenv\` repo"
    if !(git clone "https://github.com/pyenv/pyenv.git" "$HOME/.pyenv"); then
      die "Failed to clone the \`pyenv\` repo. Aborting."
    fi

    append_to_profile_if_no_such_line "export PYENV_ROOT=~/.pyenv"
    append_to_profile_if_no_such_line "export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
  fi

  if ! (line_in_profile "eval \"\$(pyenv init -)\""); then
    append_to_profile "if (type pyenv &> /dev/null); then\n  eval \"\$(pyenv init -)\"\nfi"
  fi

  # also execute in the current process for immediate effect
  # for the duration of this script
  eval "$(pyenv init -)"
}

# installs pipenv by first trying homebrew and falling back to manual
# installation if `brew` is not available
#
# ASSUMES `pip` is installed by `pyenv` or that it came with your
# python version (recent versions include it by default)
function install_pipenv() {
  if (exist brew); then
    info "Installing pipenv using Homebrew"
    brew install pipenv
  else
    if ! (exist pip); then
      die "Uh-oh! \`pip\` is not resolvable or installed\! It *should* have come with\n" \
        "\`python\`, so please fix this yourself (check your \$PATH or reinstall \`python\`)."
    fi

    pip install --user pipenv

    local user_base_bin="$(python -m site --user-base)/bin"
    mkdir -p "$user_base_bin"

    append_to_profile_if_no_such_line "export PATH=\"$user_base_bin:\$PATH\""
  fi

  append_to_profile_if_no_such_line "export PIPENV_PYTHON=\"\$(pyenv root)/shims/python\""
}

function append_to_profile_if_no_such_line() {
  local line="$1"
  if ! (line_in_profile "$line"); then
    append_to_profile "$line"
  fi

  if (printf "$line" | grep -q "^export "); then
    # also execute in the current process for immediate effect
    # for the duration of this script
    eval "$line"
  fi
}

# detects whether a line exists in the user's profile
function line_in_profile() {
  grep -v "[[:blank:]]*#[[:blank:]]*" "$(profile_file)" | grep -q -F "$*"
  return $?
}

# appends a line to the user's profile
function append_to_profile() {
  printf "$*\n" >> "$(profile_file)"
}

# Returns a best guess as to which profile file to use based on the shell
# When zsh, use ~/.zsh
# When bash, use ~/.bash_profile
#   - Creates a generic ~/.bash_profile if it does not exist that sources
#     ~/.bashrc and ~/.profile if found
# When any other shell, use ~/.profile
#
# This function is idempotent, so it may (more like, /will/) be called
# successively without side effects.
function profile_file() {
  if [ -z "$BASH_VERSION" ]; then
    if [ -n "$ZSH_VERSION" ]; then
      printf "$HOME/.zshrc";
    else
      warn "This script only supports bash and (theoretically) zsh. Couldn't identify your shell, so using ~/.profile"
      printf "$HOME/.profile"
    fi
    return
  fi

  if [ ! -r "$HOME/.bash_profile" ]; then
    cat <<-RC >> "$HOME/.bash_profile"
if [ -r ~/.bashrc ]; then
  source ~/.bashrc
fi
RC
    if [ -r "$HOME/.profile" ]; then
      cat <<-RC >> "$HOME/.bash_profile"
if [ -r ~/.profile ]; then
  source ~/.profile
fi
RC
    fi
    # set explicit permissions in case the user's `umask` is not the default `022`
    chmod 644 "$HOME/.bash_profile"
  fi
  printf "$HOME/.bash_profile"
}

function explain_restart_shell() {
  warn "\n\n" \
    "*************************************************************************************************\n" \
    "  This script has made changes to your shell environment, so you should probably restart your\n" \
    "  shell by closing this terminal session and opening a new one.\n" \
    "*************************************************************************************************"
}

# Like `/bin/echo`, but uses the more reliable bash `printf` builtin
# which can handle escape characters in a cross-platform way
function info() {
  printf "$*\n"
}

# Outputs message to STDERR
function warn() {
  info "$*" >&2
}

# prints message to STDERR and exits with failure code
function die() {
  warn "$*"
  exit 1
}

# tests if an alias, function, or command is available
function exist() {
  local cmd="$1"
  type "$cmd" &> /dev/null
  return $?
}

modified_shell_env="no"

bootstrap

if [ $# -ne 0 ]; then
  eval "pipenv run python $@"
  code=$?

  if [ "yes" = "$modified_shell_env" ]; then
    explain_restart_shell
  fi

  exit $code
else
  info "Setup complete."

  if [ "yes" = "$modified_shell_env" ]; then
    explain_restart_shell
  fi
fi
