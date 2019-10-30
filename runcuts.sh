#!/bin/bash

##########
# todo:
#   1. how to update one mapfile: it is easy to udpate cuts.csv, but how to update root tree
#   2. may need to add more check conditions
##########

function check_file_existance {
    while [ $# -gt 0 ]; do
	if [ -d "$1" ]; then
	    echo "$1 is a dir. please check it, abort execution."
	    exit 1
	fi

	if [ -f "$1" ]; then
	    read -p "file $1 already exist, do you want to remove it? [yn] " yesno 
	    case $yesno in
		[yY*])
		    echo "removing $1 now..."
		    rm -f "$1"
		    ;;
		[nN*])
		    echo "You don't want to remove $1, abort execution"
		    exit 2
		    ;;
		*)
		    echo "Unknow response, abort execution"
		    exit 3
		    ;;
	    esac
	fi
	shift
    done
}

OUTPUT="cuts.csv"
check_file_existance "$OUTPUT" 
declare -A line_numbers
ls prexCH*eventcuts.*.map | cut -d'.' -f2 | perl split_runs.pl |  while read start_run end_run mapfile; do
# while [ $# -gt 0 ]; do
#     mapfile=$1; shift
#     run_number=${mapfile#*.}
#     run_number=${run_number%.*}
#     [ "$run_number" = "map" ] && run_number="default"	# for default mapfile: prexCH_beamline_eventcuts.map

    
    # echo "Info: process run $start_run-$end_run with mapfile: $mapfile"
    run_range=$(echo $mapfile | cut -d'.' -f2)
    if [[ "$run_range" =~ ^[0-9]{4}-$ ]]; then
        nline=${line_numbers[$mapfile]}
        if [ -z "$nline" ]; then    # no such record
            n=$(wc -l "$OUTPUT" | cut -d' ' -f1)
            let n++
            line_numbers[$mapfile]=$n
        else	# record already exist
            record=$(sed -n "${n}p" "$OUTPUT" | sed -E "s/^([0-9]{4})(\\s*)([0-9]{4})/$start_run\\2$end_run/")
            echo "$record" >> "$OUTPUT"
            continue
        fi
    fi
    TEMP="$start_run-$end_run.tmp" # check tmp file existance
    check_file_existance "$TEMP"
    # remove comment and blank lines; also remove comma
    cat $mapfile    \
	| grep -v '^\s*$'	\
	| grep -v '^\s*!'	\
	| grep -v 'EVENTCUT'	\
	| sed 's/,//g; s/\s\+/ /g'  \
	| sed 's/^\s*//g'   > $TEMP
    # check_error $mapfile $TEMP
    # assume no error (repeating) after checking error
    awk -v start_run=$start_run -v end_run=$end_run -v mapfile=$mapfile -v output=$OUTPUT -f extract_cut.awk -- $TEMP
    rm $TEMP
done

# good runs
# ./good_runs.sh

# make tree
ROOTFILE="run_cuts.root"
check_file_existance "$ROOTFILE"
root -l make_tree.C <<END
.q
END



