// Author: Sébastien Tosi (IRB Barcelona)
// Version: 1.0
// Date: 21/04/2017

// The default input and output folder
inputDir = "/dockershare/667/in/";
outputDir = "/dockershare/667/out/";

// Functional parameters
ij_rad = 2;
ij_thr = -1.5;
ij_noisetol = 2.5;

arg = getArgument();
parts = split(arg, ",");

setBatchMode(true);
for(i=0; i<parts.length; i++) {
	nameAndValue = split(parts[i], "=");
	if (indexOf(nameAndValue[0], "input")>-1) inputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "output")>-1) outputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "ij_rad")>-1) ij_rad=nameAndValue[1];
	if (indexOf(nameAndValue[0], "ij_thr")>-1) ij_thr=nameAndValue[1];
	if (indexOf(nameAndValue[0], "ij_noisetol")>-1) ij_noisetol=nameAndValue[1];
}

images = getFileList(inputDir);

for(i=0; i<images.length; i++) {
	image = images[i];
	if (endsWith(image, ".tif")) {
		// Open image
		open(inputDir + "/" + image);
		width = getWidth();
		height = getHeight();
		
		// Processing
		run("Clear Results", "");
		run("FeatureJ Laplacian", "compute smoothing="+d2s(ij_rad,2));
		getMinAndMax(min,max);
		setThreshold(min,ij_thr);
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Distance Map");
		run("Find Maxima...", "noise="+d2s(ij_noisetol,2)+" output=List light");
		
		// Export results
		newImage("Mask", "16-bit black", width, height, 1);
		for(r=0;r<nResults;r++)
		{
			XPos = getResult("X",r);
			YPos = getResult("Y",r);
			setPixel(XPos,YPos,65535);			
		}
		save(outputDir + "/" + image);
		// Cleanup
		run("Close All");
	}
}
run("Quit");
