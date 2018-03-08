#!/bin/bash

## Download the most current FMP full installer
## by Ben Mason, ben@allpurposeben.info

updateFeed=$(curl -sS http://www.filemaker.com/support/updaters/updater_json.txt?id=1231231231)
fullDLurlPart='http://fmdl.filemaker.com/maint/emea_fba_ftn'

jqCheck=$(which jq)
if [[ -z "$jqCheck" ]]; then
	echo "You need to have the jq cli tool installed for this to work."
	echo "It can be easily had from homebrew: brew install jq"
	exit 1
fi

for thisOne in 0 1 2 3; do
	# get the correct array reference data
	thisSection=$(echo "$updateFeed" | jq .[$thisOne])
	#check if this is for FMP for Mac
	if [[ -z $(echo "$thisSection" | grep '"product"' | grep '"FileMaker Pro"') ]]; then
		#it's not FMP, skip to the next
		continue
	elif [[ -z $(echo "$thisSection" | grep '"platform"' | grep '"Mac"') ]]; then
		# it's not the Mac version's data
		continue
	else
		# this is the array for FMP, lets get the info
		updateDLurl=$(echo "$thisSection" | jq .url | tr -d '"')
		versionNumberFull=$(echo "$updateDLurl" | awk -F '/' '{print $NF}' | awk -F '_' '{print $NF}' |sed 's/.\{4\}$//')
		fullDLurl="$fullDLurlPart/fmp_$versionNumberFull.dmg"
		# exit the loop
		break
	fi
done

if [ -z "$updateDLurl" ]; then
	# error, we didn't get everything
	echo "Error, something went wrong, couldn't determine the correct version"
	exit 2
else
	# download the stuff
	echo "Version is: $versionNumberFull"
	echo "Downloading updater and full installer."
	echo ''
	mkdir "$HOME/Desktop/FMP_$versionNumberFull"
	curl "$updateDLurl" -o "$HOME/Desktop/FMP_$versionNumberFull/FMP_Update-$versionNumberFull.zip"
	curl "$fullDLurl" -o "$HOME/Desktop/FMP_$versionNumberFull/FMP_Full-$versionNumberFull.dmg"
	open "$HOME/Desktop/FMP_$versionNumberFull"
fi

exit 0