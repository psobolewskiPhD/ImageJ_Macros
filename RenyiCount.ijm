/* This is a macro to count nucelei stained with fluorescent dye (e.g. DAPI, Hoechst)
Authors: Peter Sobolewski, Nina Kantor-Malujdy, West Pomeranian University of Technology, Szcecin
Copyright: 2021
License: BSD3
*/

//Wrap in a keyboard shortcut
macro "Renyi Count [c]" {
//Work on Duplicate (preserve original)
//Get IDs of images for image calculator
	//Check if stack
	title=getInfo("slice.label");
	SliceLabel = split(title, "\n");
	if (title=="") {	//if no slice.label means not a stack
		//Get ID of the intial image for image calculator
		orig =  getImageID();
		run("Duplicate...", " "); //use image name
		//Get ID of the duplicate image for image calculator
		dup = getImageID();	
	}
	else {	//if a slice in a stack
		//Make a duplicate with the slice id as title
		run("Duplicate...", "title=["+SliceLabel[0]+"]");
		//Get IDs of this duplicate as the original intial image for image calculator
		orig =  getImageID();
		//Make an (extra) duplicate for the Gaussian blur	
		run("Duplicate...", " ");  
		//Get ID of the duplicate image for image calculator
		dup = getImageID();		
	}
		
//Implement background subtraction via subtraction of Guassian blur
//Gaussian blur radius (sigma) set to 12 micron (scaled option)
//The typical radius of nuclei is 7 um, maximum radius of nuclei is <10 micron
	run("Gaussian Blur...", "sigma=12 scaled");
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
	setAutoThreshold("RenyiEntropy dark");
	call("ij.plugin.frame.ThresholdAdjuster.setMode", "Over/Under");
	run("Convert to Mask");

//Binary Open (erode then redilate)	
	run("Open");	
	
//Watershed to separate adjacent	
	run("Watershed");
	
//Set measurements to just Area
	run("Set Measurements...", "area feret's redirect=None decimal=1");

//Count particles 40-400 micron sq. in area and generate summary
	run("Analyze Particles...", "size=40-400 circularity=0.60-1.00 show=Overlay display clear summarize");
}
