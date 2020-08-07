: ${AUTH_USER=db2dat01}
USER=$(whoami)

start=`date +%s`
##############################Input parameters ###################################################################
# $1 :- Database Name

##############################Input parameters ###################################################################
echo "Script started....Please wait"
echo

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
NOW=$(date +"%FT%T")
LOGFILENAME="data_import_"
SCHEMA_NAME=$2
DATABASE_NAME=$1
#####################################################################################################
#
SOURCE_PATH="./"



INSIGHSTS_MOTIVATIONAL_INSIGHT_CSV="insights_motivational_inisghts.csv"
INSIGHTS_MI_DELIVERY_FEEDBACK_CSV="insights_mi_delivery_feedback"
ANALYTICS_STREAMS_CSV="analytics_streams.csv"
#####################################################################################################

LOGFILEPATH=$SOURCE_PATH/$LOGFILENAME$NOW



INSIGHSTS_MOTIVATIONAl_INSIGHT_QUERY="IMPORT FROM ./$INSIGHSTS_MOTIVATIONAL_INSIGHT_CSV OF DEL MODIFIED BY COLDEL0X09 INSERT INTO INSIGHTS.MOTIVATIONAL_INSIGHT(JSON_PAYLOAD,LAST_FEEDBACK_TIME,USER_FEEDBACK,INSIGHT_DELIVERED_AT,INSIGHT_TS,STREAM_ID,PERSON_ID,INSIGHT_ID,CREATED_AT)"

INSIGHTS_MI_DELIVERY_FEEDBACK_query="IMPORT FROM ./$INSIGHTS_MI_DELIVERY_FEEDBACK_CSV OF DEL MODIFIED BY COLDEL0X09 INSERT INTO  INSIGHTS.MI_DELIVERY_FEEDBACK(INSIGHT_ID,PERSON_ID,LIKE_FLAG,CHANGE_TS)"

ANALYTICS_STREAMS_query="IMPORT FROM ./$ANALYTICS_STREAMS_CSV OF DEL MODIFIED BY COLDEL0X09 INSERT INTO ANALYTICS.STREAMS(INSIGHT_ID,PERSON_ID,LIKE_FLAG,CHANGE_TS)"



if [ ! $USER = $AUTH_USER ]; then
	echo " Wrong user is executing this script ,Please connect with db2dat01"  >> $LOGFILEPATH.log
	exit 1
else
	echo >> $LOGFILEPATH.log
	echo "Correct Profile $USER initiating profile" >> $LOGFILEPATH.log
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

chmod -R 777 $SOURCE_PATH/*.log >> $LOGFILEPATH.log


#####################################################################################################
echo >> $LOGFILEPATH.log
echo "Importing the data from $INSIGHSTS_MOTIVATIONAL_INSIGHT_CSV" >> $LOGFILEPATH.log
echo
echo "Importing the data from $INSIGHSTS_MOTIVATIONAL_INSIGHT_CSV.."
#####################################################################################################

db2 $INSIGHSTS_MOTIVATIONAl_INSIGHT_QUERY >> $LOGFILEPATH.log

if [ $? -eq 0 ]
	then
		echo >> $LOGFILEPATH.log
		echo "#####################################################################################################">> $LOGFILEPATH.log
		echo "Data imported successfully from $INSIGHSTS_MOTIVATIONAL_INSIGHT_CSV" >> $LOGFILEPATH.log
		echo
		echo "Data imported successfully from $INSIGHSTS_MOTIVATIONAL_INSIGHT_CSV"
		echo "#####################################################################################################">> $LOGFILEPATH.log
	
	else
		echo >> $LOGFILEPATH.log
		echo "#####################################################################################################">> $LOGFILEPATH.log
		echo "Some error in importing $INSIGHSTS_MOTIVATIONAL_INSIGHT_CSV" >> $LOGFILEPATH.log
		echo "#####################################################################################################">> $LOGFILEPATH.log
	#exit 1
	fi
#####################################################################################################

#####################################################################################################
echo >> $LOGFILEPATH.log
echo "Importing the data from $ANALYTICS_STREAMS_CSV" >> $LOGFILEPATH.log
echo
echo "Importing the data from $ANALYTICS_STREAMS_CSV.."
#####################################################################################################

db2 $INSIGHTS_MI_DELIVERY_FEEDBACK_query >> $LOGFILEPATH.log

if [ $? -eq 0 ]
	then
		echo >> $LOGFILEPATH.log
		echo "#####################################################################################################">> $LOGFILEPATH.log
		echo "Data imported successfully from $ANALYTICS_STREAMS_CSV" >> $LOGFILEPATH.log
		echo
		echo "Data imported successfully from $ANALYTICS_STREAMS_CSV"
		echo "#####################################################################################################">> $LOGFILEPATH.log
	
	else
		echo >> $LOGFILEPATH.log
		echo "#####################################################################################################">> $LOGFILEPATH.log
		echo "Some error in importing $ANALYTICS_STREAMS_CSV" >> $LOGFILEPATH.log
		echo "#####################################################################################################">> $LOGFILEPATH.log
	#exit 1
	fi
#####################################################################################################
#####################################################################################################
echo >> $LOGFILEPATH.log
echo "Importing the data from $INSIGHTS_MI_DELIVERY_FEEDBACK_CSV" >> $LOGFILEPATH.log
echo
echo "Importing the data from $INSIGHTS_MI_DELIVERY_FEEDBACK_CSV.."
#####################################################################################################

db2 $ANALYTICS_STREAMS_query >> $LOGFILEPATH.log

if [ $? -eq 0 ]
	then
		echo >> $LOGFILEPATH.log
		echo "#####################################################################################################">> $LOGFILEPATH.log
		echo "Data imported successfully from $INSIGHTS_MI_DELIVERY_FEEDBACK_CSV" >> $LOGFILEPATH.log
		echo
		echo "Data imported successfully from $INSIGHTS_MI_DELIVERY_FEEDBACK_CSV"
		echo "#####################################################################################################">> $LOGFILEPATH.log
	
	else
		echo >> $LOGFILEPATH.log
		echo "#####################################################################################################">> $LOGFILEPATH.log
		echo "Some error in importing $INSIGHTS_MI_DELIVERY_FEEDBACK_CSV" >> $LOGFILEPATH.log
		echo "#####################################################################################################">> $LOGFILEPATH.log
	#exit 1
	fi
#####################################################################################################




#echo "Displaying errors..."
echo
echo "Script ended....Displaying errors if any..."
error=$(grep "SQLSTATE=" -B 3 $2/$LOGFILENAME.log)
echo >> $LOGFILEPATH.log
err_len=${#error} 
if [ "$err_len" = "0" ]; then
	echo "Execution complete Successfully without any errors.."
	echo >>  $LOGFILEPATH.log
	echo "Closing the Database connection" >>  $LOGFILEPATH.log
	db2 connect reset >> $LOGFILEPATH.log
else
	echo "Execution complete with error " 
	echo "Error .."
	echo $error
	exit 1
fi

echo
echo "For detail logs go to $LOGFILEPATH.log "
end=`date +%s`

runtime=$(((end-start)/60))
echo "Total time of execution =$runtime minutes"
