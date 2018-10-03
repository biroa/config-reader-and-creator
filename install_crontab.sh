#!/usr/bin/env bash

# Color initializations for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# The file we need to delete and recreate
fileName="test"
copyToPath=$PWD
copyFromPath="/Crontab/"

# delete cron file
deleteCron () {
	rm -rf $fileName || true
}

# copy file from the $copyFromPath to the $copyToPath as $fileName
copyCron () {
	parameter=("$@")
	copyFrom="$copyFromPath${parameter[0]}"
	cp -r "$copyToPath$copyFrom" $fileName
}

# loop over all the lines of a file
# look for a specific name
readProp () {
    parameter=("$@")
    file="${parameter[0]}"
    keyword="${parameter[1]}"
    value="${parameter[2]}"
	todoFunctions="${@:4}"
	functionsNum="${#todoFunctions[@]}"

	counter=0
	while IFS='' read -r line || [[ -n "$line" ]]; do
		propertyName=$(awk -F= '{print $1}' <<< "$line")
		counter=$[counter + 1]
		if [ "$propertyName" == $keyword ];
		then
		    environment=$(awk -F= '{print $2}' <<< "$line")
			if [ "$environment" == $value ];
			    then
					echo "$counter: $propertyName   ==> $environment"
			fi
		fi
	done < "$file"

		# if the functionsNum array is not empty
	if [ "$functionsNum" -gt 0 ];
	then
		for i in $todoFunctions
		do
			if [ -n "$(type -t ${i})" ] && [ "$(type -t ${i})" = function ];
			then
				${i} $environment
			else
				echo -e "${RED}There is no function defined as:${YELLOW} $i ${RED}!!!${NC}"
			fi
		done
	fi


}

tasks=("deleteCron" "copyCron")

# $1 : {name of the file} as the source of haystack
# $2 : The keyword we look for in the haystack
# $3 : Value which will trigger the event we like to do
# $4 : List of function we like to chain for further process
readProp $1 resourceName devRemaining "${tasks[@]}"
