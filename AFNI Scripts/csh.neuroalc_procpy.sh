#!/bin/tcsh -xef

##conda activate py39_afni_tiny (only if python isn't set up)

set datadir = ""

set names = (  )

set alignCenters_on = "YES"
set ssWarper_on = "YES"
set procpy_on = "YES"

open -a XQuartz

#make QC directory
mkdir $datadir/QC_APT_MASTER
##############################################################
# Revisions history:
# 1. Assumes SSwarper was run prior to procpy. Note that input dsets are _shft versions
#    and tlrc base is the SSW version. NL_warped dsets are provided (output of SSwarper).
#    anat_has_skull set to no. 
# 2. Option anat_follower added (per Paul Thomas, AFNI). The unskullstripped anatomical 
#    is copied and warped just like in the skullstripped input; this can help with doublechecking alignment
# 3. Cost for align_opts_aea set to nmi, added -giant_move
# 4. blur_size set to 5.0
# 5. blur_in_mask yes used instead of blur_in_automask
# 6. radial_correlate_blocks tcat volreg for some additional QC (not sure why)
# 7. added -align_unifize_epi local - runs uniformity correction on EPI datasets (P Taylor)
# 8. Consider changing html_review_style to pythonic (better visuals, etc). This requires
#    matplotlib python library. 
# 
# See afni message board conversation here: 
# https://afni.nimh.nih.gov/afni/community/board/read.php?1,168933,168933#msg-168933
##############################################################


foreach name ($names)

	cd $datadir/$name

	echo $name Starting Preprocessing Pipeline
	echo $name Starting Preprocessing Pipeline
	echo $name Starting Preprocessing Pipeline
	

if ($alignCenters_on == "YES") then
	echo $name Running Align_Centers
	echo $name Running Align_Centers
	echo $name Running Align_Centers

    @Align_Centers -cm \
	-base ~/abin/TT_N27+tlrc.HEAD \
	-dset ${name}.T1+orig.HEAD \
	-child ${name}.apt*HEAD

endif


if ($ssWarper_on == "YES") then
	echo $name Running SSwarper
	echo $name Running SSwarper
	echo $name Running SSwarper
		
	@SSwarper -tmp_name_nice \
	-input ${name}.T1_shft+orig \
	-base ~/abin/TT_N27_SSW.nii.gz \
	-subid ${name} 

endif
	

if ($procpy_on == "YES") then
	echo $name Running afni_proc.py
	echo $name Running afni_proc.py
	echo $name Running afni_proc.py	

afni_proc.py \
  -subj_id $name \
  -dsets $name.apt1_shft+orig $name.apt2_shft+orig $name.apt3_shft+orig \
  -blocks tshift align tlrc volreg blur mask scale regress \
  -copy_anat anatSS.${name}.nii \
  -anat_has_skull no \
    -anat_follower anat_w_skull anat ${name}.T1_shft+orig \
  -align_opts_aea -cost nmi -check_flip -giant_move \
  -align_unifize_epi local \
  -volreg_align_to MIN_OUTLIER \
  -volreg_align_e2a \
  -volreg_tlrc_warp \
  -tlrc_base ~/abin/TT_N27_SSW.nii.gz \
  -tlrc_NL_warp \
  -tlrc_NL_warped_dsets \
       anatQQ.${name}.nii \
       anatQQ.${name}.aff12.1D \
       anatQQ.${name}_WARP.nii \
  -mask_epi_anat yes \
  -blur_size 5.0 \
  -blur_in_mask yes \
  -regress_stim_times \
       stim_times/$name.AppDec_local.txt \
       stim_times/$name.AppInp_local.txt \
       stim_times/$name.AmbDec_local.txt \
       stim_times/$name.AmbInp_local.txt \
       stim_times/$name.AvoDec_local.txt \
       stim_times/$name.AvoInp_local.txt \
       stim_times/$name.MisDec_local.txt \
       stim_times/$name.MisInp_local.txt \
  -regress_stim_labels \
       AppDec \
       AppInp \
       AmbDec \
       AmbInp \
       AvoDec \
       AvoInp \
       MisDec \
       MisInp \
  -regress_stim_types AM1 -regress_basis 'dmBLOCK(1)' \
  -regress_opts_3dD \
     -allzero_OK \
     -GOFORIT 11 \
  -regress_local_times \
  -regress_motion_per_run \
  -regress_censor_extern ../neuroalc_apt_dummyCensor.1D \
  -regress_censor_motion 0.3 \
  -regress_censor_outliers 0.05 \
  -regress_compute_fitts \
  -regress_est_blur_epits \
  -regress_est_blur_errts \
  -radial_correlate_blocks tcat volreg \
  -html_review_style basic \
  -execute



#assemble QC files into QC_MASTER directory for easier review
cp -R $name.results/QC_$name $datadir/QC_APT_MASTER/QC_$name

#second command to create 3dDeconvolve command for all choices regression
cp stim_times/*AllChoice* $name.results/stimuli

afni_proc.py \
  -subj_id $name \
  -dsets $name.apt1_shft+orig $name.apt2_shft+orig $name.apt3_shft+orig \
  -blocks tshift align tlrc volreg blur mask scale regress \
  -copy_anat anatSS.${name}.nii \
  -anat_has_skull no \
  -anat_follower anat_w_skull anat ${name}.T1_shft+orig \
  -align_opts_aea -cost nmi -check_flip -giant_move \
  -align_unifize_epi local \
  -volreg_align_to MIN_OUTLIER \
  -volreg_align_e2a \
  -volreg_tlrc_warp \
  -tlrc_base ../template/TT_N27_SSW.nii.gz \
  -tlrc_NL_warp \
  -tlrc_NL_warped_dsets \
       anatQQ.${name}.nii \
       anatQQ.${name}.aff12.1D \
       anatQQ.${name}_WARP.nii \
  -mask_epi_anat yes \
  -blur_size 5.0 \
  -blur_in_mask yes \
  -regress_stim_times \
       stim_times/$name.AllDec_local.txt \
       stim_times/$name.AllInp_local.txt \
       stim_times/$name.MisDec_local.txt \
       stim_times/$name.MisInp_local.txt \
  -regress_stim_labels \
       AllChoiceDec \
       AllChoiceInp \
       MisDec \
       MisInp \
  -regress_stim_types AM1	-regress_basis 'dmBLOCK(1)' \
  -regress_opts_3dD \
      -allzero_OK \
      -GOFORIT 11 \
  -regress_local_times \
  -regress_motion_per_run \
  -regress_censor_extern ../neuroalc_apt_dummyCensor.1D \
  -regress_censor_motion 0.3 \
  -regress_censor_outliers 0.05 \
  -regress_compute_fitts \
  -regress_est_blur_epits	\
  -regress_est_blur_errts	\
  -write_3dD_prefix allChoice. \
  -write_3dD_script proc.$name.3dDec.allChoice \
  -radial_correlate_blocks tcat volreg \
  -html_review_style basic \

endif

end
exit