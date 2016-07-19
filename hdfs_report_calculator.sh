#!/bin/bash

ROOT_DIR="/root/scripts/REPORT"
REPORT_DIR="${ROOT_DIR}/hdfs_usage_report"
INPUT_FILE="${REPORT_DIR}/input_file"
FINAL_REPORT="${REPORT_DIR}/final_report.txt"
TEMP="${REPORT_DIR}/temp"


echo -e '\0033\0143'
echo -e "To which day you would want to compare report ?"
echo -e "Available year\n"
ls $REPORT_DIR | grep "Y[0-9]"
echo -e "Select the year from above\n"
read _YEAR
if [ ! -d $REPORT_DIR/$_YEAR ] ; then
  echo "Entered year is incorrect, please try again"
  exit 0
fi
cd $REPORT_DIR/$_YEAR
echo -e "Available month\n"
ls $REPORT_DIR/$_YEAR
echo -e "Select the month from above"
read _MONTH
if [ ! -d $_MONTH ] ; then
  echo "Entered month is incorrect, please try again"
  exit 0
fi
cd $REPORT_DIR/$_YEAR/$_MONTH
echo -e "Available Report\n"
ls $REPORT_DIR/$_YEAR/$_MONTH
echo -e "Now select the report from above which you want to compare\n"
read _REPORT
if [ ! -f $_REPORT ] ; then
  echo "Entered report does not match from the above list, please enter the one of the report as mentioned above. Try again"
  exit 0
fi

echo -e '\0033\0143'
echo -e "Generating current HDFS usage and comparing with the entered report.\nThis is going to take some time according to your cluster size \n"


# Renew hdfs ticket if this is a kerberised cluster
#sudo -u hdfs bash -c "kinit -kt ~hdfs/hdfs.keytab hdfs@REALM.COM"

> $FINAL_REPORT
while read DIR
do
  echo -e "$DIR" >> $FINAL_REPORT
  sudo -u hdfs hadoop fs -du -h $DIR |  awk '$4 ~ /P|T|G/ && $2 !~ /K|M/ && $3 !~ /K/ {print $0}' | awk '{print $3 $4 "\t" $1 $2 "\t" $5}' | sort -hr | awk '{ printf "%-80s %-15s %s\n", $3, $2, $1}'>> $FINAL_REPORT
done < $INPUT_FILE

> $TEMP
cat $FINAL_REPORT | awk '$3 ~ /G|T|P/ { print $0 }' >> $TEMP

while read line
do
  FILE=`echo "$line" | awk '{print $1}'`
  LAST_REPORT_FILE_NAME=`grep "${FILE}\s" $REPORT_DIR/$_YEAR/$_MONTH/$_REPORT`
  LAST_REPORT_FILE_DATA=`echo "$LAST_REPORT_FILE_NAME" | awk '{print $3}'`
  LAST_REPORT_FILE=`echo "$LAST_REPORT_FILE_NAME" | awk '{print $1}'`
  if [[ "$FILE" = "$LAST_REPORT_FILE" ]]; then
    sed -i "s|$line|$line    $LAST_REPORT_FILE_DATA|g" $FINAL_REPORT
  fi
done < $TEMP

printf "%-80s %-15s %-15s %s\n" 'DIRECTORY' 'DU' 'DU WITH REP' 'PREVIOUS DATA'
while read line
do
  echo $line | awk '{ printf "%-80s %-15s %-15s %s\n", $1, $2, $3, $4}'
done < $FINAL_REPORT
