#!/bin/bash

# Change the root directory according to your requirement.
ROOT_DIR="/root/scripts/REPORT"

DATE=`date +%d-%a-%b-%Y`
YEAR=`date +%Y`
MONTH=`date +%b`
REPORT_DIR="${ROOT_DIR}/hdfs_usage_report"
TEMP="${REPORT_DIR}/temp"


if [ ! -d $REPORT_DIR ] ; then mkdir -p $REPORT_DIR; fi

# Update the input file according to your requirement, this file will store directory name which is to be monitored
INPUT_FILE="${REPORT_DIR}/input_file"

if [ ! -f $INPUT_FILE ] ; then
        touch $INPUT_FILE
        echo '/user' >>  $INPUT_FILE
        echo '/spark' >>  $INPUT_FILE
        echo '/hbase' >>  $INPUT_FILE
        echo '/solr' >>  $INPUT_FILE
        echo '/tmp' >>  $INPUT_FILE
fi

cd $REPORT_DIR
if [[ ! -d Y$YEAR ]]; then
        mkdir Y$YEAR
fi
cd Y$YEAR
if [[ ! -d $MONTH ]]; then
        mkdir $MONTH
fi
cd $MONTH


# Renew hdfs ticket if this is a kerberized cluster
#sudo -u hdfs bash -c "kinit -kt ~hdfs/hdfs.keytab hdfs@REALM.COM"
while read DIR
do
  echo -e "$DIR" >> hdfs_report_${DATE}
  sudo -u hdfs hadoop fs -du -h $DIR |  awk '$4 ~ /P|T|G/ && $2 !~ /K|M/ && $3 !~ /K/ {print $0}' | awk '{print $3 $4 "\t" $1 $2 "\t" $5}' | sort -hr | awk '{ printf "%-80s %-15s %s\n", $3, $2, $1}'>> hdfs_report_${DATE}
done < $INPUT_FILE
