: ${AUTH_USER=db2dat01}
USER=$(whoami)

#!/bin/bash
#/usr/bin/env bash
set -o errexit
set -o errtrace
set -o nounset

############################################################################
#Usage:-
# ./<script_name>.sh <weekly/all> <MM> <DD> <YYYY>
#   This script takes 4 parameters
#   $1 : Whether the inport file names has 'weekly' or 'all'.
#   $2 : month (MM) format in the name of the csv files to be imported. 
#   $3 : date (DD) format in the name of the csv files to be imported.
#   $4 : year in (YYYY) format in the name of the csv to be imported.
# Sample Command to run import script.
#   ./import_hypo_r3_db2.sh weekly 01 04 2019
############################################################################
usage() { echo "Usage: ./import_hypo_r3_db2.sh <weekly/daily> MM DD YYYY" 1>&2; exit 1; }



DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
NOW=$(date +"%FT%T")
LOGFILENAME="import_hypo_r3_db2_"
LOGFILEPATH=$LOGFILENAME$NOW
DATABASE_NAME="MDTDB"

if [ ! $USER = $AUTH_USER ]; then
  echo " Wrong user is executing this script ,Please connect with db2dat01"  >> $LOGFILEPATH.log
  echo " Wrong user is executing this script ,Please connect with db2dat01" 
  exit 1
else
  echo >> $LOGFILEPATH.log
  #echo "Correct Profile $USER initiating profile" >> $LOGFILEPATH.log
  #source ~db2dat01/sqllib/db2profile
  if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
    usage
    exit 1
  fi
  echo >> $LOGFILEPATH.log
  echo "Trying to connect to $1" >> $LOGFILEPATH.log
  
  db2 connect to $DATABASE_NAME >> $LOGFILEPATH.log
  if [ $? -eq 0 ]
  then
    echo >> $LOGFILEPATH.log
    echo "#####################################################################################################">> $LOGFILEPATH.log
    echo "Database $DATABASE_NAME connected successfully" >> $LOGFILEPATH.log
    echo
    echo "Database $DATABASE_NAME connected successfully" 
    echo "#####################################################################################################">> $LOGFILEPATH.log
  else
    echo >> $LOGFILEPATH.log
    echo "#####################################################################################################">> $LOGFILEPATH.log
    echo "Database Connection failed" >> $LOGFILEPATH.log
    echo "#####################################################################################################">> $LOGFILEPATH.log
  exit 1
  fi
fi






TYPE=$1 #ex : weekly/all 
MONTH=$2 #ex: 01
DAY=$3 #ex : 04
YEAR=$4 #ex: 2019



if [ -z "$TYPE" ]; then
  echo "First input parameter is empty"
  usage
  exit 1
  #statements
fi
if [ -z "$DAY" ]; then
  echo "Second input parameter is empty"
  usage
  exit 1
fi
if [ -z "$MONTH" ]; then
  echo "Third input parameter is empty"
  usage
  exit 1
fi
if [ -z "$YEAR" ]; then
  echo "Fourth input parameter is empty"
  usage
  exit 1
fi


echo "The input parameters to the script are as follows"
echo "TYPE=$TYPE"
echo "DAY=$DAY"
echo "MONTH=$MONTH"
echo "YEAR=$YEAR"
echo "The input parameters to the script are as follows" >> $LOGFILEPATH.log
echo "TYPE=$TYPE" >> $LOGFILEPATH.log
echo "DAY=$DAY" >> $LOGFILEPATH.log
echo "MONTH=$MONTH" >> $LOGFILEPATH.log
echo "YEAR=$YEAR" >> $LOGFILEPATH.log
echo "Script ran = ./import_hypo_r3_db2.sh $TYPE $MONTH $DAY $YEAR" >> $LOGFILEPATH.log

s=$TYPE
requestedDate=$MONTH.$DAY.$YEAR
#echo "td=$requestedDate"
  
CSV=".csv"
#All the CSV file names
ANALYTICS_STREAMS_ALERT_file="analytics.streams.alert.${s}.${requestedDate}"
echo "#####################################################################################################">> $LOGFILEPATH.log
echo "Script will look for below csv files for finding data to be imported:-" >> $LOGFILEPATH.log
echo >>$LOGFILEPATH.log
echo "ANALYTICS_STREAMS_ALERT_file=$ANALYTICS_STREAMS_ALERT_file$CSV" >> $LOGFILEPATH.log
ANALYTICS_STREAMS_FEEDBACK_file="analytics.streams.feedback.${s}.${requestedDate}"
echo "ANALYTICS_STREAMS_FEEDBACK_file=$ANALYTICS_STREAMS_FEEDBACK_file$CSV" >> $LOGFILEPATH.log
MDT_SENSOR_GLUCOSE_DATA_file="mdt.sensor_glucose_data.${s}.${requestedDate}"
echo "MDT_SENSOR_GLUCOSE_DATA_file=$MDT_SENSOR_GLUCOSE_DATA_file$CSV" >> $LOGFILEPATH.log
MDT_HYPO_FEATURES_file="mdt.hypo_features.${s}.${requestedDate}"
echo "MDT_HYPO_FEATURES_file=$MDT_HYPO_FEATURES_file$CSV" >> $LOGFILEPATH.log
INSIGHTS_PREDICTION_USER_FEEDBACK_file="insights.prediction_user_feedback.${s}.${requestedDate}"
echo "INSIGHTS_PREDICTION_USER_FEEDBACK_file=$INSIGHTS_PREDICTION_USER_FEEDBACK_file$CSV" >> $LOGFILEPATH.log
echo "#####################################################################################################">> $LOGFILEPATH.log

