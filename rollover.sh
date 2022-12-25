#!/bin/sh

REPO_STORE=~/.rollover
BACKUP_STORE=./.tmp
CONFIG_STORE=./include.txt

show_menu() {
    echo "

  _____       _ _                     
 |  __ \     | | |                    
 | |__) |___ | | | _____   _____ _ __ 
 |  _  // _ \| | |/ _ \ \ / / _ \ '__|
 | | \ \ (_) | | | (_) \ V /  __/ |   
 |_|  \_\___/|_|_|\___/ \_/ \___|_|   
                                      
  
 1. Set repository
 2. View current repository
 3. Create backup
 4. Restore backup


 Type exit to quit program
    "
}

view_repo() {
    if [ -f "$REPO_STORE" ]; then
        CURRENT_REPO="$(head -1 $REPO_STORE)"
        echo "Current repository: ${CURRENT_REPO}"
    else
        echo "No repository set."
    fi
}

set_repo() {
    view_repo
    read -p ">> Enter a repository (eg. https://github.com/username/repo.git): " NEW_REPOSITORY
    if ! [[ $NEW_REPOSITORY =~ ^(http|https|git@) ]] || ! [[ $NEW_REPOSITORY =~ \.git$ ]]; then
        echo "Invalid repository URL!"
        exit 1
    fi

    [ -f $REPO_STORE ] && touch $REPO_STORE
    truncate -s 0 $REPO_STORE
    echo "${NEW_REPOSITORY}" >> $REPO_STORE
    echo "${NEW_REPOSITORY} has been set as your default rollover repository"
}

create_backup() {
   echo "[*] Scanning files..." 
   backup_arr=()
   while read line; do
      [[ -z "${line// }" ]] && continue
      relative_path=~/$line
      [[ -e $relative_path ]] && backup_arr+=($line)
   done < $CONFIG_STORE 
   echo "[*] ${#backup_arr[*]} files/directories will be backed up:\n"
   for target in ${backup_arr[*]}
    do
        echo " $target"
    done
    
    echo "\n"

    while true; do
        read -p ">> Continue? (Y/N) " CONFIRM_BACKUP
        case "$CONFIRM_BACKUP" in
            [yY])
                break
                ;;
            [nN])
                echo "Cancelled!"
                exit 0
                ;;
        esac
    done
    if ! [[ -d $BACKUP_STORE ]]; then
        mkdir $BACKUP_STORE
    else
        rm -rf $BACKUP_STORE/*
    fi
}

restore_backup() {
    echo "Restore backup"
}

execute() {
    while true; do
        read -p ">> Type in a number that corresponds to the operation you want to perform: " OPERATION
        case "$OPERATION" in
            1)
                 set_repo
                 break
                ;;
            2)
                view_repo
                break
                ;;
            3)
                create_backup
                break
                ;;
            4)
                restore_backup
                break
                ;;
            exit)
                echo "Terminating program :)"
                break
                ;;
            *)
                echo "Operation not recognized!"
                continue
                ;;
        esac
    done
}

show_menu
execute
