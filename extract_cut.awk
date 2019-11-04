#!/usr/bin/awk

BEGIN {
    if (! start_run || ! end_run) {
	print "Error: Missing run_number, please check it"
	usage()
	exit 1 
    }
    if (! mapfile) {
	print "Error: Missing mapfile name, please check it"
	usage()
	exit 1 
    }
    if (! output) {
	print "Set default output as cuts.csv"
	output="cuts.csv"
    }

    nBCM = split("bcm_an_us bcm_an_ds bcm_an_ds3 bcm_dg_us bcm_dg_ds", BCMs)
    nBCM_cut = split("flag lower_limit upper_limit local_global stability burplevel", BCM_cuts)
    nBPM = split("bpm4a bpm4e bpm11 bpm12", BPMs)	    # actually, no bpm4ac and bpm4ec, they are all commented out
    nBPM_channel = split("xm xp ym yp absx absy effectivecharge", BPM_channels)
    nBPM_cut = split("flag lower_limit upper_limit local_global stability burplevel", BPM_cuts)
    
    # initialization
    for(i in BCMs) {
	for(j in BCM_cuts) {
	    cut[BCMs[i], BCM_cuts[j]] = -1
	}
    }
    for(i in BPMs) {
	for(j in BPM_channels) {
	    for(k in BPM_cuts) {
		cut[BPMs[i], BPM_channels[j], BCM_cuts[k]] = -1
	    }
	}
    }

    # normalized bcm
    {
	normalized["bcm"] = "bcm"
	normalized["lower_limit"] = -1
	normalized["upper_limit"] = -1
	normalized["stability"] = -1
	normalized["burplevel"] = -1
    }

    BCM_lower_limit=0
    BCM_upper_limit=1e6
    BCM_global_lower_limit=0	# this value depends on run current
    BPM_lower_limit=0
    BPM_upper_limit=1e6
    BPM_abs_lower_limit=-500

    global_BCM_count = 0
}


# bcm
$1 ~ /bcm/{
    # field 1-4
    ## check error
    if ( !contains(BCMs, $2)) {	# unknow bcm
	print "Error: New bcm not listed: ", $2, "in mapfile: ", mapfile
	next
    }

    if (NF < 4) {   # at least lower and upper limit needed
	print "Error: Invalid BCM cut line in mapfile:", mapfile, "\n\t", $0
	next
    }
    if ($3 < BCM_lower_limit) {	# though wrong, still record it
	print "Error: Invalid BCM lower limit cut for bcm:", $2, "in mapfile:", mapfile
    }
    if ($4 > BCM_upper_limit) {	# though wrong, still record it
	print "Error: Invalid BCM upper limit cut for bcm:", $2, "in mapfile:", mapfile
    }

    BCM_count[$2]++ # check repeat setting
    values = $3
    for(i=4; i<=NF; i++) {
	values = values" "$i
    }
    BCM_cut_value[values]++ # check for the same cut values

    ## assign values
    cut[$2, "flag"] = 1
    cut[$2, "lower_limit"] = $3
    cut[$2, "upper_limit"] = $4

    # field >= 5
    if (NF >= 5) {
	if ($5 !~ /[gl]/) { # check g/l flag
	    print "Error: Invalid local/global cut value for bcm:", $2, "in mapfile:", mapfile
	    cut[$2, "local_global"] = 2	# invalid setting
	} else {
	    cut[$2, "local_global"] = $5 == "g" ? 1 : 0
	}

	if ($5 == "g") {    # normalized BCM
	    if (global_BCM_count > 0) {	# if multiple global setting, use the last one for normalization
		print "Error: More than 1 global BCM setting in mapfile:", mapfile
	    }
	    global_BCM_count++
	    normalized["bcm"] = $2
	    normalized["lower_limit"] = $3
	    normalized["upper_limit"] = $4
	    if ($6) normalized["stability"] = $6
	    if ($7) normalized["burplevel"] = $7
	}
    } 
    if (NF > 5) cut[$2, "stability"] = $6
    if (NF > 6) cut[$2, "burplevel"] = $7
}

