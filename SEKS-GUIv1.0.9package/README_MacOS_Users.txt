A. Important note for users of Mac OS 10.9.x or greater
=======================================================

SEKS-GUI needs the GCC compiler to run correctly. Traditionally, Apple has been
including (or making it trivial to install) the GCC C, C++, and Fortran compilers
as part of their XCode application.

As of Mac OS 10.9 (Mavericks), this convenience is no longer present at the time
of writing this note. If you install SEKS-GUI and you are a Mac OS 10.9 or greater
user, then please make sure to also download and install the GCC compiler package
for Mac OS 10.9 as follows:

1. Get the file "gcc-4.9-bin.tar.gz" from Sourceforge:
   http://prdownloads.sourceforge.net/hpc/gcc-4.9-bin.tar.gz?download
   This file has the binaries of the necessary compilers.

2. Open the Terminal application on your Mac. Navigate to the / folder. As an
   administrator, save the download there.
   % cd /
   % sudo mv <Path_To_Your_Downloads_Folder>/gcc-4.9-bin.tar.gz .

3. While in the / folder, decompress the file you just moved. Its contents will be
   properly placed at the correct locations under the directory /usr.
   % sudo tar -zxvf gcc-4.9-bin.tar.gz

4. Check that you can access, for example, the Fortran compiler by issuing the command:
   % which gfortran
   You should see a response like "/usr/local/bin/gfortran".

5. In /Applications/MATLAB_R2013a.app/sys/os/maci64 rename the Fortran library:
   % mv libgfortran.3.dylib libgfortran.3.dylib.old
   and create the following symbolic link 
   % ln -s /usr/local/lib/libgfortran.3.dylib libgfortran.3.dylib


B. Important note for users of Mac OS 10.10.x (only for users of Matlab v <= R2014a)
====================================================================================

Summary: Java Exception and abrupt exit on Mac OS X version 10.10 Yosemite
(Matlab bug 1098655; bug was fixed as of R2014b).

For MATLAB R2012a through R2014a only, a patch is needed to fix this behavior.
This is a Matlab issue that has nothing to do with SEKS-GUI. Yet, to use SEKS-GUI
on Mac OS 10.10.x, you will need to install a Matlab patch to run Matlab versions
up to (including) R2014a.

To install this patch, you need to find it on the Mathworks website; then, 
you will need the name and password of an account with Administrator privileges.
1. Download the appropriate patch file for the version of MATLAB you wish to patch.
2. Look for the file in your Downloads folder, the Desktop, or wherever your Web browser saves downloaded files.
3. If your Web browser did not unzip the patch file for you, double-click the file in the Finder to unzip it.
4. Double-click the .dmg file to mount the disk image.
5. At the top level of the mounted disk image is an application such as R2014a_patch_1098655.app. Double-click to launch it.
6. Select your MATLAB installation. Select the root folder of the install, for example, MATLAB_R2014a.app.
7. Enter the name and password of an account with Administrator privileges.
8. New Java class files will be installed in the java/patch/com/mathworks/widgets folder of your MATLAB installation.
9. When the upgrade is complete, you can launch MATLAB.


March 2014,
The SEKSGUI support team.

   