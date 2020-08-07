: ${AUTH_USER=db2dat01}
USER=$(whoami)

#!/bin/bash
#/usr/bin/env bash
set -o errexit
set -o errtrace
set -o nounset

############################################################################
#Usage:-
#1) Weekly option(Runs for one week in past from todays date)
#   ./<script_name>.sh -s weekly 
#2) All Option(Runs for all data till today)
#   ./<script_name>.sh -s all
############################################################################

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
NOW=$(date +"%FT%T")
LOGFILENAME="extract_hypo_r3_db2_"
LOGFILEPATH=$LOGFILENAME$NOW
DATABASE_NAME="MDTDB"



td=$(date +%m.%d.%Y)
ed=$(date +%m/%d/%Y)
sd=$(date -d '- 7 days' +%m/%d/%Y)
echo "todays date=${td}" >> $LOGFILEPATH.log

if [ ! $USER = $AUTH_USER ]; then
  echo " Wrong user is executing this script ,Please connect with db2dat01"  >> $LOGFILEPATH.log
  echo " Wrong user is executing this script ,Please connect with db2dat01" 
  exit 1
else
  echo >> $LOGFILEPATH.log
  #echo "Correct Profile $USER initiating profile" >> $LOGFILEPATH.log
  #source ~db2dat01/sqllib/db2profile
  
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

usage() { echo "Usage: $0 [-s <weekly|all>" 1>&2; exit 1; }
while getopts ":s:" o; do
    case "${o}" in
        s)
            s=${OPTARG}
            #echo "s is assigned as ${s}"
            if [ ${s} != "weekly" ] && [ ${s} != "all" ] ; then
                usage
                exit 1
            fi
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${s}" ] ; then
    usage
    exit 1
fi
echo "Option used to run the script is s = ${s}" 
case ${s} in
    "weekly")
      echo "The Script is running for option '-s weekly' for data between startdate=${sd} and enddate=${ed}"
      echo "The Script is running for option '-s weekly' for data between startdate=${sd} and enddate=${ed}" >> $LOGFILEPATH.log
      wst="date(created_at) < '${ed}' and date(created_at)>= '${sd}' "
      ;;
    "all")
      echo "The Script is running for option '-s all' where enddate=${ed}"
      echo "The Script is running for option '-s all' where enddate=${ed}" >> $LOGFILEPATH.log
      wst="date(created_at) < '${ed}' "
      ;;
    *)
      ;;
esac
echo "wst= ${wst}" >> $LOGFILEPATH.log


  

#All the CSV file names
ANALYTICS_STREAMS_ALERT_CSV="analytics.streams.alert.${s}.${td}.csv"
ANALYTICS_STREAMS_FEEDBACK_CSV="analytics.streams.feedback.${s}.${td}.csv"
MDT_SENSOR_GLUCOSE_DATA_CSV="mdt.sensor_glucose_data.${s}.${td}.csv"
MDT_HYPO_FEATURES_CSV="mdt.hypo_features.${s}.${td}.csv"

#All the queries used for export
ANALYTICS_STREAMS_ALERT_QUERY="export to $ANALYTICS_STREAMS_ALERT_CSV of del modified by nochardel COLDEL| select id, person_id, json_data, is_liked, created_at, created_at_tz, updated_at from analytics.streams where ${wst} and json_data like '%hypo.1%'"
ANALYTICS_STREAMS_FEEDBACK_QUERY="export to $ANALYTICS_STREAMS_FEEDBACK_CSV of del modified by nochardel COLDEL| select id, person_id, json_data, is_liked, created_at, created_at_tz, updated_at from analytics.streams where ${wst} and json_data like '%notice.1%' "
MDT_SENSOR_GLUCOSE_DATA_QUERY="export to $MDT_SENSOR_GLUCOSE_DATA_CSV of del modified by nochardel COLDEL| select id, person_id, sg, sg_timestamp, sg_timestamp_tz, time_change, created_at, updated_at from mdt.sensor_glucose_data where ${wst} "
MDT_HYPO_FEATURES_QUERY="export to $MDT_HYPO_FEATURES_CSV of del modified by nochardel COLDEL| select person_id, partition, sg_timestamp, format_version, created_at, updated_at, features from mdt.hypo_features where ${wst} "


