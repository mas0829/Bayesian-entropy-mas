SEKS-GUI Changelog:

23 May 2019: Version 1.0.9 out
* Bug fix: Modified SEKS-GUI
  - guiLibs/BMELIB2.0/genlib/trapezint.m, l.29
  to account correctly for operator ‘&’ instead of ‘&&’. The latter can be used
  only in comparisons that assign a logical scalar values (rather than compare):
  In previous Matlab versions, the operator '&&' was correclty used, but not any longer.


27 Nov 2015: Version 1.0.8 out
* BMElib bug fix: In S-T case, kernel smoothing accounted incorrectly for the
                  joint space-time distance.
  - genlib/kernelsmoothing.m, l.69-end
  Modified function to behave differently in S / S-T cases. Works as previousy
    in spatial case. In S-T case, the distance dh returned by neighbours.m has
    2 columns (space, time) so the distance in the kernel exponential is now
    computed by accounting for the correct spatiotemporal metric in space-time.
    Also, the exponential expression in the kernel was corrected by adding a
    minus (-) sign to precede the ratio of distance over the constant kv.
    Also propagated same fix in:
    guiResources/kernelsmoothingPar.m
    guiResources/kernelsmoothingexp.m
    guiResources/kernelsmoothingexggui.m
* BMElib feature: Conditional simulation available: guiResources/simucholcondMEgui.
  Created GUI version of guiLibs/BMELIB2.0b/simulib/simucholcondME that improves
  existing version: It can accept simulation output grids that might contain
  locations of data points.
* BMElib feature: Extended functionality of guiLibs/BMELIB2.0b/statlib/uniformstat.
  Created GUI version called uniformstatgui that can accept a vector of interval SD
  instead of only one at a time.


1 Sep 2015: Version 1.0.7 out
* Bug fix: In MATLAB R2014B, colorplots have MarkerEdgeColor with multiple colors.
           As a result, this makes interpretation of colorplots confusing.
  - graphlib/colorplot.m, l.113:
  Set(a,'MarkerEdgeColor','black') to account for new Matlab R2014b default.
* Bug fix: S-T data plots are presented with their values mirrored on the axes.
  - ip304p2TexplorAnal.m, l.213:
  Function valstv2stg returns arguments in an inverted index order. Index order
    of output matrices elements was corrected with flipud().
* Bug fix: Warning about using INTERP1(...,'CUBIC') becoming obsolete in future.
  - nscoreBack.m, l.66
  - nscoreBackVec.m, l.69, 95:
  Replaced with INTERP1(...,'PCHIP') as recommended.
* Bug fix: When I ask the model info to be saved in a text file, if the sill is
           very low (eg 1e-6) then it is incorrectly recorded as 0.
  - ip305p2TcovarAnal.m, l.527-557:
  Changed the sill file printing format from %12.4f to %24.16f to allow for 16
  decimal digits. Reading from the file is not affected.
* BMElib feature: Conditional simulation available with simucholcondgui.
  Created GUI version of guiLibs/BMELIB2.0b/simulib/simucholcond that improves
  existing version: It can accept simulation output grids that might contain
  locations of data points.
* Bug fix: Modified SEKS-GUI
  - guiLibs/BMELIB2.0/bmeprobalib/BMEprobaPdf.m, l.439
  - guiLibs/BMELIB2.0/bmeprobalib/proba2val.m  , l. 49, 58, 71, 75
  to account correctly for operator ‘&’ instead of ‘&&’. The latter can be used
  only in comparisons that assign a logical scalar values (rather than compare):
  In previous Matlab versions, the operator '&&' was correclty used, but not any longer.
* Bug fix: Modified SEKS-GUI
  - ip304p2TexplorAnal, l.197
  In the preliminary code, temp versions of hard and soft data were made. Using
  valstv2stg for hard data can lead to reordering of rows in records, and the
  new ordering would be reflected in the ‘*AtInst’ series of variables. However,
  zhTempAtInst was being later directly created based on the original input hard
  data table, and this led to miscorreposndence of hard data locations to values
  from that point on. Fixed the issue so that all hard data row ordering is based
  on the order produced after the call to valstv2stg.
* Bug fix: Modified SEKS-GUI
  - ip307v1Tvisuals, l.2423
  When printing output for data woth no mean trend, the variable ‘trendTInsts’ is
  empty. Yet, the conditionals in this block would not account for empty ‘trendTInsts’
  and this would cause an error.


