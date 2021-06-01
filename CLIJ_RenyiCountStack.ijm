run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();
time = getTime();

orig =  getTitle();

getDimensions(width, height, channels, slices, frames);

//store the scale (px/micron)
getPixelSize(unit, pw, ph); //returns the width of a pixel in 'unit' (here microns)
scale = 1/pw; //convert to pixel/micron

for (i=0; i < slices; i ++) {
	Stack.setSlice(i+1);
	title=getInfo("slice.label");
	SliceLabel = split(title, "\n");	
	Ext.CLIJ2_pushCurrentSlice(orig);
	
	//Set Guassian blur sigma values
	//Sigma in pixels as equivalent to 12 micron using 'scale'
	sigma1x = 0;
	sigma1y = 0;
	sigma2x = 12*scale;
	sigma2y = 12*scale;
	Ext.CLIJ2_gaussianBlur2D(orig, blurred, sigma2x, sigma2y);
	//Ext.CLIJ2_differenceOfGaussian2D(orig, DoG, sigma1x, sigma1y, sigma2x, sigma2y);
	//Ext.CLIJ2_topHatBox(orig, DoG, sigma2x, sigma2y, 0);
	Ext.CLIJ2_subtractImages(orig, blurred, DoG);
	Ext.CLIJ2_release(blurred);
	Ext.CLIJ2_release(orig);
	//Ext.CLIJ2_pull(DoG);
	Ext.CLIJ2_thresholdRenyiEntropy(DoG, mask);
	Ext.CLIJ2_release(DoG);
	//Binary Open (erode then dilate)
	Ext.CLIJ2_erodeBox(mask, eroded);
	Ext.CLIJ2_dilateBox(eroded, opened);
	Ext.CLIJ2_release(mask);
	Ext.CLIJ2_release(eroded);
	
	//Ext.CLIJ2_pull(mask);
	Ext.CLIJx_imageJWatershed(opened, WS);
	//Ext.CLIJx_parametricWatershed(mask, WS, sigma1x, sigma1y, 0);
	//Ext.CLIJ2_pull(WS);
	Ext.CLIJ2_release(opened);
	Ext.CLIJ2_connectedComponentsLabelingBox(WS, labels);
	Ext.CLIJ2_release(WS);
	Ext.CLIJ2_getMaximumOfAllPixels(labels, count);
	setResult("File", i, orig);
	setResult("Frame", i, title);
	setResult("Count", i, count);
}
//Ext.CLIJ2_pull(labels);
//run("glasbey");
print("Processed slices:" + slices);
print("Counting CLIJ took " + (getTime() - time) + " msec");
//Ext.CLIJ2_getGPUProperties(gpu, memory, opencl_version);
//print("GPU: " + gpu);
//print("Memory in GB: " + (memory / 1024 / 1024 / 1024) );
//print("OpenCL version: " + opencl_version);
