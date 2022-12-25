# Rollover

Rollover allows you to backup your configs and scripts to your Github/Gitlab automatically using a pre-specified list.

## Getting Started

- Fork & clone this repository
- Create a repository for saving your backups (remember to make it private if you will be backing up sensitive data eg. .ssh folder)
- Modify `include.txt` to contain a list of files you want to backup; relative to ~ or your home directory
- Run the command below to get started:

```bash
chmod +x ./rollover.sh && ./rollover.sh
```

## Important notes

- You need to have GIT (and SSH if you use SSH with your Github or Gitlab) set up on your machine
- Rollover can restore any version of your backup from GIT but, you should know it will replace existing version of those files on your machine.
  > MAKE SURE YOU KNOW WHAT YOU'RE DOING!