TEMP="_temp.csv"


#All the queries used for export
ANALYTICS_STREAMS_ALERT_IMPORT_QUERY="IMPORT FROM $ANALYTICS_STREAMS_ALERT_file$TEMP OF DEL MODIFIED BY COLDEL| INSERT INTO ANALYTICS.STREAMS (id, person_id, json_data, is_liked, created_at, created_at_tz, updated_at)"
ANALYTICS_STREAMS_FEEDBACK_QUERY="IMPORT FROM  $ANALYTICS_STREAMS_FEEDBACK_file$TEMP of del modified by COLDEL| INSERT INTO ANALYTICS.STREAMS(id, person_id, json_data, is_liked, created_at, created_at_tz, updated_at)"
MDT_SENSOR_GLUCOSE_DATA_QUERY="IMPORT FROM $MDT_SENSOR_GLUCOSE_DATA_file$TEMP of del modified by COLDEL| INSERT INTO mdt.sensor_glucose_data (id, person_id, sg, sg_timestamp, sg_timestamp_tz, time_change, created_at, updated_at)"
MDT_HYPO_FEATURES_QUERY="IMPORT FROM $MDT_HYPO_FEATURES_file$TEMP of del modified by COLDEL| INSERT INTO mdt.hypo_features(person_id, partition, sg_timestamp, format_version, created_at, updated_at, features)"
INSIGHTS_PREDICTION_USER_FEEDBACK_QUERY="IMPORT FROM $INSIGHTS_PREDICTION_USER_FEEDBACK_file$TEMP of del modified by COLDEL| INSERT INTO  insights.prediction_user_feedback (person_id, feedback_streams_id, feedback_action_tag_id, feedback_action_value, created_at,updated_at,submission_timestamp,submission_timestamp_tz,feedback_type)"


if [ ! -f "./$ANALYTICS_STREAMS_ALERT_file$CSV" ]
then
    echo "***************************************************************************************************************************************">> $LOGFILEPATH.log
    echo "ERROR: File '$ANALYTICS_STREAMS_ALERT_file$CSV' not found, so cannot import data from filename=$ANALYTICS_STREAMS_ALERT_file$CSV ." >> $LOGFILEPATH.log
    echo "***************************************************************************************************************************************">> $LOGFILEPATH.log
else
    
    echo "#######################################################################################################################################" >> $LOGFILEPATH.log
    echo "File '$ANALYTICS_STREAMS_ALERT_file$CSV' found." >> $LOGFILEPATH.log
    echo "Importing the data to ANALYTICS.STREAMS for Prediction Alert from file $ANALYTICS_STREAMS_ALERT_file$CSV" >> $LOGFILEPATH.log
    echo "Query used:-----" >> $LOGFILEPATH.log
    echo $ANALYTICS_STREAMS_ALERT_IMPORT_QUERY >> $LOGFILEPATH.log
    echo "----------------" >> $LOGFILEPATH.log
    echo "#######################################################################################################################################" >> $LOGFILEPATH.log
    sed 1d $ANALYTICS_STREAMS_ALERT_file$CSV > $ANALYTICS_STREAMS_ALERT_file$TEMP
    db2 $ANALYTICS_STREAMS_ALERT_IMPORT_QUERY >> $LOGFILEPATH.log
fi

if [ ! -f "./$ANALYTICS_STREAMS_FEEDBACK_file$CSV" ]
then
    echo "***************************************************************************************************************************************">> $LOGFILEPATH.log
    echo "ERROR:  File '$ANALYTICS_STREAMS_FEEDBACK_file$CSV' not found, so cannot import data from filename=$ANALYTICS_STREAMS_FEEDBACK_file$CSV." >> $LOGFILEPATH.log
    echo "***************************************************************************************************************************************">> $LOGFILEPATH.log
else
    echo "#######################################################################################################################################" >> $LOGFILEPATH.log
    echo "File '$ANALYTICS_STREAMS_FEEDBACK_file$CSV' found." >> $LOGFILEPATH.log
    echo "Importing the data to ANALYTICS.STREAMS for Prediction Feedback from file $ANALYTICS_STREAMS_FEEDBACK_file$CSV" >> $LOGFILEPATH.log
    echo "Query used:-----" >> $LOGFILEPATH.log
    echo $ANALYTICS_STREAMS_FEEDBACK_QUERY >> $LOGFILEPATH.log
    echo "----------------" >> $LOGFILEPATH.log
    echo "#######################################################################################################################################" >> $LOGFILEPATH.log
    sed 1d $ANALYTICS_STREAMS_FEEDBACK_file$CSV > $ANALYTICS_STREAMS_FEEDBACK_file$TEMP
    db2 $ANALYTICS_STREAMS_FEEDBACK_QUERY >> $LOGFILEPATH.log
  fi




