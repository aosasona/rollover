#!/bin/sh

REPO_STORE=~/.rollover

show_menu() {
    echo "

  _____       _ _                     
 |  __ \     | | |                    
 | |__) |___ | | | _____   _____ _ __ 
 |  _  // _ \| | |/ _ \ \ / / _ \ '__|
 | | \ \ (_) | | | (_) \ V /  __/ |   
 |_|  \_\___/|_|_|\___/ \_/ \___|_|   
                                      
  
 1. Set repository
 2. Create backup
 2. Restore backup

    "
}

set_repo() {
    if [ -f "$REPO_STORE" ]; then
        CURRENT_REPO = $(head -1 $REPO_STORE)
        echo "Current repository: ${CURRENT_REPO}"
    fi
}

create_backup() {
   echo "Create backup" 
}

restore_backup() {
    echo "Restore backup"
}

execute() {
    read -p "What do you want to do? (type in a number that matches the operation): " OPERATION
    case "$OPERATION" in
        [1])
             set_repo
            ;;
        [2])
            create_backup
            ;;
        [3])
            restore_backup
            ;;
        *)
            echo "Invalid operation!"
            ;;
    esac
}

show_menu
execute
