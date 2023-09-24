#!/bin/bash

#Name: Kinjal Prajapati
#ID: 110095279
#Section: 3

# this is a function which will create the complete backup of
# all text files under /home/kin 

kin_comp_backup() {
#defining the destination dir for complete backup
  local kin_dir_cb="/home/kin/backup/cb"
  #making file name with the help of date. here tar file naming will be done
  local kin_file_cb="cb$(date +%Y%m%d).tar"
  #here find command will find all the txt files
  #all the txt file list will go to tar to create backup
  if find "/home/kin" -name "*.txt" | tar -cf "$kin_dir_cb/$kin_file_cb" -T - ; then
    #if tar is success the it will log it in log file
    echo "$(date) ${kin_file_cb} was created" >> "/home/kin/backup/backup.log"
  else
    #else error will be log
    echo "$(date) cb file creation error" >> "/home/kin/backup/backup.log"
  fi
}

# this is a function which will create the incremental backup of
# all modified or newely created text files under /home/kin 
kin_inc_backup() {
  #defining the destination dir for incremental backup
  local kin_dir_ib="/home/kin/backup/ib"
   #making file name with the help of date. here tar file naming will be done
  local kin_file_ib="ib$(date +%Y%m%d).tar"
  #this is a ref file to compare incremental changes
  local kin_last_comp_backup="/home/kin/backup/last_cbackup"

  #checking if ref file exits
  if [ -z "$kin_last_comp_backup" ]; then
    echo "Error: The variable \$kin_last_comp_backup is not set. Please set it to the reference file for comparison."
    exit 1
  fi

  if ! [ -e "$kin_last_comp_backup" ]; then
      echo "Error: The reference file specified by \$kin_last_comp_backup does not exist."
      exit 1
  fi

  # Check if the target directory for incremental backups exists, if not, create it
  if ! [ -d "$kin_dir_ib" ]; then
      mkdir -p "$kin_dir_ib"
  fi

  # Find and store the list of files matching the criteria in a variable
  files_to_backup=$(find "/home/kin" -type f -newer "$kin_last_comp_backup" -name "*.txt")

  if [ -n "$files_to_backup" ]; then
      # Create the incremental backup using the tar command with the list of files
      tar -cf "$kin_dir_ib/$kin_file_ib" $files_to_backup

      # creating the log entry
      echo "$(date) ${kin_file_ib} was created" >> "/home/kin/backup/backup.log"
  else
      echo "$(date) No changes - Incremental backup was not created" >> "/home/kin/backup/backup.log"
  fi

}

# this func will do inc backup 3 times as defined
kin_loop_ib() {
  for i in {1..3}; do
    kin_inc_backup
    # Updateing timestamp for incremental backup
    touch "/home/kin/backup/last_cbackup"
    # Wait for given time 
    sleep 25
  done
}

# Continuously running loop
while true; do
  # calling complete backup
  kin_comp_backup

  # Updateing timestamp
  touch "/home/kin/backup/last_cbackup"

  # Wait for 2given time
  sleep 25

  # calling inc backup loop
  kin_loop_ib
done

