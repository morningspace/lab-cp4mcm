#!/bin/bash

########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
TYPE_SPEED=100

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W "

#
# custom colors
#
DEMO_CMD_COLOR="\033[0;37m"
DEMO_COMMENT_COLOR=$CYAN

# put your demo awesomeness here
start_time=$SECONDS

trap on_exit exit

function on_exit {
  elapsed_time=$(($SECONDS - $start_time))
  logger::info "Total elapsed time: $elapsed_time seconds"
}

function i {
  local task=$1
  local step=$2
  local file="docs/README.md"
  if [[ -n $task && -z $step ]]; then
    file="docs/$task/README.md"
  elif [[ -n $task && -n $step ]]; then
    file="docs/$task/$step.md"
  fi

  p "$(head -n 1 $file)"
  sed -e '1d' < $file
  echo
}

function launch {
  local task=$1
  local step=$2
  local method="i"
  if [[ -n $task && -z $step ]]; then
    method="$task"
  elif [[ -n $task && -n $step ]]; then
    method="$task-$step"
  fi

  if type $method &>/dev/null ; then
    # hide the evidence
    clear

    "$method"

    # show a prompt so as not to reveal our true nature after
    # the demo has concluded
    # p "# Press Enter key to exit..."
  else
    logger::warn "Unknown task or step"
  fi
}

function logger::info {
  # Cyan
  printf "\033[0;36mINFO\033[0m $@\n"
}

function logger::warn {
  # Yellow
  printf "\033[0;33mWARN\033[0m $@\n"
}

function logger::error {
  # Red
  printf "\033[0;31mERRO\033[0m $@\n"
  exit 1
}

function a {
  prompt "$@"
  while [[ -z $(eval echo \$$2) ]]; do
    prompt "$@"
  done
}

function prompt {
  echo -n -e "\033[0;36m? \033[0;37m$1\033[0m"

  local sample=$(eval echo \$$2)
  if [[ -n $sample ]]; then
    echo -n -e "($sample): "
  else
    echo -n -e ": "
  fi

  local input
  read -r input
  if [[ -n $input ]]; then
    eval $2=\'$input\'
  else
    return 1
  fi
}
