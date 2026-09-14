#!/bin/csh -xef

set datadir = "" #populate

set names = (  ) #populate

foreach subj ($names)

cd $datadir/$subj/$subj.results
# ================================ regress =================================

# create censor file motion_${subj}_censor.1D, for censoring motion 
1d_tool.py -infile dfile_rall.1D -set_nruns 3                            \
    -show_censor_count                                    \
    -censor_motion 0.3 motion_${subj}_prevTRincl \

# combine multiple censor files
1deval -a motion_${subj}_prevTRincl_censor.1D -b censor_${subj}_combined_2.1D       \
       -expr "a*b" > censor_${subj}_prevTRincl_combined_3.1D




# ------------------------------
# run the regression analysis
3dDeconvolve -input pb04.$subj.r*.scale+tlrc.HEAD                        \
    -censor censor_${subj}_prevTRincl_combined_3.1D                                 \
    -ortvec mot_demean.r01.1D mot_demean_r01                             \
    -ortvec mot_demean.r02.1D mot_demean_r02                             \
    -ortvec mot_demean.r03.1D mot_demean_r03                             \
    -polort 4                                                            \
    -local_times                                                         \
    -num_stimts 8                                                       \
    -stim_times_AM1 1 stimuli/${subj}.AppDec_local.txt 'dmBLOCK(1)'     \
    -stim_label 1 AppDec                                             \
    -stim_times_AM1 2 stimuli/${subj}.AppInp_local.txt 'dmBLOCK(1)'     \
    -stim_label 2 AppInp                                             \
    -stim_times_AM1 3 stimuli/${subj}.AmbDec_local.txt 'dmBLOCK(1)'     \
    -stim_label 3 AmbDec                                             \
    -stim_times_AM1 4 stimuli/${subj}.AmbInp_local.txt 'dmBLOCK(1)'     \
    -stim_label 4 AmbInp                                             \
    -stim_times_AM1 5 stimuli/${subj}.AvoDec_local.txt 'dmBLOCK(1)'     \
    -stim_label 5 AvoDec                                             \
    -stim_times_AM1 6 stimuli/${subj}.AvoInp_local.txt 'dmBLOCK(1)'     \
    -stim_label 6 AvoInp                                             \
    -stim_times_AM1 7 stimuli/${subj}.MisDec_local.txt 'dmBLOCK(1)'     \
    -stim_label 7 MisDec                                             \
    -stim_times_AM1 8 stimuli/${subj}.MisInp_local.txt 'dmBLOCK(1)'     \
    -stim_label 8 MisInp                                             \
    -allzero_OK                                                          \
    -GOFORIT 11                                                          \
    -fout -tout -x1D X.xmat_prevTRincl.1D -xjpeg X_prevTRincl.jpg                              \
    -x1D_uncensored X.nocensor_prevTRincl.xmat.1D                                   \
    -errts errts.${subj}_prevTRincl                                                 \
    -bucket stats.${subj}_prevTRincl

# return to parent directory (just in case...)
cd ../../

end