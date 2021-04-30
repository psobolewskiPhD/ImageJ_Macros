macro "Renyi Count Stack [c]" {
	cwd = getDirectory("current");
for (i=1; i<nSlices+1;i++) {
	// Copy slice to be processed
	Stack.setSlice(i); 	
	runMacro(cwd + "RenyiCount.ijm")
		//Close uneeded images
		close();
		close();
	//Close Results	
		selectWindow("Results"); 
        run("Close" );
   
	}
//Rename Summary to Results    
        IJ.renameResults("Summary", "Results");

}