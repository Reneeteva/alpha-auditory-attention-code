# alpha-auditory-attention-code
This repository contains the main code files used in the Alpha research project on auditory stimuli and visual selective attention.

## PsyToolkit task code
The visual search task was implemented in PsyToolkit.  
Six versions of the task are included, corresponding to the six possible orders of the auditory conditions across the three experimental blocks.
The task structure was identical across the six versions. The only difference between the versions was the order of the auditory conditions:
silence, slow-tempo music, and fast-tempo music.

## MATLAB analysis code
The MATLAB code was used to process the PsyToolkit output files and analyze the experimental data.
The input of the MATLAB code was the participant output files exported from PsyToolkit.

The code was used to:
- filter invalid trials
- calculate reaction times
- calculate accuracy measures and number of errors
- apply log transformation to reaction times
- run a linear mixed model testing the effect of auditory condition while accounting for presentation round and subject
- generate tables and graphs for the results

The final central reaction-time analysis was based on log-transformed reaction times and a linear mixed model.