#export the hypo alert and feedback data
echo "#######################################################################################################################################" >> $LOGFILEPATH.log
echo "Exporting the data from ANALYTICS.STREAMS for Prediction Alert to file $ANALYTICS_STREAMS_ALERT_CSV" >> $LOGFILEPATH.log
echo "Query used:-----" >> $LOGFILEPATH.log
echo $ANALYTICS_STREAMS_ALERT_QUERY >> $LOGFILEPATH.log
echo "----------------" >> $LOGFILEPATH.log
echo "#######################################################################################################################################" >> $LOGFILEPATH.log

db2 $ANALYTICS_STREAMS_ALERT_QUERY >> $LOGFILEPATH.log
sed -i '1i id|person_idi|json_data|is_liked|created_at|created_at_tz|updated_at' $ANALYTICS_STREAMS_ALERT_CSV >> $LOGFILEPATH.log

echo "#######################################################################################################################################" >> $LOGFILEPATH.log
echo "Exporting the data from ANALYTICS.STREAMS for Prediction Feedback to file $ANALYTICS_STREAMS_FEEDBACK_CSV" >> $LOGFILEPATH.log
echo "Query used:-----" >> $LOGFILEPATH.log
echo $ANALYTICS_STREAMS_FEEDBACK_QUERY >> $LOGFILEPATH.log
echo "----------------" >> $LOGFILEPATH.log
echo "#######################################################################################################################################" >> $LOGFILEPATH.log

db2 $ANALYTICS_STREAMS_FEEDBACK_QUERY >> $LOGFILEPATH.log
sed -i '1i id|person_id|json_data|is_liked|created_at|created_at_tz|updated_at' $ANALYTICS_STREAMS_FEEDBACK_CSV >> $LOGFILEPATH.log

echo "#######################################################################################################################################" >> $LOGFILEPATH.log
echo "Exporting the data from MDT.MDT_SENSOR_GLUCOSE_DATA SG Data to file $MDT_SENSOR_GLUCOSE_DATA_CSV" >> $LOGFILEPATH.log
echo "Query used:-----" >> $LOGFILEPATH.log
echo $MDT_SENSOR_GLUCOSE_DATA_QUERY >> $LOGFILEPATH.log
echo "----------------" >> $LOGFILEPATH.log
echo "#######################################################################################################################################" >> $LOGFILEPATH.log
#export the mdt sg data
db2 $MDT_SENSOR_GLUCOSE_DATA_QUERY >> $LOGFILEPATH.log
sed -i '1i id|person_id|sg|sg_timestamp|sg_timestamp_tz|time_change|created_at|updated_at' $MDT_SENSOR_GLUCOSE_DATA_CSV >> $LOGFILEPATH.log

echo "#######################################################################################################################################" >> $LOGFILEPATH.log
echo "Exporting the data from MDT.MDT_HYPO_FEATURERES_DATA that is hypo features data to file $MDT_HYPO_FEATURES_CSV" >> $LOGFILEPATH.log
echo "Query used:-----" >> $LOGFILEPATH.log
echo $MDT_HYPO_FEATURES_QUERY >> $LOGFILEPATH.log
echo "----------------" >> $LOGFILEPATH.log
echo "#######################################################################################################################################" >> $LOGFILEPATH.log

#export the hypo feature data
db2 $MDT_HYPO_FEATURES_QUERY >> $LOGFILEPATH.log
sed -i '1i person_id|partition_number|sg_timestamp|format_version|created_at|updated_at|created_at|features' $MDT_HYPO_FEATURES_CSV >> $LOGFILEPATH.log


chmod 777 *.csv
chmod 777 *.log

db2 connect reset >> $LOGFILEPATH.log

echo "The script ran successfully, please check the report in the log file $LOGFILEPATH.log"