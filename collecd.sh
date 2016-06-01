#!/bin/bash
FILE=/home/raja/Desktop/check/*.tar
SCADA_FILE=/home/raja/Desktop/check/*.csv
db=wind
tar_file=$( { ls | grep .tar; } )
if [ "$tar_file"  != "" ]; then
for f in $FILE
do
  tar -xvf $f
    for s in $SCADA_FILE
    do	
      mysql_error_status=$( { mysql -uroot -proot --local_infile=1 $db -e "LOAD DATA LOCAL INFILE '$s' INTO TABLE machine FIELDS TERMINATED BY ',' IGNORE 1 ROWS";} 2>&1)
        if [ "$mysql_error_status"  = "" ]; then
      	  echo "$(date) $s file Updated Sucessfully"
      	  rm $s
    	else
      	  echo "$(date) $s $mysql_error_status"
    	fi
    done
  rm -rf $f
done
else
 echo "$(date) $FILE in this dir no tar file"
fi
