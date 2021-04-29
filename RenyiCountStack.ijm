/* This is a macro to count nucelei stained with fluorescent dye (e.g. DAPI, Hoechst)
The macro will iterate over all slices in a stack.
Authors: Peter Sobolewski, Nina Kantor-Malujdy, West Pomeranian University of Technology, Szcecin
Copyright: 2021
License: BSD3
*/

//Wrap in a keyboard shortcut
macro "Renyi Count Stack [c]" {
for (i=1; i<nSlices+1;i++) {
	// Copy slice to be processed
	Stack.setSlice(i); 	
	//Get the name of the slice to be processed
	title=getInfo("slice.label");
	//Make a duplicate with the slice id as title
	run("Duplicate...", "title=["+title+"]");

	//Get IDs of the intial image for image calculator
		orig =  getImageID();
	//Make an (extra) duplicate 	
		run("Duplicate...", " ");  
		dup = getImageID();
		
	//Implement background subtraction via subtraction of Guassian blur
	//Gaussian blur radius (sigma) set to 12 micron (scaled option) 	
	//Avg. radius is approx. 7 micron, maximum <10 micron	
		run("Gaussian Blur...", "sigma=12 scaled");
		blurred = getImageID();
		imageCalculator("Subtract create", orig,blurred);
		delta =  getImageID();
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
		run("Set Measurements...", "area redirect=None decimal=1");

	//Count particles 40-400 micron sq. in area and generate summary
		run("Analyze Particles...", "size=40-400 circularity=0.60-1.00 show=Overlay display clear summarize");
	//Close uneeded images
		selectImage(orig);
		close();
		selectImage(delta);
		close();
	//Close Results	
		selectWindow("Results"); 
        run("Close" );
   
	}
//Rename Summary to Results    
        IJ.renameResults("Summary", "Results");

}
