#!/usr/bin/perl

use strict;
use warnings;

my $last_start = 2947;
my $last_run = 4980;
my @ends;   # the ends array is sorted from large to small
my %mapfiles;
my $open_mapfile = "prexCH_beamline_eventcuts.map";

# open (my $in, "<", "test");
LINE: while (<>) {
    chomp;
    # print "process $. record: $_ \n";

    my ($current_start, $current_end, $last_end, $open_flag);   # $current_end >= $current_start >= $last_start
    if (/(\d\d\d\d)-(\d\d\d\d)/) {
	$current_start = $1;
	$current_end = $2;
	# check the initial (first accepted) run: 3000
	if ($current_end < $last_start) {
	    next LINE;   # runs before the first accepted run
	}
    } elsif (/(\d\d\d\d)-/) {
	$current_start = $1;
	$open_flag=1;
    } elsif (/\d\d\d\d/) {
	$current_start = $&;
	$current_end = $&;
	if ($current_end < $last_start) {
	    next LINE;   # runs before the first accepted run
	}
    } else {
	print "Wrong format"
    }

    if ($current_start <= $last_start) { # some runs before the first accepted run
	if ($current_end && $current_end >= $current_start) {
	    $mapfiles{$current_end} = "prexCH_beamline_eventcuts.$_.map";
	    push @ends, $current_end;
	}
	next LINE;
    } 

    $mapfiles{$current_start} = "prexCH_beamline_eventcuts.$_.map"; # ntoe here: if $current_start = $last_end, then current mapfile will overwrite old value
    $mapfiles{$current_end} = "prexCH_beamline_eventcuts.$_.map" if $current_end;

    if (@ends) {
	while (($last_end = pop @ends) && $current_start > $last_end) {
	    print "$last_start\t$last_end\t", mapfile($last_start, $last_end), "\n";
	    $last_start = $last_end + 1;
	}

	if ($last_end && $current_start <= $last_end) {    
	    push @ends, $last_end;
	} 
    }

    $last_end = $current_start - 1;
    if ($last_end >= $last_start) {
	print "$last_start\t$last_end\t", mapfile($last_start, $last_end), "\n";
    }
    $last_start = $last_end + 1;
    $open_mapfile = "prexCH_beamline_eventcuts.$_.map" if $open_flag;
    push (@ends, $current_end) if ($current_end && $current_end >= $current_start);
    @ends = reverse sort @ends if (@ends);
}

push @ends, $last_run;
@ends = reverse sort @ends;
while (my $last_end = pop @ends) {
    print "$last_start\t$last_end\t", mapfile($last_start, $last_end), "\n";
    $last_start = $last_end + 1;
}


sub mapfile {
    my ($start, $end);
    $start = shift;
    $end = shift;
    if ($mapfiles{$start}) {
	return $mapfiles{$start};
    } elsif ($mapfiles{$end}) {
	return $mapfiles{$end};
    } else {
	return $open_mapfile;
    }
}

