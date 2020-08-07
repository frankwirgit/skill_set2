A) Below are the steps required to run the export script to export R3.0 hypo related data from db2


Steps
1. Login to the database server for which environment you need to export the db2 data.
2. You need to be user "db2dat01"
	
	command to run on terminal: 
		su db2dat01
	password: safe4whc
3. Usage for script extract_hypo_r3_db2.sh:-

	1) 'weekly' option(Runs for one week in past from todays date)
		   ./<script_name>.sh -s weekly 
		   example
		   ./extract_hypo_r3_db2.sh -s weekly

	2) 'all' Option(Runs for all data till today)
			./<script_name>.sh -s all
			example
			./extract_hypo_r3_db2.sh -s all

4. Once the above command is run there will be csv files created for exported data
	
	CSV file naming convention:  ${name of the table}.{alert | feedback}.{all | weekly}.{DD.MM.YY}
    
    Example: analytics.streams.alert.weekly.31.01.2018

5. In addition to the csv files you will get a log file created for each run which will give you details of the exported data
	and also the queries used to export it.

	Sample log file content
======================================================================================================================================
   Database Connection Information

 Database server        = DB2/LINUXX8664 10.5.7
 SQL authorization ID   = DB2DAT01
 Local database alias   = MDTDB


#####################################################################################################
Database MDTDB connected successfully
#####################################################################################################
The Script is running for option '-s all' where enddate=01/04/2019
wst= date(created_at) < '01/04/2019' 
#######################################################################################################################################
Exporting the data from ANALYTICS.STREAMS for Prediction Alert to file analytics.streams.alert.all.01.04.2019.csv
Query used:-----
export to analytics.streams.alert.all.01.04.2019.csv of del modified by nochardel COLDEL| select id, person_id, json_data, is_liked, created_at, created_at_tz, updated_at from analytics.streams where date(created_at) < '01/04/2019' and json_data like '%hypo.1%'
----------------
#######################################################################################################################################
SQL3104N  The Export utility is beginning to export data to file 
"analytics.streams.alert.all.01.04.2019.csv".

SQL3105N  The Export utility has finished exporting "1477" rows.


Number of rows exported: 1477

#######################################################################################################################################
Exporting the data from ANALYTICS.STREAMS for Prediction Feedback to file analytics.streams.feedback.all.01.04.2019.csv
Query used:-----
export to analytics.streams.feedback.all.01.04.2019.csv of del modified by nochardel COLDEL| select id, person_id, json_data, is_liked, created_at, created_at_tz, updated_at from analytics.streams where date(created_at) < '01/04/2019' and json_data like '%notice.1%'
----------------
#######################################################################################################################################
SQL3104N  The Export utility is beginning to export data to file 
"analytics.streams.feedback.all.01.04.2019.csv".

SQL3105N  The Export utility has finished exporting "395" rows.


Number of rows exported: 395

#######################################################################################################################################
Exporting the data from MDT.MDT_SENSOR_GLUCOSE_DATA SG Data to file mdt.sensor_glucose_data.all.01.04.2019.csv
Query used:-----
export to mdt.sensor_glucose_data.all.01.04.2019.csv of del modified by nochardel COLDEL| select id, person_id, sg, sg_timestamp, sg_timestamp_tz, time_change, created_at, updated_at from mdt.sensor_glucose_data where date(created_at) < '01/04/2019'
----------------
#######################################################################################################################################
SQL3104N  The Export utility is beginning to export data to file 
"mdt.sensor_glucose_data.all.01.04.2019.csv".

SQL3105N  The Export utility has finished exporting "653925" rows.


Number of rows exported: 653925

#######################################################################################################################################
Exporting the data from MDT.MDT_HYPO_FEATURERES_DATA that is hypo features data to file mdt.hypo_features.all.01.04.2019.csv
Query used:-----
export to mdt.hypo_features.all.01.04.2019.csv of del modified by nochardel COLDEL| select person_id, partition, sg_timestamp, format_version, created_at, updated_at, features from mdt.hypo_features where date(created_at) < '01/04/2019'
----------------
#######################################################################################################################################
SQL3104N  The Export utility is beginning to export data to file 
"mdt.hypo_features.all.01.04.2019.csv".

SQL3105N  The Export utility has finished exporting "649870" rows.


Number of rows exported: 649870

#######################################################################################################################################
Exporting the data from INSIGHTS.PREDICTION_USER_FEEDBACK_CSV that is hypo features data to file insights.prediction_user_feedback.all.01.04.2019.csv
Query used:-----
export to insights.prediction_user_feedback.all.01.04.2019.csv of del modified by nochardel COLDEL| select person_id, feedback_streams_id, feedback_action_tag_id, feedback_action_value, created_at,updated_at,submission_timestamp,submission_timestamp_tz,feedback_type from insights.prediction_user_feedback where date(created_at) < '01/04/2019'
----------------
#######################################################################################################################################
SQL3104N  The Export utility is beginning to export data to file 
"insights.prediction_user_feedback.all.01.04.2019.csv".

SQL3105N  The Export utility has finished exporting "15" rows.


Number of rows exported: 15

DB20000I  The SQL command completed successfully.
======================================================================================================================================

