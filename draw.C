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
	"bcm_an_us.lower_limit:run",
	"bcm_an_us.upper_limit:run",
	"bcm_an_us.local_global:run",
	"bcm_an_us.stability:run",
	"bcm_an_us.burplevel:run",
	"bcm_an_ds.lower_limit:run",
	"bcm_an_ds.upper_limit:run",
	"bcm_an_ds.local_global:run",
	"bcm_an_ds.stability:run",
	"bcm_an_ds.burplevel:run",
	"bcm_an_ds3.lower_limit:run",
	"bcm_an_ds3.upper_limit:run",
	"bcm_an_ds3.local_global:run",
	"bcm_an_ds3.stability:run",
	"bcm_an_ds3.burplevel:run",
	"bcm_dg_us.lower_limit:run",
	"bcm_dg_us.upper_limit:run",
	"bcm_dg_us.local_global:run",
	"bcm_dg_us.stability:run",
	"bcm_dg_us.burplevel:run",
	"bcm_dg_ds.lower_limit:run",
	"bcm_dg_ds.upper_limit:run",
	"bcm_dg_ds.local_global:run",
	"bcm_dg_ds.stability:run",
	"bcm_dg_ds.burplevel:run",

	"bpm4a_xm.lower_limit:run",
	"bpm4a_xm.upper_limit:run",
	"bpm4a_xm.local_global:run",
	"bpm4a_xm.stability:run",
	"bpm4a_xm.burplevel:run",
	"bpm4a_xp.lower_limit:run",
	"bpm4a_xp.upper_limit:run",
	"bpm4a_xp.local_global:run",
	"bpm4a_xp.stability:run",
	"bpm4a_xp.burplevel:run",
	"bpm4a_ym.lower_limit:run",
	"bpm4a_ym.upper_limit:run",
	"bpm4a_ym.local_global:run",
	"bpm4a_ym.stability:run",
	"bpm4a_ym.burplevel:run",
	"bpm4a_yp.lower_limit:run",
	"bpm4a_yp.upper_limit:run",
	"bpm4a_yp.local_global:run",
	"bpm4a_yp.stability:run",
	"bpm4a_yp.burplevel:run",
	"bpm4a_absx.lower_limit:run",
	"bpm4a_absx.upper_limit:run",
	"bpm4a_absx.local_global:run",
	"bpm4a_absx.stability:run",
	"bpm4a_absx.burplevel:run",
	"bpm4a_absy.lower_limit:run",
	"bpm4a_absy.upper_limit:run",
	"bpm4a_absy.local_global:run",
	"bpm4a_absy.stability:run",
	"bpm4a_absy.burplevel:run",
	"bpm4a_effectivecharge.lower_limit:run",
	"bpm4a_effectivecharge.upper_limit:run",
	"bpm4a_effectivecharge.local_global:run",
	"bpm4a_effectivecharge.stability:run",
	"bpm4a_effectivecharge.burplevel:run",

	"bpm4e_xm.lower_limit:run",
	"bpm4e_xm.upper_limit:run",
	"bpm4e_xm.local_global:run",
	"bpm4e_xm.stability:run",
	"bpm4e_xm.burplevel:run",
	"bpm4e_xp.lower_limit:run",
	"bpm4e_xp.upper_limit:run",
	"bpm4e_xp.local_global:run",
	"bpm4e_xp.stability:run",
	"bpm4e_xp.burplevel:run",
	"bpm4e_ym.lower_limit:run",
	"bpm4e_ym.upper_limit:run",
	"bpm4e_ym.local_global:run",
	"bpm4e_ym.stability:run",
	"bpm4e_ym.burplevel:run",
	"bpm4e_yp.lower_limit:run",
	"bpm4e_yp.upper_limit:run",
	"bpm4e_yp.local_global:run",
	"bpm4e_yp.stability:run",
	"bpm4e_yp.burplevel:run",
	"bpm4e_absx.lower_limit:run",
	"bpm4e_absx.upper_limit:run",
	"bpm4e_absx.local_global:run",
	"bpm4e_absx.stability:run",
	"bpm4e_absx.burplevel:run",
	"bpm4e_absy.lower_limit:run",
	"bpm4e_absy.upper_limit:run",
	"bpm4e_absy.local_global:run",
	"bpm4e_absy.stability:run",
	"bpm4e_absy.burplevel:run",
	"bpm4e_effectivecharge.lower_limit:run",
	"bpm4e_effectivecharge.upper_limit:run",
	"bpm4e_effectivecharge.local_global:run",
	"bpm4e_effectivecharge.stability:run",
	"bpm4e_effectivecharge.burplevel:run",

	"bpm11_xm.lower_limit:run",
	"bpm11_xm.upper_limit:run",
	"bpm11_xm.local_global:run",
	"bpm11_xm.stability:run",
	"bpm11_xm.burplevel:run",
	"bpm11_xp.lower_limit:run",
	"bpm11_xp.upper_limit:run",
	"bpm11_xp.local_global:run",
	"bpm11_xp.stability:run",
	"bpm11_xp.burplevel:run",
	"bpm11_ym.lower_limit:run",
	"bpm11_ym.upper_limit:run",
	"bpm11_ym.local_global:run",
	"bpm11_ym.stability:run",
	"bpm11_ym.burplevel:run",
	"bpm11_yp.lower_limit:run",
	"bpm11_yp.upper_limit:run",
	"bpm11_yp.local_global:run",
	"bpm11_yp.stability:run",
	"bpm11_yp.burplevel:run",
	"bpm11_absx.lower_limit:run",
	"bpm11_absx.upper_limit:run",
	"bpm11_absx.local_global:run",
	"bpm11_absx.stability:run",
	"bpm11_absx.burplevel:run",
	"bpm11_absy.lower_limit:run",
	"bpm11_absy.upper_limit:run",
	"bpm11_absy.local_global:run",
	"bpm11_absy.stability:run",
	"bpm11_absy.burplevel:run",
	"bpm11_effectivecharge.lower_limit:run",
	"bpm11_effectivecharge.upper_limit:run",
	"bpm11_effectivecharge.local_global:run",
	"bpm11_effectivecharge.stability:run",
	"bpm11_effectivecharge.burplevel:run",

	"bpm12_xm.lower_limit:run",
	"bpm12_xm.upper_limit:run",
	"bpm12_xm.local_global:run",
	"bpm12_xm.stability:run",
	"bpm12_xm.burplevel:run",
	"bpm12_xp.lower_limit:run",
	"bpm12_xp.upper_limit:run",
	"bpm12_xp.local_global:run",
	"bpm12_xp.stability:run",
	"bpm12_xp.burplevel:run",
	"bpm12_ym.lower_limit:run",
	"bpm12_ym.upper_limit:run",
	"bpm12_ym.local_global:run",
	"bpm12_ym.stability:run",
	"bpm12_ym.burplevel:run",
	"bpm12_yp.lower_limit:run",
	"bpm12_yp.upper_limit:run",
	"bpm12_yp.local_global:run",
	"bpm12_yp.stability:run",
	"bpm12_yp.burplevel:run",
	"bpm12_absx.lower_limit:run",
	"bpm12_absx.upper_limit:run",
	"bpm12_absx.local_global:run",
	"bpm12_absx.stability:run",
	"bpm12_absx.burplevel:run",
	"bpm12_absy.lower_limit:run",
	"bpm12_absy.upper_limit:run",
	"bpm12_absy.local_global:run",
	"bpm12_absy.stability:run",
	"bpm12_absy.burplevel:run",
	"bpm12_effectivecharge.lower_limit:run",
	"bpm12_effectivecharge.upper_limit:run",
	"bpm12_effectivecharge.local_global:run",
	"bpm12_effectivecharge.stability:run",
	"bpm12_effectivecharge.burplevel:run",
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
