function seksgui()
%
% seksgui               - The Graphic User Interface project for
%                         Spatiotemporal Epistemic Knowledge Synthesis (2006)
%
% SEKS-GUI is a front-end user interface for temporal GIS investigations,
% and space/time data assimilation, processing and visualizations. It is
% based on the use of BMElib, a software library that is based on the 
% provisions of the Knowledge Synthesis information processing framework.
%
% BMElib is the popular and acclaimed software library for spatial and
% spatiotemporal investigations. Its development and working version are 
% produced to run under the Matlab scientific software. Despite BMElib's 
% excellent documentation it is still required by the user to run the
% library within the command-line environment of Matlab. This task
% requires a basic level of programming knowledge on behalf of the user.
%
% The command "seksgui" launches a Graphic User Interface (GUI) that simply 
% guides the user through the necessary steps to perform a series of tasks
% using either of the above methods. The user is asked to proceed at each step
% by making decisions according to the study conducted. Users are then asked
% to provide the necessary information for the chosen processing method by
% means of files that contain properly formatted input. Please note that the
% SEKS-GUI will work only with Matlab versions 6.5 (Release 13) or more recent.
%
% The SEKS-GUI features some detailed documentation itself at each step of the
% process. The help displays on the individual screens that appear. This element
% makes a process almost self-explanatory, so that a user will not need to have
% any prior knowledge of the methods or programming or even Matlab to make use 
% of the BMElib and nu/mu software libraries. A rudimentary knowledge of how
% to launch Matlab and how to add the present GUI to Matlab's path scope is 
% required to execute "seksgui".
%
% The SEKS-GUI is also made easy to use. The GUI is very clear regarding the 
% input it requires from the user, and at each occasion there are examples
% guiding the user, as well as error catcing features. The input is requested
% in the commonly used forms of data in ASCII (text) or Excel files. A user
% that is asked to provide such an input file can tentatively create such a 
% file on the spot from arranging the available information with a text
% processor or an office-type application.
%
% The SEKS-GUI additionally provides access to the standard BMElib help 
% documentation. At each screen of the GUI, there exists a "BMElib Help" button
% that launches a separate window. Within the window users have readily access
% to the BMElib functions and commands help documentation. Essentially, this 
% feature ports the Matlab command line related help output into a GUI window
% for the convenience of the user. This feature is provided as a reference to 
% the BMElib library and is not crucial for the use of the GUI.
% 
% BMElib is a very powerful tool and at the present development stage of the GUI
% a few of the library's tools are unimplemented within the interface. For these
% tools users need to make use of the Matlab command line environment.
% To this end, see also help on tutorlib (BMElib tutorial) and exlib (examples). 
% 
clear; clear all; clear memory;

global thisVersion

versionData = sscanf(version,'%f');
thisVersion = versionData(1)+versionData(2);
clear versionData

if thisVersion<6.5 
    ip108badVersion('Title','Error')
else
  if exist('guiResources/ithinkPic.png')==2
    ip001splashScreen('Title','Welcome to SEKS-GUI!')
  else
    ip109badPath('Title','Error')
  end
end