
How to use MIDACO in Matlab 
---------------------------

1) Include the files 'midaco.m' and 'midacox.c' in the current directory of Matlab

2) Type 'mex midacox.c' in the Matlab command window and press RETURN

---> This creates the DLL or MEX (e.g. midacox.dll, midacox.mexw32, midacox.mexglx) 

3) Download some small example problem (in Matlab) from: http://www.midaco-solver.com/download.html

4) Now you should be able to run the example !



Troubleshooting
---------------

The MIDACO MEX file has been successfully tested under Windows/Linux/Mac with 
different Matlab versions. If you still have problems creating or running the
MEX file, please contact info@midaco-solver.com.

Type *help midaco* in the command window to get more detailed information 
about MIDACO and especially the error flag 'ifail' which will appear if something
goes wrong with the problem setup.

