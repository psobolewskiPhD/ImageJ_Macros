# ImageJ_Macros
A (nascent) collection of ImageJ macros.
To install, place the folder into Fiji/macros and/or in Fiji/scripts (to get a custom menu)--or use symbolic links.


*Renyi_Count*  
This is a macro to count nucelei stained with fluorescent dye (e.g. DAPI, Hoechst)
It subtracts background by subtracting a Gaussian blurred version of the image, thresholds using RenyiEntropy Algorithm, performs Binary Open and Watershed, and then counts particles 40-400 um2.

*Renyi_CountStack*  
This is a macro executes the RenyiCount macro, but iterates over a stack.

The two marcros with *CLIJ* prefixes are GPU accelerated (OpenCL) using CLIJ. For a 60 frame (1920x1440) stack, CLIJ yields ~7X speedup. 
If you would like to use these macros, see the CLIJ website for installation instructions at:
https://clij.github.io/clij2-docs/installationInFiji
