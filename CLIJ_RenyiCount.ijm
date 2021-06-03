//Initialize OpenCL device
run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();

//For benchmarking
time = getTime();


//Check if stack
	title=getInfo("slice.label");
	SliceLabel = split(title, "\n");
	if (title=="") {	//if no slice.label means not a stack
		//Get ID of the image
		orig_id =  getImageID();
	}
	else {	//if a slice in a stack
		//Make a duplicate with the slice id as title
		run("Duplicate...", "title=["+SliceLabel[0]+"]");
		//Get IDs of this duplicate as the original intial image for image calculator
		orig_id =  getImageID();
		dup_id = orig_id;
	}

selectImage(orig_id);
orig = getTitle();
//Get pixel/micron
getPixelSize(unit, pw, ph); //returns the width of a pixel in 'unit' (here microns)
scale = 1/pw; //convert to pixel/micron

//push (store) img meta data to GPU, so we can then restore it later
Ext.CLIJx_pushMetaData();	
//Push image to GPU, uses image title
Ext.CLIJ2_push(orig);

//Set Guassian blur sigma values
//CLIJ uses pixel values! 
//Calculate sigma in pixels as equivalent to 12 micron
sigma1x = 0;
sigma1y = 0;
sigma2x = 12*scale;
sigma2y = 12*scale;

//Perform a Gaussian blur
Ext.CLIJ2_gaussianBlur2D(orig, blurred, sigma2x, sigma2y);
//Background subtraction by subtracting the blurred image from original
Ext.CLIJ2_subtractImages(orig, blurred, DoG);
Ext.CLIJ2_release(blurred);
Ext.CLIJ2_release(orig);

//If using a frame duplicate, close it
selectImage(dup_id);
close();
//Ext.CLIJ2_pull(DoG);

//Other background subtraction options
//Ext.CLIJ2_differenceOfGaussian2D(orig, DoG, sigma1x, sigma1y, sigma2x, sigma2y);
//Ext.CLIJ2_topHatBox(orig, DoG, sigma2x, sigma2y, 0);

//Threshold the image using Renyi algo
Ext.CLIJ2_thresholdRenyiEntropy(DoG, mask);
Ext.CLIJ2_release(DoG);
//Ext.CLIJ2_pull(mask);

//Binary Open (erode then dilate)
Ext.CLIJ2_erodeBox(mask, eroded);
Ext.CLIJ2_dilateBox(eroded, opened);
Ext.CLIJ2_release(mask);
Ext.CLIJ2_release(eroded);

//Use the watershed operation
Ext.CLIJx_imageJWatershed(opened, WS);
//Ext.CLIJ2_pull(WS);
Ext.CLIJ2_release(opened);

//Label objects
Ext.CLIJ2_connectedComponentsLabelingBox(WS, labels);
Ext.CLIJ2_release(WS);

//Count the number of objects labeled
Ext.CLIJ2_getMaximumOfAllPixels(labels, count);
//Ext.CLIJ2_statisticsOfLabelledPixels(labels, labels);

// Block to get the segmented, labeled image back with proper name and meta data
Ext.CLIJ2_pull(labels);
//Restore meta data
Ext.CLIJx_popMetaData();
run("glasbey");
//rename
rename(orig + " Seg");
//
//Prepare a Results table with slice/image title and count
i=nResults();
setResult("Frame", i, orig);
setResult("Count", i, count);
// Benchmarking and CLIJ Info block
print("Counting CLIJ took " + (getTime() - time) + " msec");
Ext.CLIJ2_getGPUProperties(gpu, memory, opencl_version);
print("GPU: " + gpu);
print("Memory in GB: " + (memory / 1024 / 1024 / 1024) );
print("OpenCL version: " + opencl_version);
//