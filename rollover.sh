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
 2. View current repository
 3. Create backup
 4. Restore backup

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

    test -f $REPO_STORE && touch $REPO_STORE
    truncate -s 0 $REPO_STORE
    echo "${NEW_REPOSITORY}" >> $REPO_STORE
    echo "${NEW_REPOSITORY} has been set as your default rollover repository"
}

create_backup() {
   echo "Create backup" 
}

restore_backup() {
    echo "Restore backup"
}

execute() {
    read -p ">> Type in a number that corresponds to the operation you want to perform: " OPERATION
    case "$OPERATION" in
        [1])
             set_repo
            ;;
        [2])
            view_repo
            ;;
        [3])
            create_backup
            ;;
        [4])
            restore_backup
            ;;
        *)
            echo "Operation not recognized!"
            exit 1
            ;;
    esac
}

show_menu
execute
