/* This is a macro to count nucelei stained with fluorescent dye (e.g. DAPI, Hoechst)
Authors: Peter Sobolewski, Nina Kantor-Malujdy, West Pomeranian University of Technology, Szcecin
Copyright: 2021
License: BSD3
*/
//Wrap ina keyboard shortcut
macro "Renyi Count [c]" {
//Work on Duplicate (preserve original)
//Implement background subtraction via subtraction of Guassian blur
	orig =  getImageID();
	run("Duplicate...", " ");  
	dup = getImageID();
//Gaussian blur radius (sigma) set to 15 micron 	
	run("Gaussian Blur...", "sigma=15 scaled");
	blurred = getImageID();
	imageCalculator("Subtract create", orig,blurred);
	selectImage(blurred);
	close();
//In case of inverted LUT
	if (is("Inverting LUT")) {
		run("Invert LUT");
	}
//Threshold the image using Renyi algo
	setAutoThreshold("Default dark");
	//run("Threshold...");
	setAutoThreshold("RenyiEntropy dark");
	call("ij.plugin.frame.ThresholdAdjuster.setMode", "Over/Under");
	run("Convert to Mask");
//Watershed to separate adjacent	
	run("Watershed");
//Set measurements to just Area
	run("Set Measurements...", "area redirect=None decimal=1");
//Count particles 30-600 micron sq. in area and generate summary
	run("Analyze Particles...", "size=30-600 circularity=0.30-1.00 show=Overlay display exclude clear summarize");
}
