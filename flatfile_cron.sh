#!/bin/bash
check_md5sum () {
    for run in $(seq 1 4)
    do
      sum1=$(echo $(/usr/bin/env md5sum "$1" |awk '{print $1}'))
      sleep 4
      sum2=$(echo $(/usr/bin/env md5sum "$1" |awk '{print $1}'))
      if [ $sum1 ==  $sum2 ]
      then
        echo "OK"
        exit 0
      else
        echo "FAIL"
      fi
    done
}
decrypt_gpg () {
    if [ -f ~/.gnupg/.k ] ; then
      GPGK=$(cat ~/.gnupg/.k)
      infile="$(basename -- $1)"
      outfile="$SOURCEDIR/${infile%.*}"
      echo "$GPGK" | /usr/bin/gpg -o "$outfile" --batch --yes --passphrase-fd 0 "$1" >> $LOGFILE 2>&1
      ret_val=$?
      if [ $ret_val -ne 0 ]; then
        echo "GPG decryption failed on "$newfile"" >> $LOGFILE 2>&1
        mkdir -p "$GPGFAIL"
        mv "$newfile" "$GPGFAIL"
        echo "GPG file has been moved to "$GPGFAIL" for analysis" >> $LOGFILE 2>&1
        exit 2
      else
        echo "Removing $newfile" >> $LOGFILE 2>&1
        rm "$newfile"
        newfile="$outfile"
        echo "The decrypted file has been saved as $newfile" >> $LOGFILE 2>&1
      fi
    else
      echo "GPG decryption failed on "$newfile"" >> $LOGFILE 2>&1
      mkdir -p "$GPGFAIL"
      mv "$newfile" "$GPGFAIL"
      echo "GPG file has been moved to "$GPGFAIL" for analysis" >> $LOGFILE 2>&1
      exit 2
    fi
}
rename_file () {
    file=$(echo "$1" | tr " " "_")
    base_name="${1##*/}"
    filename="${file%.*}"
    extension="${file##*.}"
    timestamp=$(date +"%s")
    newfile="$filename-$timestamp.$extension"
    echo "Renaming \"$base_name\" to \"$newfile\"" >> $LOGFILE 2>&1
    mv "$1" "$newfile"
}
SOURCEDIR=<%=@chroot_dir%>/<%=@home_dir%>
BADGE_SOURCEDIR=<%=@chroot_dir%>/badge
BADGE_TARGETDIR=<%=@badge_dir%>/todo
TARGETDIR=<%=@install_dir%>/processed
GPGFAIL=<%=@install_dir%>/gpg_decrypt_failures
LOGFILE=<%=@install_dir%>/log/parser.log
cd /opt/fileprocessor/bin
echo ----------------------------------------------------------------- >> $LOGFILE 2>&1
echo Initiate CSV file move from client upload directory - $(date) >> $LOGFILE 2>&1
for file in "$BADGE_SOURCEDIR"/* "$SOURCEDIR"/*
do
  if [ -f "$file" ]; then
    rename_file "$file"
    verify_md5sum=$(echo $(check_md5sum "$newfile"))
    if [ "$verify_md5sum" == 'OK' ]
    then
      if [ ${newfile: -4} == ".gpg" ] || [ ${newfile: -4} == ".pgp" ]
      then
          echo "Decrypting $newfile" >> $LOGFILE 2>&1
          decrypt_gpg "$newfile"
      fi
      chown <%=@admin_user%> $newfile >> $LOGFILE 2>&1
      chgrp <%=@admin_user%> $newfile >> $LOGFILE 2>&1
      if [[ "$newfile" =~ badge ]]
      then
         mv $newfile $BADGE_TARGETDIR >> $LOGFILE 2>&1
         echo "Moved $newfile to $BADGE_TARGETDIR" >> $LOGFILE 2>&1
      else
         mv $newfile $TARGETDIR >> $LOGFILE 2>&1
         echo "Moved $newfile to $TARGETDIR" >> $LOGFILE 2>&1
      fi
    else
      echo "Failed to verify md5sum on $newfile" >> $LOGFILE 2>&1
      echo "File must still be updating, will try to move again on next run..." >> $LOGFILE 2>&1
      fi
  elif [ ! -d "$file" ]; then
    echo "No file(s) to move." >> $LOGFILE 2>&1
  fi
done
echo ----------------------------------------------------------------- >> $LOGFILE 2>&1
