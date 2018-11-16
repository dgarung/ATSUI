The codes are based on the Adaptive Tsunami SoUrce Inversion (ATSUI) method. The ATSUI method uses a reciprocity principle and optimization to automate the determination of parameters required in the tsunami source inversion analysis. To start the ATSUI method, user must first compute the unit sources according to the reciprocity principle by executing the 'run_source.m'. Once the sources are generated, user needs to run the tsunami forward model (not included here) for each of the generated sources, and store the snapshots of tsunami elevations in a predefined source area. Note that the time interval of the snapshots must be consistent with the observed tsunami data. These snapshots are required as one of the inputs for the subsequent stage. The next stage is the optimization for 
sea surface displacement inversion and slip inversion using 'run_optimization.m'. Details and theory of the ATSUI 
method are described in the following paper:

Mulia, I. E, Gusman, A. R., Hossen, M. J., Satake, K. 2018. Adaptive tsunami source inversion using an optimization and the reciprocity principle. Journal of Geophysical Research: Solid Earth. (in revision)
   
'run_source.m' file: 
Computes Gaussian sources at the observation locations based on the reciprocity principle. 

'run_optimization.m' file: 
Executes the mesh adaptive direct search (MADS) optimization for the two-step inversion of the ATSUI method. The OPTI toolbox is required, which can be dowloaded here https://github.com/jonathancurrie/OPTI 

'inputs' folder:
Contains inputs files required to run the ATSUI method. Example of the input files can be downloaded here https://doi.org/10.5281/zenodo.1486392
All files must be extracted in the 'inputs' folder.

'src' folder:
Contains all matlab functions both newly developed and taken or modified from existing open source programs.
