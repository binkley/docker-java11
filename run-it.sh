#!/usr/bin/env bash

export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

set -e
set -u
set -o pipefail

readonly progname="${0##*/}"
readonly name=docker-java11
readonly version=0-SNAPSHOT

: "${LINES:=$(tput lines)}"
export LINES
: "${COLUMNS:=$(tput cols)}"
export COLUMNS

fmt=fmt
readonly fmt_width=$((COLUMNS - 5))
function -setup-terminal {
    if [[ ! -t 1 ]]
    then
        readonly fmt=cat
        return 0
    fi

    if (( fmt_width < 10 ))
    then
        echo "$progname: Your terminal is too narrow." >&2
        readonly fmt=cat
        return 0
    fi

    fmt="fmt -w $fmt_width"
    readonly fmt
}

function -setup-colors {
    local -r ncolors=$(tput colors)

    if $color && (( ${ncolors-0} > 7 ))
    then
        printf -v pgreen "$(tput setaf 2)"
        printf -v preset "$(tput sgr0)"
    else
        pgreen=''
        preset=''
    fi
    readonly pgreen
    readonly preset
}

function -maybe-debug {
    case $debug in
    0 ) debug=false ;;
    1 ) debug=true ;;
    * ) debug=true ; set -x ;;
    esac
}

function -print-usage {
    cat <<EOU | $fmt
Usage: $progname [OPTION]... [TASK]...
EOU
}

function -print-help {
    echo "$progname, version $version"
    -print-usage
    cat <<EOH

Options:
  -c, --color     Print in color
      --no-color  Print without color
  -d, --debug     Print debug output while running.  Repeat for more output
  -h, --help      Print help and exit normally
  -n, --dry-run   Do nothing (dry run); echo actions
  -v, --verbose   Verbose output

Tasks:
EOH

    for task in "${tasks[@]}"
    do
        local help_fn="-$task-help"
        echo "  * $task"
        if declare -F -- $help_fn >/dev/null 2>&1
        then
            $help_fn | -format-help
        fi
    done
}

function -format-help {
    $fmt -w $((fmt_width - 8)) | sed 's/^/       /'
}

function -find-in-tasks {
    local cmd="$1"
    for task in "${tasks[@]}"
    do
        [[ "$cmd" == "$task" ]] && return 0
    done
    return 1
}

run=''
case $(uname) in
    CYGWIN* | MINGW* ) run=winpty ;;
esac
readonly run

for f in functions/*.sh
do
    source $f
done

readonly tasks=($(declare -F | cut -d' ' -f3 | grep -v '^-' | sort))

-setup-terminal

[[ -t 1 ]] && color=true || color=false
let debug=0 || true
print=
pwd=pwd
verbose=false
while getopts :-: opt
do
    [[ - == $opt ]] && opt=${OPTARG%%=*} OPTARG=${OPTARG#*=}
    case $opt in
    c | color ) color=true ;;
    no-color ) color=false ;;
    d | debug ) let ++debug ;;
    h | help ) -print-help ; exit 0 ;;
    n | dry-run ) print=echo ;;
    v | verbose ) verbose=true ;;
    * ) -print-usage >&2 ; exit 2 ;;
    esac
done
shift $((OPTIND - 1))
readonly print
readonly verbose

-setup-colors
-maybe-debug
readonly debug

case $# in
0 ) set -- clean build run ;;
esac

# Assume no sub-command takes arguments
for cmd
do
    "$cmd"
done