3 Apr 2015: Version 1.0.6 out
* Bug fix: (MATLAB R2014B) In part II of covariance analysis: Invisible parameter boxes.
  - ip305p2TcovarAnal.fig
  Sent 'Covariance Parameter' frame to background.
* Bug fix: Warning about using INTERP1(...,'CUBIC') becoming obsolete in future.
  - ip304p3TexplorAnal.m
  Replaced with INTERP1(...,'PCHIP') as recommended.
* New feature
  - guiResources/kernelsmoothingPar.m
  kernelsmoothing function that supports parfor with an additional “nWorkers” argument.


11 Nov 2014: Version 1.0.5 out
* New feature
  - guiResources/finddupliwtol.m
  Added function that finds duplicates (collocated data) in a data set that
    skips using 'unique' fuction which might provide inaccurate results
    adds a S-T input argument flag to better account for collocation in S-T
    adds a tol input argument to pass an explicit spatial distance tolerance
       value below which an observation pair is deemed to be collocated.
* Bug fix: Modified SEKS-GUI
  - guiResources/findneardupli.m
  to account correctly for operator ‘&’ instead of ‘&&’. The latter can be used
  only in comparisons that assign a logical scalar values (rather than compare):
  In previous Matlab versions, the operator '&&' was correclty used, but not any longer.


29 Aug 2014: Version 1.0.4 out
* Bug fix: Modified SEKS-GUI
  - data input 'ip*' files
  - guiResources/crosscovarioSTgui.m
    guiResources/findneardupli.m
    guiResources/findOutliers.m
    guiResources/inpoly.m
    guiResources/nscoreTrsf.m
    guiResources/stcovgui.m
  to account correctly for operator
  “|” in following comparisons that assign a logical value (rather than only compare):
     (norm<0.95 | norm>1.05)
     (normSorted<0.95 | normSorted>1.05)
  In previous Matlab versions, the operator '||' was correclty used, but not any longer.


24 May 2014: Version 1.0.3 out
* Bug fix: Modified all SEKS-GUI 'ip*' files and those under 'guiResources' folder
  to account correctly for operators && and ||. In previous Matlab versions, it was
  ok to use interchangeably & and | as the the above operators, but not any longer.
* Bug fix: In 'ip304p2TexplorAnal.m' and 'ip304p2explorAnal.m', the variable
  limiTempDetrendedAtInst{it} is explicitly set to empty, if needed: If no soft data
  exist at it-instance, then computations involving the kron() function lead to error.
* Bug fix: In 'ip304p2TexplorAnal.m' it could happen that soft data matrices would be
  empty by being both [] and 0x1 matrices. However, comparing these types of matrices
  by size (,2) yields non-equality and consequent errors. Now this comparison is
  preceded by emptiness check for matrices to compare.
* Changed version name in 'ip000about.fig' and 'ip001splashScreen.fig' accordingly.


 7 May 2014: Version 1.0.2 out
* Bug fix: Modified files 'ip302p3[A-E]softDataWiz.m': If a user would specify a
  text file as input soft data file, then an error would occur. These files previously
  accounted for the number of observations by using a parameter that was defined only
  when using an Excel file as input soft data file.
* BMElib2.0b: Series of fixes across BMElib2.0b files to account correctly for
  operators && and ||. In previous Matlab versions, it was ok to use interchangeably
  & and | as the the above operators, but not any longer.
* BMElib2.0b: Changed stcov.m in statlib to follow exactly the stcovgui.m under
  guiResources.
* Changed version name in 'ip000about.fig' and 'ip001splashScreen.fig' accordingly.


11 Mar 2013: Version 1.0.1 out
* Bug fix: Modified 'ip305p2TcovarAnal.m' because the parameter covModST was producing
  errors when adding arbitrary models. Reduced its use as global variable.
* Bug fix: Also in 'ip305p2TcovarAnal.m', if no transformation specified, then covariance
  sill could become >1. Fitting a model with a sill >1 was previously unacceptable and
  produced on-screen error. Commented out this check in code and de-activated on-screen
  error.
* Changed version name in 'ip000about.fig' and 'ip001splashScreen.fig' accordingly.


23 Jan 2013: Version 1.0.0 out
