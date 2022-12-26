#!/bin/sh

HOME_DIR=~/
REPO_STORE=~/.rollover
BACKUP_STORE=./.tmp
CONFIG_STORE=./include.txt
ROLLOVER_GIT_DIR=.rgit
CURRENT_REPO="$(head -1 $REPO_STORE)"

show_menu() {
    echo "

  _____       _ _                     
 |  __ \     | | |                    
 | |__) |___ | | | _____   _____ _ __ 
 |  _  // _ \| | |/ _ \ \ / / _ \ '__|
 | | \ \ (_) | | | (_) \ V /  __/ |   
 |_|  \_\___/|_|_|\___/ \_/ \___|_|   
                                      
  
 [1] Set repository
 [2] View current repository
 [3] Create a backup
 [4] Restore a backup


 Type exit to quit program
    "
}

view_repo() {
    if [ -f "$REPO_STORE" ]; then
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

create_clean_temp() {
    if ! [[ -d $BACKUP_STORE ]]; then
        mkdir $BACKUP_STORE
        cd $BACKUP_STORE
        {
            git init
            mv .git $ROLLOVER_GIT_DIR
            git --git-dir=$ROLLOVER_GIT_DIR remote add origin $CURRENT_REPO
        }
        cd ..
    else
        cp -r $BACKUP_STORE/$ROLLOVER_GIT_DIR ./$ROLLOVER_GIT_DIR
        rm -rf $BACKUP_STORE
        mkdir $BACKUP_STORE
        mv ./$ROLLOVER_GIT_DIR $BACKUP_STORE/$ROLLOVER_GIT_DIR
    fi

    # Set/update repository and prevent rgit from being pushed to the remote repository
    cd $BACKUP_STORE
    {
        git --git-dir=$ROLLOVER_GIT_DIR remote set-url origin $CURRENT_REPO
        git --git-dir=$ROLLOVER_GIT_DIR branch -m main
        git --git-dir=$ROLLOVER_GIT_DIR pull origin main
    }
    cd ..
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
   for target in ${backup_arr[*]}; do
        echo " $target"
    done
    
    echo "\n"

    while true; do
        read -p ">> Continue? (Y/N) " CONFIRM
        case "$CONFIRM" in
            [yY])
                break
                ;;
            [nN])
                echo "Cancelled!"
                exit 0
                ;;
        esac
    done

    create_clean_temp

    echo "\n[*] Copying targets"
    
    for target in ${backup_arr[*]}; do
        target_path=~/$target
        dest_path=$BACKUP_STORE/$target
        if [[ -f $target_path ]]; then
            cp $target_path $dest_path
        else
            cp -r $target_path $dest_path
        fi
    done

    if ! [ $? -eq 0 ]; then
        echo "\n[x] Failed to copy!"
        exit 1
    fi

    echo "\n[*] Saving backup to remote repository"

    timestamp=$(date +"%Y-%m-%d %T")
    cd $BACKUP_STORE 
    {
        [[ -f .gitignore ]] && echo "${ROLLOVER_GIT_DIR}" > .gitignore
        git --git-dir=$ROLLOVER_GIT_DIR add .
        git --git-dir=$ROLLOVER_GIT_DIR commit -m "[ROLLOVER] Added backup $timestamp"
        git --git-dir=$ROLLOVER_GIT_DIR push --force || git --git-dir=$ROLLOVER_GIT_DIR push -u origin main --force
        # Force is used because from time to time there will be an issue with Git since files will be created and deleted from time to time as you update your include.txt file

        if [ $? -eq 0 ]; then
            echo "\n[*] Backup $timestamp saved successfully!"
        else
            echo "\n[x] Failed to save backup $timestamp"
        fi
    }
    cd ..
    exit 0
}

checkout_remote() {
    hash=$1

    git --git-dir=$ROLLOVER_GIT_DIR fetch origin
    git --git-dir=$ROLLOVER_GIT_DIR checkout HEAD
}

restore_backup() {
    create_clean_temp

    echo "\n[1] Restore from last backup\n[2] Restore from commit hash"
    
    while true; do
        read -p ">> Type the corresponding number to choose how to restore backup: " RESTORE_OPTION
        case "${RESTORE_OPTION}" in
            1)
                cd $BACKUP_STORE
                {
                    latest_commit=$(git --git-dir=$ROLLOVER_GIT_DIR rev-parse HEAD)
                    checkout_remote $latest_commit
                }
                cd ..
                break
                ;;
            2)
                read -p ">> Enter the commit hash: " SELECTED_HASH
                cd $BACKUP_STORE
                {
                    checkout_remote $SELECTED_HASH
                }
                cd ..
                break
                ;;
            *)
                echo "Invalid option!"
                ;;
        esac
    done
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
