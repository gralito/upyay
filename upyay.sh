#!/bin/bash

# =========================================
# upyay
# Version: 3.1.4
# Author: gralito
# Github author: https://github.com/gralito
# Description: a yay wrapper.
# =========================================

SCRIPT_NAME="upyay.sh"
VERSION="3.1.4"

#=== Errors handling ===#
set -euo pipefail       # (comment for dev mode)
# set -euxo pipefail    # (uncomment for dev mode)

#=== Default variables ===#
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/upyay"
LOG_DIR="${XDG_CONFIG_HOME:-$HOME/.logs}/upyay"
BACKUP_DIR="$LOG_DIR/backup"
CONFIG_FILE="$CONFIG_DIR/upyay.conf"
LOG_FILE="$LOG_DIR/upyay.log"
LOCK_FILE="$LOG_DIR/upyay.lock"
LAST_FILE="$LOG_DIR/upyay.last"

declare -A LAST_ACTIONS=(
    ["LAST_UPDATE"]=""
    ["LAST_MIRRORS"]=""
    ["LAST_JOURNAL"]=""
    ["LAST_CACHE"]=""
    ["LAST_ORPHANS"]=""
)

#=== Default configuration ===#
# active if the config file does not exist
NOTHING_TO_DO_STRING="there is nothing to do"
NOTIFICATION_TIMEOUT=10000
ICON_SUCCESS="object-select-symbolic"
ICON_ERROR="dialog-error-symbolic"
ICON_INFO="dialog-information-symbolic"
ENDEAVOUROS_OPTION=false
AUTO_BACKUP=false
AUTO_SHOW_UPDATED=false                     #unused


#=== Help display ===#
show_help () {
    cat <<EOF

    =============================   

        upyay - a yay wrapper

    =============================

    version : $VERSION

    Usage: upyay [OPTIONS]

    OPTIONS:
        -u / --update         : system update
        -m / --mirrors        : update mirrors list (AUR & EndeavourOS if ENDEAVOUROS_OPTION=true)
        -j / --journal        : clean journal
        -c / --cache          : clean cache
        -o / --orphans        : remove orphan packages
        -l / --last           : display last date of each function
        -h / --help           : display this help message
        -v / --version        : display package version

    EXAMPLES:
        upyay -h              : show help

    EXIT CODES:
        0 - Success
        1 - Argument Error

EOF
}

#=== Version display ===#
show_version () {
    echo "${SCRIPT_NAME}"
    echo "version : ${VERSION}"
    exit 0
}

#=== Notification function ===#
send_notif () {
	notify-send -r "$ID" -t "$NOTIFICATION_TIMEOUT" -u $3 \
	-a "upyay" -i $1 "upyay" "$2 \nSee log at $LOG_FILE"
}

#=== Start notification ===#
start_notif () {
    ID=$(notify-send --print-id -t "$NOTIFICATION_TIMEOUT" -u normal \
        -a "upyay" -i $ICON_INFO "UpYaY" "... starting upyay ...")
}

#=== Write in log file ===#
log () {
	echo "$(date): $1" >> "$LOG_FILE"
}

#=== Reset log file ===#
reset_log () {
    > "$LOG_FILE"
    log "=== upyay started ==="
}

#=== Prompt user to open and backup log file ===#
see_log () {
	echo
	read -p "Do you want to see log file ? [y/N]" log_option
	if [[ "$log_option" =~ ^[Yy]$ ]]; then
		nvim $LOG_FILE
	fi
}

#=== Backup function ===#
backup () {
    mkdir -p $BACKUP_DIR
    filename="$(date +%F)-$(date +%H%M%S)"
    cp $LOG_FILE $BACKUP_DIR/${filename}
}

#=== Check user or auto backup ===#
check_backup () {
    if [[ $AUTO_BACKUP = false ]]; then
        echo
        read -p "Do you want to save a backup copy ? [y/N]" backup_option
        if [[ "$backup_option" =~ ^[Yy]$ ]]; then
            backup
        fi
    else
        echo
        echo "=== AUTO BACKUP ==="
        backup
    fi
}

#=== Load config file if exists ===#
load_config_file () {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi
}

#=== Check lock file for another instance ===#
check_lock_file () {
    sudo exec 9>"$LOCK_FILE"
    if ! flock -n 9; then
        log "Another instance is already running. Exiting."
        exit 1
    fi
}

#=== Read in last actions file ===#
read_last () {
    if [ -f "$LAST_FILE" ]; then
        source "$LAST_FILE"
        LAST_ACTIONS['LAST_UPDATE']=$LAST_UPDATE
        LAST_ACTIONS['LAST_MIRRORS']=$LAST_MIRRORS
        LAST_ACTIONS['LAST_JOURNAL']=$LAST_JOURNAL
        LAST_ACTIONS['LAST_CACHE']=$LAST_CACHE
        LAST_ACTIONS['LAST_ORPHANS']=$LAST_ORPHANS
    fi
}

#=== Write in last actions file ===#
write_last () {
    echo "#!/bin/bash" > "$LAST_FILE"
    for element in "${!LAST_ACTIONS[@]}"
    do
        echo "${element}='${LAST_ACTIONS[${element}]}'" >> "$LAST_FILE"
    done
}

