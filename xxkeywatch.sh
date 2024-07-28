#!/bin/bash
#shellcheck disable=SC2002,SC1091,SC2034
# NOTE: Editing the inventory does not need a restart, the script will pick up the changes in the next iteration.
# NOTE: Editing the .env file will not take effect until the script is restarted.
_SCRIPT_VERSION="0.1.0"
_SCRIPT_NAME="xxHecate"

#####################################
#### Configuration
#####################################
XXKEYWATCHLOG_FILE="${XXKEYWATCHLOG_FILE:-xxHecate.log}"
XXKEYWATCHSLEEP_DURATION="${XXKEYWATCHSLEEP_DURATION:-60}"
# TODO: Remove this after testing is done.

#####################################
#### Constants
#####################################
XXKEYWATCH_DEBUG_FLAG="${_SCRIPT_NAME}_DEBUG_MODE"
XXKEYWATCH_DEBUG_FLAG=$(echo "$XXKEYWATCH_DEBUG_FLAG" | tr '[:lower:]' '[:upper:]')
XXKEYWATCH_DEBUG_MODE=$(if [[ -f $XXKEYWATCH_DEBUG_FLAG ]]; then echo 1; else echo 0; fi)

#####################################
#### Helpers
#####################################
fblack='\e[0;30m'        # Black
fred='\e[0;31m'          # Red
fgreen='\e[0;32m'        # Green
fyellow='\e[0;33m'       # Yellow
fblue='\e[0;34m'         # Blue
fpurple='\e[0;35m'       # Purple
fcyan='\e[0;36m'         # Cyan
fwhite='\e[0;37m'        # White
bblack='\e[1;30m'        # Black
bred='\e[1;31m'          # Red
bgreen='\e[1;32m'        # Green
byellow='\e[1;33m'       # Yellow
bblue='\e[1;34m'         # Blue
bpurple='\e[1;35m'       # Purple
bcyan='\e[1;36m'         # Cyan
bwhite='\e[1;37m'        # White
nc="\e[m"                # Color Reset
nl="\n"                  # New Line

function log() {
    local _message="$1"
    local _level="$2" # Expect 'INFO', 'WARN', 'ERROR', 'DEBUG'
    local _timestamp
    local log_file="$XXKEYWATCHLOG_FILE"
    _timestamp=$(date +'%Y-%m-%d %H:%M:%S')

    # Ensure log file exists
    if [ ! -f "$log_file" ]; then
        touch "$log_file"
    fi

    case $(echo "$_level" | tr '[:upper:]' '[:lower:]') in
    "info" | "information")
        echo -ne "${bwhite}[INFO][${_SCRIPT_NAME} ${_SCRIPT_VERSION}][${_timestamp}]: ${_message}${nc}${nl}"
        if [ -s "$log_file" ]; then echo "$(date +'%Y-%m-%d %H:%M:%S') - [INFO] $_message" >> "$log_file"; fi
        ;;
    "warn" | "warning")
        echo -ne "${byellow}[WARN][${_SCRIPT_NAME} ${_SCRIPT_VERSION}][${_timestamp}]: ${_message}${nc}${nl}"
        if [ -s "$log_file" ]; then echo "$(date +'%Y-%m-%d %H:%M:%S') - [WARN] $_message" >> "$log_file"; fi
        ;;
    "err" | "error")
        echo -ne "${bred}[ERR][${_SCRIPT_NAME} ${_SCRIPT_VERSION}][${_timestamp}]: ${_message}${nc}${nl}"
        if [ -s "$log_file" ]; then echo "$(date +'%Y-%m-%d %H:%M:%S') - [ERR] $_message" >> "$log_file"; fi
        ;;
    "dbg" | "debug")
        if [ "$XXKEYWATCH_DEBUG_MODE" -eq 1 ]; then
            echo -ne "${bcyan}[DEBUG][${_SCRIPT_NAME} ${_SCRIPT_VERSION}][${_timestamp}]: ${_message}${nc}${nl}"
            if [ -s "$log_file" ]; then echo "$(date +'%Y-%m-%d %H:%M:%S') - [DEBUG] $_message" >> "$log_file"; fi
        fi
        ;;
    *)
        echo -ne "${bblue}[UNKNOWN][${_SCRIPT_NAME} ${_SCRIPT_VERSION}][${_timestamp}]: ${_message}${nc}${nl}"
        if [ -s "$log_file" ]; then echo "$(date +'%Y-%m-%d %H:%M:%S') - [UNKNOWN] $_message" >> "$log_file"; fi
        ;;
    esac
}

function check_requirements() {
    for tool in "$@"; 
    do
        if ! command -v "$tool" &> /dev/null; 
        then
            log "Pre-requisite '$tool' was not found on your system." "ERROR"
            exit 1
        else
            log "Pre-requisite '$tool' found." "DEBUG"
        fi
    done
}

function load_env_file() {
    local _count=0
    log "Loading environment variables from the .env file." "INFO"
    if [ -f .env ]; then
        set -o allexport
        source .env
        set +o allexport
        while IFS= read -r _; do
            ((_count++))
        done < .env
        log "Loaded ${_count} environment variables from the .env file." "INFO"
    else
        log "The .env file was not found found falling back to defaults." "WARN"
    fi
}

function main() {
    # TODO: Add main logic here.
    log "Starting $_SCRIPT_NAME $_SCRIPT_VERSION" "INFO"
}

load_env_file
check_requirements "ssh" "curl" "awk" 
main
