# ImageJ_Macros
A (nascent) collection of ImageJ macros

*Renyi_Count*  
This is a macro to count nucelei stained with fluorescent dye (e.g. DAPI, Hoechst)
It subtracts background by subtracting a Gaussian blurred version of the image, thresholds using RenyiEntropy Algorithm, performs Binary Open and Watershed, and then counts particles 40-400 um2.

*Renyi_CountStack*  
This is a macro executes the RenyiCount macro, but iterates over a stack.

The two marcros with *CLIJ* prefixes are GPU accelerated using CLIJ
