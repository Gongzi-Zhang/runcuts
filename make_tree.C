#include <iostream>
#include <fstream>
#include <string>
// #include <bits/stdc++.h>
#include "TFile.h"
#include "TTree.h"
#include "TBranch.h"

void make_tree(const char *input = "cuts.csv", const char *output = "run_cuts.root") {
    ifstream fin(input, std::ifstream::in);
    if (! fin.is_open()) {
      cerr << "Error: can't open input file, please check it:\t" << input << endl;
      exit(1);
    }
    ofstream ftxt_out("run_cuts.txt", std::ofstream::out);
    if (! ftxt_out.is_open()) {
	cerr << "Error: can't open output file: run_cuts.txt, please check it!";
	exit(1);
    }
    ifstream fin_good_runs("good_runs.list", std::ifstream::in);
    if (! fin_good_runs.is_open()) {
      cerr << "Error: can't open good_runs file: good_runs.list please check it:\t" << endl;
      exit(1);
    }
    TFile fout(output, "recreate");
    if (!fout.IsOpen()){
      cerr << "Error: can't create output root file, please check it:\t" << output << endl;
      exit(1);
    }

    int run, slug, start_run, end_run;
    char mapfile[42];
    char normalized_bcm[12];
    double normalized_lower_limit, normalized_upper_limit, normalized_stability, normalized_burplevel;
    // std::string mapfile;
    // these variables should keep the same order as that in the extract_cut.awk script
    const char * bcms[] = {"bcm_an_us", "bcm_an_ds", "bcm_an_ds3", "bcm_dg_us", "bcm_dg_ds"};
    const char * bcm_cuts[] = {"flag", "lower_limit", "upper_limit", "local_global", "stability", "burplevel"};
    const char * bpms[] = {"bpm4a", "bpm4e", "bpm11", "bpm12"};
    const char * bpm_channels[] = {"xm", "xp", "ym", "yp", "absx", "absy", "effectivecharge"};
    const char * bpm_cuts[] = {"flag", "lower_limit", "upper_limit", "local_global", "stability", "burplevel"};
    const int nbcm = sizeof(bcms)/sizeof(*bcms);
    const int nbcm_cut = sizeof(bcm_cuts)/sizeof(*bcm_cuts);
    const int nbpm = sizeof(bpms)/sizeof(*bpms);
    const int nbpm_channel = sizeof(bpm_channels)/sizeof(*bpm_channels);
    const int nbpm_cut = sizeof(bpm_cuts)/sizeof(*bpm_cuts);
    double bcm_cut_values[nbcm][nbcm_cut];
    double bpm_cut_values[nbpm][nbpm_channel][nbpm_cut];

    char *bcm_cut_description = Form("%s/D", bcm_cuts[0]), *bpm_cut_description = Form("%s/D", bpm_cuts[0]);
    for(int i=1; i<nbcm_cut; i++) {
      bcm_cut_description = Form("%s:%s/D", bcm_cut_description, bcm_cuts[i]);
    }
    for(int i=1; i<nbpm_cut; i++) {
      bpm_cut_description = Form("%s:%s/D", bpm_cut_description, bpm_cuts[i]);
    }


    TTree *t = new TTree("run_cut", "run cuts");
    t->Branch("run", &run, "run/I");
    t->Branch("slug", &slug, "slug/I");
    t->Branch("mapfile", mapfile, "mapfile/C");
    t->Branch("normalized_bcm", normalized_bcm, "normalized_bcm/C");
    t->Branch("normalized_lower_limit", &normalized_lower_limit, "normalized_lower_limit/D");
    t->Branch("normalized_upper_limit", &normalized_upper_limit, "normalized_upper_limit/D");
    t->Branch("normalized_stability", &normalized_stability, "normalized_stability/D");
    t->Branch("normalized_burplevel", &normalized_burplevel, "normalized_burplevel/D");
    for(int i=0; i<nbcm; i++) {
      t->Branch(bcms[i], bcm_cut_values[i], bcm_cut_description);
    }
    for(int i=0; i<nbpm; i++) {
      for (int j=0; j<nbpm_channel; j++) {
        t->Branch(Form("%s_%s", bpms[i], bpm_channels[j]), bpm_cut_values[i][j], bpm_cut_description);
      }
    }

    std::string mapfile_name, normalized_bcm_name;
    fin_good_runs >> run >> slug;
    while (fin >> start_run >> end_run >> mapfile_name) {   // !!! the read in order is very important
      // bcm
      for(int i=0; i<nbcm; i++) {
        for (int j=0; j<nbcm_cut; j++) {
          fin >> bcm_cut_values[i][j];
        }
      }
      // normalized bcm
      fin >> normalized_bcm_name >> normalized_lower_limit >> normalized_upper_limit >> normalized_stability >> normalized_burplevel;
      // bpm
      for(int i=0; i<nbpm; i++) {
        for (int j=0; j<nbpm_channel; j++) {
          for (int k=0; k<nbpm_cut; k++) {
            fin >> bpm_cut_values[i][j][k];
          }
        }
      }
      std::strcpy(mapfile, mapfile_name.c_str());
      std::strcpy(normalized_bcm, normalized_bcm_name.c_str());

      while(run <= end_run) {
        t->Fill();
	ftxt_out << run << "\t" << slug << "\t" << mapfile << "\t";
	for(int i=0; i<nbcm; i++) {
	  for (int j=0; j<nbcm_cut; j++) {
	    ftxt_out << bcm_cut_values[i][j] << "\t";
	  }
	}
	ftxt_out <<  normalized_bcm_name << "\t" <<  normalized_lower_limit << "\t" 
	    <<  normalized_upper_limit << "\t" <<  normalized_stability << "\t" <<  normalized_burplevel << "\t";
        for(int i=0; i<nbpm; i++) {
          for (int j=0; j<nbpm_channel; j++) {
            for (int k=0; k<nbpm_cut; k++) {
              ftxt_out << bpm_cut_values[i][j][k] << "\t";
            }
          }
        }
	ftxt_out << endl;
        if (fin_good_runs >> run >> slug)
          ;
        else 
          break;
      }
    }

    cout << t->GetEntries() << " entries have been recorded" << endl;
    
    fin.close();
    fin_good_runs.close();
    fout.cd();
    t->Write();
    fout.Close();
}