$1 ~ /bpmstripline/{
    # field 1-5
    ## check errors
    if ( !contains(BPMs, $2) ) {    # check new BPM
	print "Error: New bpm not listed: ", $2, "in mapfile: ", mapfile
	next
    }
    if ( !contains(BPM_channels, $3) ) {    # check new BPM channel
	print "Error: New bpm channel not listed: ", $3, "in mapfile: ", mapfile
	next
    }

    if (NF < 5) {   # at least 5 fields
	print "Error: Invalid BMM cut line in mapfile:", mapfile, "\n\t", $0
	next
    }
    if ($3 ~ /abs[xy]/) {
	if ($4 < BPM_abs_lower_limit) {
	    print "Error: Invalid BPM lower limit cut for bpm channel:", $2"_"$3, "in mapfile:", mapfile
	}
    } else {
	if ($4 < BPM_lower_limit) {
	    print "Error: Invalid BPM lower limit cut for bpm channel:", $2"_"$3, "in mapfile:", mapfile
	}
    }
    if ($5 > BPM_upper_limit) {
	print "Error: Invalid BPM upper limit cut for bpm channel:", $2"_"$3, "in mapfile:", mapfile
    }

    BPM_count[$2, $3]++	    # check repeat setting
    if ($3 ~ /abs[xy]/) {   # check BPM abs channel cut value
	values=$4
	for(i=5; i<=NF; i++) {
	    values = values" "$i
	}
	BPM_abs_cut_value[values]++	# check for the same cut values
	if ($7) BPM_abs_stability[$7]++	# check the same value stability
	if ($8) BPM_abs_burplevel[$8]++	# check the same value burplevel
    }
	
    ## assignment
    cut[$2, $3, "flag"] = 1
    cut[$2, $3, "lower_limit"] = $4
    cut[$2, $3, "upper_limit"] = $5

    if (NF > 5) {
	if ($6 !~ /[gl]/) {
	    print "In mapfile:", mapfile, "find wrong cut setting in line:\n\t\t", $0
	    cut[$2, $3, "local_global"] = 2
	} else {
	    cut[$2, $3, "local_global"] = $6 == "g" ? 1 : 0
	}
    }
    if (NF > 6) cut[$2, $3, "stability"] = $7
    if (NF > 7) cut[$2, $3, "burplevel"] = $8
}

END{
    # error check
    for(i in BCM_count) {
	if (BCM_count[i] > 1) {
	    print "Error: Repeated cut for", i, "in mapfile:", mapfile
	}
    }
    for(i in BPM_count) {
	if (BPM_count[i] > 1) {
	    split(i, keys, SUBSEP)
	    print "Error: Repeated cut for", keys[1]"_"keys[2], "in mapfile:", mapfile
	}
    }

    for(i in BCM_cut_value) {
	if (BCM_cut_value[i] > 1) {
	    print "Error: find the same value cut set of BCMs in mapfile:", mapfile, "\n\t", i
	}
    }
    for(i in BPM_abs_cut_value) {
	split(i, keys, " "); 
	if (BPM_abs_cut_value[i] > 1) {
	    print "Error: find the same value cut set for different BPM abs channels in mapfile:", mapfile, "\n\t", i
	} else if (keys[4] && BPM_abs_stability[keys[4]] > 1) {
	    print "Error: find the same stability value", keys[4], "for different BPM abs channel in mapfile:", mapfile
	} else if (keys[5] && BPM_abs_burplevel[keys[5]] > 1) {
	    print "Error: find the same burplevel value", keys[5], "for different BPM abs channel in mapfile:", mapfile
	}
    }

    # output
    ORS="\t"
    print start_run, end_run >> output
    print mapfile >> output
    for(i in BCMs) {
	# print cut[BCMs[i], "flag"] >> output
	for(j in BCM_cuts) {
	    print cut[BCMs[i], BCM_cuts[j]] >> output
	}
    }
    {
	print normalized["bcm"] >> output
	print normalized["lower_limit"] >> output
	print normalized["upper_limit"] >> output
	print normalized["stability"] >> output
	print normalized["burplevel"] >> output
    }
    for(i in BPMs) {
	for(j in BPM_channels) {
	    # print cut[BPMs[i], BPM_channels[j], "flag"] >> output
	    for(k in BPM_cuts) {
		print cut[BPMs[i], BPM_channels[j], BPM_cuts[k]] >> output
	    }
	}
    }
    ORS="\n"
    print "\t" >> output
}

function contains(a, b) {	# a contains b or not
    for (i in a) {
	if (a[i] == b) return 1
    }
    return 0
}

function usage() {
    print "awk -v start_run=1234 end_run=3456 -v mapfile=\"mapfile_name\" -f extract.awk -- mapfile"
}
