# HDFS_Report
#
#What is the use of this script?
#
# Here is a set of two scripts which will help you to generate HDFS storage report and also compare current ulitization with any previous day/month.
#
# How the script works ?
# 
# One script (hdfs_report.sh) runs and generate current HDFS utilization report. 
# Cron task can be added to run this on a daily/weekly basis(according to your requirement)
# Example : 
# 00      4       *       *       *       /root/hdfs_report.sh
# This cron task will run the script everyday at 4 AM
# 
#The other script(hdfs_report_calculator.sh) can be run manually to generate current HDFS utilization and compares it with your desired day and lets you identify the HDFS storage space(file/directories) from a previous date.
#
# Who will benifit from this script?
#
# 1. The generated report can be used by project managers/Architect to identify the rate of HDFS storage growth and identify if the rate is as expected, this will also help identify unwanted space used(knowingly or unknowningly)
# 2. Hadoop Admins can keep track of HDFS storage and identify where exactly the space is being utilized, may ask user/group to remove unwanted data.

