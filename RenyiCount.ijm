/* This is a macro to count nucelei stained with fluorescent dye (e.g. DAPI, Hoechst)
Authors: Peter Sobolewski, Nina Kantor-Malujdy, West Pomeranian University of Technology, Szcecin
Copyright: 2021
License: BSD3
*/

//Wrap in a keyboard shortcut
macro "Renyi Count [c]" {
//Work on Duplicate (preserve original)
//Get IDs of images for image calculator
	orig =  getImageID();
	run("Duplicate...", " ");  
	dup = getImageID();
		
//Implement background subtraction via subtraction of Guassian blur
//Gaussian blur radius (sigma) set to 25 micron (scaled option) 	
	run("Gaussian Blur...", "sigma=25 scaled");
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
	run("Analyze Particles...", "size=30-600 circularity=0.60-1.00 show=Overlay display clear summarize");
}
