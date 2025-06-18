# Meteorological Computer Applications project
Project done for my sophomore Meteorological Computer Apps (METR 4105) class at UNC Charlotte. It uses Fortran for analyzing data and Python for creating graphics inserted into my presentation.

The Fortran code ```Final Project.f90``` reads in five soundings and five CF6 files relevant to landfalling or impactful tropical cyclones to the Charleston, SC area. Python graphics were created using MetPy's declarative plotting syntax. Files have not been edited at this time. The presentation supplementing the analysis has been included.

Sources:
* Sounding data: https://weather.uwyo.edu/upperair/sounding_legacy.html
* CF6 data: https://mesonet.agron.iastate.edu/nws/cf6table.php?opt=bystation&station=KCHS&year=2025

Notes:
* I used gfortran on my MacBook to compile. It is a tossup if sind and cosd works on your system; my professor said the function did not compile on her's. I will eventually re-do the offending sections using standard functions (namely: sin and cos).
* Plots were done using declarative syntax, this was a constraint of the class. I have since learned more about using the standard pyplot syntax, though the python code here will remain unedited for posterity.
