#!/bin/bash
#################
/usr/bin/sqlite3 /home/arun/Desktop/App/application.db <<!
.headers on
.mode csv
.output scada1.csv
select * from SCADA1;
!
################
/usr/bin/sqlite3 /home/arun/Desktop/App/application.db <<!
.headers on
.mode csv
.output scada2.csv
select * from SCADA2;
!
#################

SLAVE_PASSWORD=aaa
CONNECTION_TIMEOUT=10
LOG_LIMIT=100
TRUE=1
#MC_IP=("192.168.1.100")  #Machine 1 ip addr
MC_IP=("192.168.1.100" 
       "192.168.1.102")   #Machine 2 ip addr
#       "192.168.2.151") #Machine 3 ip addr
Conn_loss_Cnt[0]=0
LOG_LIMIT=$(($LOG_LIMIT+$TRUE))
while [ 0 -lt 10 ]
do
for var in ${!MC_IP[@]};
 do
   Connection_Status=$( { sshpass -p $SLAVE_PASSWORD scp -o ConnectTimeout=$CONNECTION_TIMEOUT root@${MC_IP[$var]}:/home/pi/Desktop/scada1.csv  /home/raja/Desktop/check; } 2>&1 )
  if [ "$Connection_Status"  = "" ]; then
    echo "${MC_IP[$var]} $(date) Connection Sucessfully"
    Sql_Conn_Status=$( { mysql -uroot -proot --local_infile=1 wind -e "LOAD DATA LOCAL INFILE '/home/raja/Desktop/check/scada1.csv' REPLACE INTO TABLE livedata FIELDS TERMINATED BY ','"; } 2>&1 )
	if [ "$Sql_Conn_Status"  = "" ]; then
	   echo "${MC_IP[$var]} $(date) db updated Sucessfully"
	else
	   echo "${MC_IP[$var]} $(date) $Sql_Conn_Status"
	fi
  else
    echo "${MC_IP[$var]} $(date) $Connection_Status"
    Conn_loss_Cnt[$var]=`expr ${Conn_loss_Cnt[$var]} + 1`
      if [ "${Conn_loss_Cnt[$var]}" -ge 5 ]; then
       echo "${MC_IP[$var]} $(date) connection reset"
       Conn_loss_Cnt[$var]=0
      fi
  fi  
 done
done
MK=$(sed "$LOG_LIMIT!d" /home/raja/Desktop/App/Get_DB.log)
if [ "$MK"  != "" ]; then
    sed -i '1d' /home/raja/Desktop/App/Get_DB.log
fi

       
