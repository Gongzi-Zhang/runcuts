#!/bin/bash

last="normalized_2948-.map"
TEMP1="tmp1.tmp"
TEMP2="tmp2.tmp"
awk '{print $1, $2, $3}' run_cuts.txt | while read run slug mapfile; do 
    nmap=${mapfile#*.}
    nmap="normalized_$nmap"
    if ! diff -q $last $nmap &> /dev/null; then 
	echo "$run    $slug    $mapfile    Y" > "$TEMP1"
	paste $last $nmap | column -s $'\t' -tn > "$TEMP2"
	sed -i '1{x;G}' "$TEMP2"
	paste $TEMP1 $TEMP2 | column -s $'\t' -tn
       	last=$nmap
	rm "$TEMP1" "$TEMP2"
    else 
	echo "$run    $slug    $mapfile"
    fi
done | tee diff_log