if [ ! -f "./$MDT_SENSOR_GLUCOSE_DATA_file$CSV" ]
then
    echo "***************************************************************************************************************************************">> $LOGFILEPATH.log
    echo "ERROR:  File '$MDT_SENSOR_GLUCOSE_DATA_file$CSV' not found, so cannot import data from filename=$MDT_SENSOR_GLUCOSE_DATA_file$CSV." >> $LOGFILEPATH.log
    echo "***************************************************************************************************************************************">> $LOGFILEPATH.log
else
    echo "#######################################################################################################################################" >> $LOGFILEPATH.log
    echo "File '$MDT_SENSOR_GLUCOSE_DATA_file$CSV' found." >> $LOGFILEPATH.log
    echo "Importing the data to MDT.MDT_SENSOR_GLUCOSE_DATA SG Data from file $MDT_SENSOR_GLUCOSE_DATA_file$CSV" >> $LOGFILEPATH.log
    echo "Query used:-----" >> $LOGFILEPATH.log
    echo $MDT_SENSOR_GLUCOSE_DATA_QUERY >> $LOGFILEPATH.log
    echo "----------------" >> $LOGFILEPATH.log
    echo "#######################################################################################################################################" >> $LOGFILEPATH.log
    sed 1d $MDT_SENSOR_GLUCOSE_DATA_file$CSV > $MDT_SENSOR_GLUCOSE_DATA_file$TEMP
    db2 $MDT_SENSOR_GLUCOSE_DATA_QUERY >> $LOGFILEPATH.log
  fi


if [ ! -f "./$MDT_HYPO_FEATURES_file$CSV" ]
then
    echo "***************************************************************************************************************************************">> $LOGFILEPATH.log
    echo "ERROR:  File '$MDT_HYPO_FEATURES_file$CSV' not found, so cannot import data from filename=$MDT_HYPO_FEATURES_file$CSV." >> $LOGFILEPATH.log
    echo "***************************************************************************************************************************************">> $LOGFILEPATH.log
else
    echo "#######################################################################################################################################" >> $LOGFILEPATH.log
    echo "File '$MDT_HYPO_FEATURES_file$CSV' found." >> $LOGFILEPATH.log
    echo "Importing the data to MDT.MDT_HYPO_FEATURERES_DATA that is hypo features data from file $MDT_HYPO_FEATURES_file$CSV" >> $LOGFILEPATH.log
    echo "Query used:-----" >> $LOGFILEPATH.log
    echo $MDT_HYPO_FEATURES_QUERY >> $LOGFILEPATH.log
    echo "----------------" >> $LOGFILEPATH.log
    echo "#######################################################################################################################################" >> $LOGFILEPATH.log

    sed 1d $MDT_HYPO_FEATURES_file$CSV > $MDT_HYPO_FEATURES_file$TEMP
    db2 $MDT_HYPO_FEATURES_QUERY >> $LOGFILEPATH.log
  fi



if [ ! -f "./$INSIGHTS_PREDICTION_USER_FEEDBACK_file$CSV" ]
then
    echo "***************************************************************************************************************************************">> $LOGFILEPATH.log
    echo "ERROR:  File '$INSIGHTS_PREDICTION_USER_FEEDBACK_file$CSV' not found, so cannot import data from filename=$INSIGHTS_PREDICTION_USER_FEEDBACK_file$CSV." >> $LOGFILEPATH.log
    echo "***************************************************************************************************************************************">> $LOGFILEPATH.log
else
    echo "#######################################################################################################################################" >> $LOGFILEPATH.log
    echo "File '$INSIGHTS_PREDICTION_USER_FEEDBACK_file$CSV' found." >> $LOGFILEPATH.log
    echo "Importing the data to INSIGHTS.PREDICTION_USER_FEEDBACK_CSV that is prediction user feedback to file $INSIGHTS_PREDICTION_USER_FEEDBACK_file$CSV" >> $LOGFILEPATH.log
    echo "Query used:-----" >> $LOGFILEPATH.log
    echo $INSIGHTS_PREDICTION_USER_FEEDBACK_QUERY >> $LOGFILEPATH.log
    echo "----------------" >> $LOGFILEPATH.log
    echo "#######################################################################################################################################" >> $LOGFILEPATH.log
    sed 1d $INSIGHTS_PREDICTION_USER_FEEDBACK_file$CSV > $INSIGHTS_PREDICTION_USER_FEEDBACK_file$TEMP
    db2 $INSIGHTS_PREDICTION_USER_FEEDBACK_QUERY >> $LOGFILEPATH.log
  fi




chmod 777 *.csv
chmod 777 *.log
rm -rf *$TEMP

db2 connect reset >> $LOGFILEPATH.log

echo "The script ran successfully, please check the report in the log file $LOGFILEPATH.log"