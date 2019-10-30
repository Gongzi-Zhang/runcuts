void draw(const char * fin_name = "run_cuts.root") {
    TFile * fin = new TFile(fin_name, "read");
    if (!fin) {
	cout << "Error: Can not open root file: " << fin_name << endl;
	exit(1);
    }
    TTree * tin = (TTree*) fin->Get("run_cut");
    if (!tin) {
	cout << "Error: Can not receive tree: run_cut from root file: " <<  fin_name << endl;
	exit(1);
    }

    TCanvas * c = new TCanvas("c", "c", 800, 600);
    tin->SetMarkerStyle(10);
    // tin->SetMarkerSize(0.5);

    const char* vars[] = {
	"normalized_bcm",
	"normalized_lower_limit:run",
	"normalized_upper_limit:run",
	"normalized_stability:run",
	"normalized_burplevel:run",
	"bcm_dg_ds.flag:run",
	"bcm_dg_us.flag:run",
	"bcm_an_ds3.flag:run",
	"bcm_dg_ds.lower_limit:run",
	"bcm_an_ds3.lower_limit:run",
	"bpm4a_absx.stability:run",
	"bpm4a_absy.stability:run",
	"bpm4a_absx.burplevel:run",
	"bpm4a_absy.burplevel:run",
	"bpm4e_absx.stability:run",
	"bpm4e_absy.stability:run",
	"bpm4e_absx.burplevel:run",
	"bpm4e_absy.burplevel:run",
    };

    pair<const char*, const char*> correlated_vars[] = {
	make_pair("bcm_an_us.local_global", "bcm_an_us.flag"),
	make_pair("bcm_an_ds.local_global", "bcm_an_ds.flag"),
	make_pair("bcm_an_ds3.local_global", "bcm_an_ds3.flag"),
	make_pair("bcm_dg_us.local_global", "bcm_dg_us.flag"),
	make_pair("bcm_dg_ds.local_global", "bcm_dg_ds.flag"),
    };

    const int nvars = sizeof(vars)/sizeof(*vars);
    for (int i=0; i<nvars; i++) {
	tin->Draw(vars[i]);
	c->Print(Form("%s.png", vars[i]));
    }

    const int ncorrelated_vars = sizeof(correlated_vars)/sizeof(*correlated_vars);
    for (int i=0; i<ncorrelated_vars; i++) {
	const char *var1 = correlated_vars[i].first;
	const char *var2 = correlated_vars[i].second;
	// TH1F * h1, * h2;
	tin->Draw(Form("%s:run>>h1", var1));
	tin->Draw(Form("%s:run>>h2", var2));
	TH1F * h1 = (TH1F*) gDirectory->Get("h1");
	TH1F * h2 = (TH1F*) gDirectory->Get("h2");
	h1->SetMarkerStyle(26);
	h1->SetMarkerColor(8);
	h2->SetMarkerStyle(29);
	h2->SetMarkerColor(9);
	h1->Draw();
	h2->Draw("same");
	c->Print(Form("%s_vs_flag.png", var1));
    }
}
