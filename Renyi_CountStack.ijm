macro "Renyi Count Stack [c]" {
	time = getTime();
	cwd = getDirectory("current");
for (i=1; i<nSlices+1;i++) {
	// Copy slice to be processed
	Stack.setSlice(i); 	
	runMacro("ImageJ_Macros/Renyi_Count.ijm")
		//Close uneeded images
		close();
		close();
	//Close Results	
		selectWindow("Results"); 
        run("Close" );
   
	}
//Rename Summary to Results    
        IJ.renameResults("Summary", "Results");
        print("Counting Normal took " + (getTime() - time) + " msec");

}