#=== Arguments parser ===#
parse_args (){
    if [[ $# -gt 0 ]]; then
        case $1 in
            -u | --update)
                start_notif
                system_update
                write_last
                see_log
                check_backup
                exit 0;;
            -m | --mirrors)
                start_notif
                update_mirrors
                write_last
                see_log
                check_backup
                exit 0;;
            -j | --journal)
                start_notif
                clean_journal
                write_last
                see_log
                check_backup
                exit 0;;
            -c | --cache)
                start_notif
                clean_cache
                write_last
                see_log
                check_backup
                exit 0;;
            -o | --orphans)
                start_notif
                remove_orphans
                write_last
                see_log
                check_backup
                exit 0;;
            -l | --last)
                last_actions
                exit 0;;
            -h | --help)
                show_help
                exit 0;;
            -v | --version)
                show_version
                exit 0;;
            *)
                echo -e "[ERROR] Unknown argument : $1"
                show_help
                exit 1;;
        esac
    fi
}

#=== System update ===#
system_update () {
	log "=== System update started ==="
	echo "Start system update"
	if ! yay -Syyu --sudoloop --needed 2>&1 | tee -a "$LOG_FILE" ; then
		send_notif $ICON_ERROR "Error during system update!" critical
		log "=== System update failed ==="
		exit 1
	fi
	send_notif $ICON_SUCCESS "System update successful" normal
	log "=== System update succeeded ==="
    LAST_ACTIONS['LAST_UPDATE']="$(date)"
}

#=== Mirrors list update ===#
update_mirrors () {
	log "=== Refresh AUR mirrors list started ==="
	echo "Refresh AUR mirrors list"
	if ! sudo reflector --protocol https --verbose --latest 25 --sort rate --save /etc/pacman.d/mirrorlist ; then
		send_notif $ICON_ERROR "Error during AUR mirrors update!" critical
		log "=== Refresh AUR mirrors list failed ==="
		exit 1
	fi
	if $ENDEAVOUROS_OPTION ; then
		log "=== Refresh EOS mirrors list started ==="
		echo "Refresh EOS mirrors list"
		if ! eos-rankmirrors --verbose ; then
			send_notif $ICON_ERROR "Error during EOS mirrors update!" critical
			log "=== Refresh EOS mirrors list failed ==="
			exit 1
		fi
	fi
	send_notif "$ICON_SUCCESS" "Lists update successful" normal
	log "=== Lists update succeeded ==="
    LAST_ACTIONS['LAST_MIRRORS']="$(date)"
    echo
    read -p "Performing system update (Y/n) ? (recommanded) >> " select_update
    select_update=${select_update:-y}
    if [[ "$select_update" =~ ^[Yy]$ ]]; then
        system_update
    fi
}

#=== Journal cleaning ===#
clean_journal () {
	log "=== Journal cleanup started ==="
	echo "Start journal cleanup"
	if ! sudo journalctl --vacuum-time=4weeks 2>&1 | tee -a "$LOG_FILE" ; then
		send_notif $ICON_ERROR "Error during journal cleanup!" critical
		log "=== Journal cleanup failed ==="
		exit 1
	fi
	send_notif "$ICON_SUCCESS" "Journal cleanup successful" normal
	log "=== Journal cleanup succeeded ==="
    LAST_ACTIONS['LAST_JOURNAL']="$(date)"
}

#=== Cache cleaning ===#
clean_cache () {
	log "=== Cache cleanup started ==="
	echo "Start cache cleanup"
	if ! yay -Scc --noconfirm 2>&1 | tee -a "$LOG_FILE" ; then
		send_notif "$ICON_ERROR" "Error during cache cleanup!" critical
		log "=== Cache cleanup failed ==="
		exit 1
	fi
	send_notif "$ICON_SUCCESS" "Cache cleanup successful" normal
	log "=== Cache cleanup succeeded ==="
    LAST_ACTIONS['LAST_CACHE']="$(date)"
}

#=== Remove orphan packages ===#
remove_orphans () {
	log "=== Orphans remove started ==="
	echo "Start orphans remove"
	if ! sudo pacman -Qdtq | ifne sudo pacman -Rns - 2>&1 | tee -a "$LOG_FILE" ; then
		send_notif "$ICON_INFO" "No orphan packages!" normal
		log "=== No orphan packages ==="
	else
		send_notif "$ICON_INFO" "Orphans remove successful" normal
		log "=== Orphans remove succeeded ==="
	fi
    LAST_ACTIONS['LAST_ORPHANS']="$(date)"
}

#=== Display last actions ===#
last_actions () {
    echo
    echo '****************'
    echo '* Last actions *'
    echo '****************'
    echo 
    echo "System update     => ${LAST_ACTIONS['LAST_UPDATE']}"
    echo "Mirrors list      => ${LAST_ACTIONS['LAST_MIRRORS']}"
    echo "Journal cleanup   => ${LAST_ACTIONS['LAST_JOURNAL']}"
    echo "Cache cleanup     => ${LAST_ACTIONS['LAST_CACHE']}"
    echo "Orphans removal   => ${LAST_ACTIONS['LAST_ORPHANS']}"
}

#=== Main program ===#
main () {
    # Prepare the environment
    check_lock_file
    load_config_file
    reset_log

    # Get the last actions dates in LAST_FILE
    read_last
    
    # Check args presence
    if [ $# = 0 ]; then
        echo "[ERROR] No argument passed"
        return 1;
    else
        parse_args "$@"
    fi
}

#=== Script Entry Point ===#
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi