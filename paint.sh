#!/usr/bin/env bash

set -e

# shellcheck source=lib-date.sh
source "$(dirname "$0")/lib-date.sh"

commitmax=${commitmax:-50}

if [ ! -z "${username}" ]; then
	if [ ! -z "$(which curl 2> /dev/null)" ]; then
		fetchcmd="curl -s"
		else if [ ! -z "$(which wget 2> /dev/null)" ]; then
			fetchcmd="wget -q -O -"
		fi
	fi

	if [ ! -z "${fetchcmd}" ]; then
		max=$($fetchcmd "https://github.com/${username}"|tr '<> ' "\n"|grep data-count|tr '="' "\n"|grep -v data-count|grep -v '^$'|sort -nr|head -1)
		commitmax=${max:-${commitmax}}
	fi
fi

while read line
do
	IFS='-' read -r Y M D I <<< "$line"
	I=$((${I:-4}*(${commitmax:-50}+1)))
	d="$Y-$M-$D"
	for i in $( eval echo {1..$I} )
	do
		tm="$(sec_to_time ${i})"
		export GIT_COMMITTER_DATE="$d $tm"
		export GIT_AUTHOR_DATE="$d $tm"
		git commit --date="$d $tm" -m "$i on $d" --no-gpg-sign --allow-empty
	done
done < "$(dirname "$0")/dates.txt"
