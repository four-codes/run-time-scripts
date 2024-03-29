#!/usr/bin/env bash

DIR=$(date -dmonday +%Y_%b_%d)

if [[ -d "${DIR}" ]]; then
	echo "Directory ${DIR} exists"
else
	echo "Directory ${DIR} does not exist, creating...."
	mkdir "${DIR}"
fi

cd ${DIR}

from_date=$(date -d "yesterday" '+%Y-%m-%d 00:00:00')
end_date=$(date '+%Y-%m-%d 00:00:00')

echo "Pulling LogDNA data from ${from_date} to ${end_date}"

/opt/ops-report/export_report_data.py -s "${from_date}" -e "${end_date}" --stats -r us-south

python combine_data.py -d $DIR/ -t _5-1_5-31 -f 'may_2020_23/_5-1_5-23,may_2020_31/_5-23_5-31' -r ALL

# folder directory dates

week_start_date=$(date -dlast-sunday +_%-m-%-d)
echo $week_start_date

week_end_date=$(date -dnext-saturday +_%-m-%-d)
echo "${week_end_date}"_"${week_start_date}"


# week wise execution

date_in_letters=$(date +'%a')

if [ "${date_in_letters}" == "Sat" ]; then
	echo "${date_in_letters}"
else 
	echo "${date_in_letters}"
	echo "non sat"
fi


# Month wise execution

last_date_current_month=$(date -d "-$(date +%d) days +1 month" +%d)
today_date=$(date +%d)
monthNumberic=$(date -d "-$(date +%d) days +1 month" +%-m)
dateNumeric=$(date --date="$(date +'%Y-%m-01') + 1 month" +%-d)
last_date_current_month_format=$(date -d "-$(date +%d) days +1 month" +%b-%Y-%m)
FinaldayNumeric=$(date -d "-$(date +%d) days +1 month" +%-m_%-d)

if [ "${today_date}" == "${last_date_current_month}" ]; then
	echo "${last_date_current_month}"
	python top_customer_single_file.py -d "${last_date_current_month_format}"/ -p "_${monthNumberic}-${dateNumeric}_${FinaldayNumeric}" -r ALL
	#python top_customer_single_file.py -d may_2020_30/ -p _5-1_5-30 -r ALL

else 
	echo "${today_date}"
fi



from_date=$(date -d "yesterday" '+%Y-%m-%d_00_00_00')
end_date=$(date  '+%Y-%m-%d_00_00_00')
dir_struc=$(date  '+%Y-%b-%d')

ibmcloud cos download --bucket logdna-cron-data --region us-geo --key "${dir_struc}"/us-south_"${from_date}"_"${end_date}"_count.txt us-south_"${from_date}"_"${end_date}"_count.txt && echo "$(date -u '+%Y-%m-%d %H:%M:%S'): Finished transfer to COS"