function check_error {
    if [ $# -lt 2 ]; then
       	echo "At least 2 argument: mapfile name and clean mapfile needed"
	return 2
    fi
    local file_name=$1
    local mapfile=$2
    shift; shift
    if  [ $# -gt 0 ]; then
	echo "More than 2 arguments, ignore the extra ones."
    fi

    # old_BCM_channel_number=$(grep "BCM" $mapfile | cut -d' ' -f1-2 | wc -l)
    # new_BCM_channel_number=$(grep "BCM" $mapfile | cut -d' ' -f1-2 | sort | uniq | wc -l)
    # old_BPM_channel_number=$(grep "bpmstripline" $mapfile | cut -d' ' -f1-3 | wc -l)
    # new_BPM_channel_number=$(grep "bpmstripline" $mapfile | cut -d' ' -f1-3 | sort | uniq | wc -l)
    # if [ $old_BCM_channel_number -ne $new_BCM_channel_number ]; then
    #     echo "Error: Find repeated BCM cut in mapfile $file_name, please check it"
    # fi
    # if [ $old_BPM_channel_number -ne $new_BPM_channel_number ]; then
    #     echo "Error: Find repeated BPM cut in mapfile $file_name, please check it"
    # fi

    grep "BCM" $mapfile | sort | uniq | cut -d' ' -f3- |  \
	awk -v mapfile=$file_name   \
	   '{cut[$0]++};
	    END{ 
		for(i in cut) {
		    if (cut[i] > 1) {
			print "Error: find the same value cut set of BCMs in mapfile: ", mapfile, "\n\t", i
		    }
		}
	    }'

    grep "bpmstripline" $mapfile | sort | uniq | grep 'abs' | cut -d' ' -f4- |	\
	awk -v mapfile=$file_name   \
	   '{cut[$0]++; stability[$7]++; burplevel[$8]++};
	    END{ 
		for(i in cut) {
		    split(i, values, SUBSEP); 
		    if (cut[i] > 1) {
			print "Error: find the same value cut set for different BPM abs channels in mapfile: ", mapfile, "\n\t", i
		    } else if (stability[values[4]] > 1) {
			print "Error: find the same stability value", values[4], " for different BPM abs channel in mapfile: ", mapfile
		    } else if (burplevel[values[5]] > 1) {
			print "Error: find the same burplevel value", values[5], " for different BPM abs channel in mapfile: ", mapfile
		    }
		}
	    }'
    # old_BCM_cut_number=$(grep "BCM" $mapfile | sort | uniq | wc -l)
    # new_BCM_cut_number=$(grep "BCM" $mapfile | sort | uniq | cut -d' ' -f2- | sort | uniq | wc -l)
    # old_BPM_cut_number=$(grep "bpmstripline" $mapfile | sort | uniq | wc -l)
    # new_BPM_cut_number=$(grep "bpmstripline" $mapfile | sort | uniq | cut -d' ' -f3- | sort | uniq | wc -l)
    # if [ $old_BCM_cut_number -ne $new_BCM_cut_number ]; then
    #     echo "Error: Find the same value cut set of BCM in mapfile: $file_name"
    # fi
    # if [ $old_BPM_cut_number -ne $new_BPM_cut_number ]; then
    #     echo "Error: Find the same value cut set of BPM in mapfile: $file_name"
    # fi

    # cut value
    BCM_lower_cut_limit=0
    BCM_upper_cut_limit=1000000
    BPM_lower_cut_limit=0
    BPM_upper_cut_limit=1000000
    grep '^bcm' $mapfile |  \
	awk "NF < 4 {print \"Error: Invalid BCM cut line in mapfile: $file_name\\n\\t\", \$0 }
	     \$3 < $BCM_lower_cut_limit {print \"Error: Invalid BCM lower limit cut for bcm: \", \$2, \" in mapfile: $file_name\"}
	     \$4 > $BCM_upper_cut_limit {print \"Error: Invalid BCM upper limit cut for bcm: \", \$2, \" in mapfile: $file_name\"}
	     \$5 !~ /[gl]/ {print \"Error: Invalid local/global cut value for bcm: \", \$2, \" in mapfile: $file_name\"}"
    grep \"^bpmstripline\" $mapfile |  \
	awk "NF < 5 {print \"Error: Invalid BPM cut line in mapfile: $file_name\\n\\t\", \$0 }
	     \$4 < $BPM_lower_cut_limit {print \"Error: Invalid BPM lower limit cut for bpm channel: \", \$2\"_\"\$3, \" in mapfile: $file_name\"}
	     \$5 > $BPM_upper_cut_limit {print \"Error: Invalid BPM upper limit cut for bpm channel:\", \$2\"_\"\$3, \" in mapfile: $file_name\"}	\
	     \$6 !~ /[gl]/ {print \"Error: Invalid local/global cut value for bpm channel:\", \$2\"_\"\$3, \" in mapfile: $file_name\"}"
}
