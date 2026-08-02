This folder contains the main final code files used in the research project.

The PsyToolkit task files include six versions of the same visual search task.
The six versions differ only in the order of the auditory conditions across the three blocks.

The MATLAB RT code analyzes reaction time data.
It reads the PsyToolkit output files, filters invalid trials, applies log transformation to reaction times,
and runs a linear mixed model to test the effect of auditory condition while accounting for presentation round and subject.

The accuracy/errors code calculates accuracy and errors for each auditory condition.
Accuracy was examined as a control measure, since most participants made very few errors.