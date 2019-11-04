* run 4396: normalized_lower_limit: 60 

* add legend to double_var plots

# observation
* no burplevel cut for bcm
* bcm_dg_us.flag:run	bcm_dg_us never used for cut
* bcm stability: normalized_stability, bcm_an_ds.stability and bcm_an_ds3.stability: the usual value being 1.4, 
  for some runs before ~3600, it is set to be 0.8

bpm:
* for 70 runs (<= 3447), the bpm4a_ym.lower_limit == 10000
* bpm4a_absx.lower_limit (3540-3542, 3455, 3524, 3540): a few runs has lower_limit as -10 (normal value being -200)
  bpm4a_absy.lower_limit (3540-3542, 3455, 3524, 3540): a few runs has lower_limit as -10 (normal value being -200)
and bpm4a_absy.lower_limit: a few runs has lower_limit ~ -10 (normal value being -200)
* bpm4a_effectivecharge 
    3450-3452, 3455, 3489, 3524, 3540: has lower_limit as 0 (others not set)

#  Overview
This small analysis program is composed of a few scripts:
* runcuts.sh	    :: a shell script that glues other scripts together
* split_run.pl	    :: a perl script that splits runs, deciding mapfile for each run range
* extract_cut.awk   :: a awk script that check each cut condition and then extract them into a csv file
* make_tree.C	    :: as its name implies, this C macro makes a tree from the produced csv file

# execution
* ./runcuts.sh	    
    a simple command, but you need to make sure that this script lies in the same dir. where
    the mapfiles stay.
* root make_tree.C  
    if you already has a csv file, then you can directly run the C macro to make tree, 
    of course, you need to make sure the name of the csv file is the same as it appears
    in the macro

# root file:
* branch and leaf
    1. run	    : run number
    2. mapfile	    : mapfile where the cuts come from
    3. normalized_bcm   : the bcm used for normalization
       normalized_lower_limit   : lower limit of normalized_bcm
       normalized_upper_limit   : upper limit of normalized_bcm
       normalized_stability	: stability cut of normalized_bcm
       normalized_burplevel	: burplevel cut of normalized_bcm
    4. bcm_an_us, bcm_an_ds, bcm_an_ds3, bcm_dg_us, bcm_dg_ds
	each branch has 6 leaves:
	* flag:	indicate if the bcm is cut or not, 1 means used for cut, -1 mean not
	* lower_limit
	* upper_limit
	* global/local:	    -1 is unset, 0 is local, 1 is global, 2 is invalid setting
	* stability
	* burplevel
    5. each channel (xp, xm, yp, ym, absx, absy and effectivecharge) of each BPM (bpm4a, bpm4e, bpm11, bpm12)
       they are connected by "_" (e.x. bpm4a_absx)
	this has the same leaves as bcm

# cuts.csv
* begin_run	end_run	    mapfile	5 bcms x 6 cut/bcm	normalized_bcm	    normalized_lower_limit	normalized_upper_limit	    normalized_stability    normalized_burplevel    4 bpms x 7 channels/bpm x 6 cuts/channel
*   1		  2	       3	    4 - 33		    34			    35				36			37			    38				39 - 206
# run_cuts.txt
* run	slug	mapfile	    5 bcms x 6 cut/bcm	normalized_bcm	    normalized_lower_limit	normalized_upper_limit	    normalized_stability    normalized_burplevel    4 bpms x 7 channels/bpm x 6 cuts/channel
* 1	 2	   3		4 - 33		    34			    35				36			37			    38				39 - 206

# Miscellaneous
* if you want to make any change, please make a copy and then do it in your version
* start run
    you can modify this value in **split_run.pl**, currently, I set is as 3000:
	my $last_start = 3000
* cut condition check
    If you have some idea about cut condition check, then you can add it in 
    **extract_cut.awk**
