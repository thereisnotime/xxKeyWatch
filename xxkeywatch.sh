#!/bin/bash
#shellcheck disable=SC2002,SC1091,SC2034
# NOTE: Editing the inventory does not need a restart, the script will pick up the changes in the next iteration.
# NOTE: Editing the .env file will not take effect until the script is restarted.
# TODO: Change globals to local variables.
_SCRIPT_VERSION="0.1.0"
_SCRIPT_NAME="xxKeyWatch"

#####################################
#### Configuration
#####################################
XXKEYWATCH_LOG_FILE="${XXKEYWATCH_LOG_FILE:-${_SCRIPT_NAME}.log}"

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
    local log_file="$XXKEYWATCH_LOG_FILE"
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

function get_config() {
    local _config_url="$1"
    local _config
    log "Fetching configuration from $_config_url" "INFO"
    _config=$(curl -s "$_config_url")
    if ! jq -e . >/dev/null 2>&1 <<<"$_config"; then
        log "Configuration is not valid JSON." "ERROR"
        exit 1
    fi
}

function load_env_file() {
    local _count=0
    local _current_dir
    local _env_file
    log "Loading environment variables from the .env file." "INFO"
    _current_dir="$(dirname "${BASH_SOURCE[0]}")"
    _env_file="${_current_dir}/.env"
    if [ -f "$_env_file" ]; then
        set -o allexport
        source .env
        set +o allexport
        while IFS= read -r _; do
            ((_count++))
        done < "$_env_file"
        log "Loaded ${_count} environment variables from the .env file." "INFO"
    else
        log "The .env file was not found found," "WARN"
    fi
}

function print_config() {
    log "Printing configuration..." "DEBUG"
    env | grep -i "^XXKEYWATCH"
}

function main() {
    # TODO: Add main logic here.
    log "Starting $_SCRIPT_NAME $_SCRIPT_VERSION" "INFO"
    # TODO: Remove testing
    input_file="test-data.json"
    if [ "$XXKEYWATCH_DEBUG_MODE" -eq 1 ]; then print_config; fi
    # TODO: Add a mechanism to detect if running for user (use only all_user_keys and the user specific one) or for root (do it for all users).
    # Process individual users
    # TODO: Finish this.
    log "=== Processing individual users..." "INFO"
    users=$(jq -c '.[].users[]' "$input_file")
    echo "$users" | while IFS= read -r user; do
        user_name=$(echo "$user" | jq -r '.user')
        user_keys=$(echo "$user" | jq -c '.keys[]')
        user_groups=$(echo "$user" | jq -r '.groups[]')
        user_groups_concat=$(echo "$user_groups" | tr '\n' ',')
        user_groups_concat=$(echo "$user_groups_concat" | sed 's/,$//')

        # Check if groups exist, if not create the groups
        if [ -n "$user_groups" ]; then
            log "Processing groups for user: $user_name" "DEBUG"
            for group in $user_groups; do
                log "Processing group: $group" "DEBUG"
                if getent group "$group" &>/dev/null; then
                    log "Group $group exists." "DEBUG"
                else
                    log "Group $group does not exist. Creating it now..." "WARNING"
                    groupadd "$group" 
                fi
            done
        fi

        # Check if user exists, if not create the user
        if ! id "$user_name" &>/dev/null; then
            log "Creating user: $user_name" "INFO"
            useradd -m "$user_name" -s /bin/bash -G "$user_groups_concat"
        else
            log "User $user_name already exists. Ensuring group membership." "DEBUG"
            usermod -a -G "$user_groups_concat" "$user_name"
        fi

        # Process keys for the user
        echo "$user_keys" | while IFS= read -r key; do
            key_value=$(echo "$key" | jq -r '.')
            key_value_short=$(echo "$key_value" | cut -c1-38)
            log "Processing key: $key_value_short for $user_name" "DEBUG"

            # Manage the authorized_keys file
            homedir=$(getent passwd "$user_name" | cut -d: -f6)
            authorized_keys="$homedir/.ssh/authorized_keys"
            mkdir -p "$homedir/.ssh"
            [ ! -f "$authorized_keys" ] && touch "$authorized_keys"
            chown -R "${user_name}:${user_name}" "$homedir/.ssh"
            chmod 600 "$authorized_keys"
            grep -qxF "$key_value" "$authorized_keys" || echo "$key_value" >> "$authorized_keys"
        done

        log "Processed user $user_name ($user_groups_concat)" "INFO"
    done

    # Process keys for all users
    log "=== Processing keys for all users..." "INFO"
    all_user_keys=$(jq -c '.[].all_user_keys[]' "$input_file")
    echo "$all_user_keys" | while IFS= read -r key_obj; do
        key=$(echo "$key_obj" | jq -r '.key')
        key_short=$(echo "$key" | cut -c1-38)
        comment=$(echo "$key_obj" | jq -r '.comment')
        log "Processing key: $key_short ($comment)" "INFO"
        # TODO: Improve this logic for edge cases.
        all_users=$(cat /etc/passwd | grep -E '.*sh$')
        all_users=$(echo "$all_users" | awk -F: '{print $1}')

        # Ensure only proper users' authorized_keys are updated
        for username in $all_users; do
            homedir=$(getent passwd "$username" | cut -d: -f6)
            shell=$(getent passwd "$username" | cut -d: -f7)
            authorized_keys="$homedir/.ssh/authorized_keys"
            log "Adding key ($key_short) to $username's authorized_keys ($homedir)" "DEBUG"
            # Create .ssh directory if it does not exist
            mkdir -p "$homedir/.ssh"
            # Check if authorized_keys exists, if not create it and set proper permissions
            if [ ! -f "$authorized_keys" ]; then
                touch "$authorized_keys"
                chown "${username}:${username}" "$authorized_keys"
                chmod 600 "$authorized_keys"
            fi
            # Add the key if it does not already exist
            # TODO: Add a mechanism for full control of the authorized_keys file when XXKEYWATCH_FULL_CONTROL is set to true.
            grep -qxF "$key" "$authorized_keys" || echo "$key" >> "$authorized_keys"
            
        done
    done
    log "Done. Exiting..." "INFO"
}

load_env_file
check_requirements "ssh" "curl" "awk" "jq"
main
