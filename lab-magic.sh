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
touch .lab.states

start_time=$SECONDS

trap on_exit exit

function on_exit {
  elapsed_time=$(($SECONDS - $start_time))
  logger::info "Total elapsed time: $elapsed_time seconds"
}

function s {
  local task_dirs=($(ls -d -1 docs/*/))
  
  for task_dir in ${task_dirs[@]}; do
    print_state $task_dir
    #
    local step_dirs=($(ls -1 $task_dir* | grep -v README))
    for step_dir in ${step_dirs[@]}; do
      print_state $step_dir
    done
  done
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

function e {
  local need_clean=0
  local POSITIONAL=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --clean)
      need_clean=1
      shift
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
    esac
  done

  local task=${POSITIONAL[0]}
  local step=${POSITIONAL[1]}
  local method="i"
  if [[ -n $task && -z $step ]]; then
    method="$task"
  elif [[ -n $task && -n $step ]]; then
    method="$task-$step"
  fi

  if type $method &>/dev/null ; then
    if [[ $need_clean == 1 ]]; then
      # hide the evidence
      clear
    fi

    if [[ -n $task && -n $step ]]; then
      sed -e "s/^*/?/g" .lab.states > .lab.states.tmp
      mv .lab.states{.tmp,}

      if cat .lab.states | grep -q -e "^.\? $task $step"; then
        sed -e "s/^? $task $step/* $task $step/g" \
            -e "s/^v $task $step/* $task $step/g" \
          .lab.states > .lab.states.tmp
        mv .lab.states{.tmp,}
      else
        echo "* $task $step" >> .lab.states
      fi
    fi

    if type $method-before &>/dev/null && ! $method-before; then
      logger::error "Start task or step failed because it does not pass the pre-condition check!"
    fi

    if $method && [[ -n $task && -n $step ]]; then
      sed -e "s/^* $task $step/v $task $step/g" .lab.states > .lab.states.tmp
      mv .lab.states{.tmp,}
    fi

    # show a prompt so as not to reveal our true nature after
    # the demo has concluded
    # p "# Press Enter key to exit..."
  else
    logger::warn "Unknown task or step: ${POSITIONAL[@]}"
  fi
}

function a {
  prompt "$@"
  while [[ -z $(eval echo \$$2) ]]; do
    prompt "$@"
  done

  store_settings "$2" "$(eval echo \$$2)"
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

function store_settings {
  sed -e "s/^$1=.*/$1=$2/g" .lab.settings > .lab.settings.tmp
  mv .lab.settings{.tmp,}
}

DONE_COLOR="\033[0;36m"
QUES_COLOR="\033[0;33m"
CURR_COLOR="\033[1;37m"

function print_state {
  local task=${1#*/}
  task=${task%/*}

  local step=${1##*/}
  step=${step%.md}

  local file=$1
  if [[ -n $task && -z $step ]]; then
    file="$1/README.md"
  fi

  local head_line="$(head -n 1 $file)"

  if [[ $head_line =~ ^#" " ]]; then
    local state
    if [[ -n $task && -n $step ]] && cat .lab.states | grep -q -e "^.\? $task $step"; then
      state=$(cat .lab.states | grep -e "^.\? $task $step")
      state=${state% $task $step}
      head_line=$(echo $head_line | sed -e "s/^#/$state/g")
    else
      head_line=$(echo $head_line | sed -e "s/^#/ /g")
    fi

    case $state in
    "*")
      echo -e "$CURR_COLOR$head_line$COLOR_RESET";;
    "v")
      echo -e "$DONE_COLOR$head_line$COLOR_RESET";;
    "?")
      echo -e "$QUES_COLOR$head_line$COLOR_RESET";;
    *)
      echo "$head_line";;
    esac
  fi
}
