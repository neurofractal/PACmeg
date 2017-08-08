# Script to convert individual freesurfer output to a 4k cortical mesh in FS_LR space

# Make sure you have SUBJECTS_DIR set up to the location of your 
# Freesurfer output directory not the specific subject folder e.g. 
# export SUBJECTS_DIR=/mnt/scratch14/freesurferXXXX

# Parameters - CHANGE SUBJECT_ID=SubjectXXXX accordingly
export SUBJECT_ID=Subject1410
printf "SUBJECT_DIR = %s \nSUBJECT_ID = %s \n" "$SUBJECTS_DIR" "$SUBJECT_ID"
cd $SUBJECTS_DIR/$SUBJECT_ID/surf

# LH Preparation Freesurfer to fs_LR 32k
'/studies/201601-108/scripts/granger_visual/wb_shortcuts' -freesurfer-resample-prep \
lh.white \
lh.pial \
lh.sphere.reg \
/studies/201601-108/scripts/granger_visual/standard_mesh_atlases/resample_fsaverage/fs_LR-deformed_to-fsaverage.L.sphere.32k_fs_LR.surf.gii \
lh.midthickness.surf.gii \
$SUBJECT_ID.L.midthickness.32k_fs_LR.surf.gii \
lh.sphere.reg.surf.gii
printf "\nFinished Freesurfer to FS_LR for %s Left Hemisphere \n\n" "$SUBJECT_ID"

# RH Preparation Freesurfer to fs_LR 32k
'/studies/201601-108/scripts/granger_visual/wb_shortcuts' -freesurfer-resample-prep \
rh.white \
rh.pial \
rh.sphere.reg \
/studies/201601-108/scripts/granger_visual/standard_mesh_atlases/resample_fsaverage/fs_LR-deformed_to-fsaverage.R.sphere.32k_fs_LR.surf.gii \
rh.midthickness.surf.gii \
$SUBJECT_ID.R.midthickness.32k_fs_LR.surf.gii \
rh.sphere.reg.surf.gii
printf "\nFinished Freesurfer to FS_LR for %s Right Hemisphere \n\n" "$SUBJECT_ID"

# Resample 32k to 4k LH
printf "Downsampling..."
wb_command -surface-resample \
$SUBJECT_ID.L.midthickness.32k_fs_LR.surf.gii \
/studies/201601-108/scripts/granger_visual/standard_mesh_atlases/L.sphere.32k_fs_LR.surf.gii \
/studies/201601-108/scripts/granger_visual/megconnectome-3.0/template/Sphere.4k.L.surf.gii \
BARYCENTRIC \
$SUBJECT_ID.L.midthickness.4k_fs_LR.surf.gii
printf "\nFinished Downsampling from 32k to 4k for %s Left Hemisphere \n\n" "$SUBJECT_ID"

# Resample 32k to 4k RH
printf "Downsampling..."
wb_command -surface-resample \
$SUBJECT_ID.R.midthickness.32k_fs_LR.surf.gii \
/studies/201601-108/scripts/granger_visual/standard_mesh_atlases/R.sphere.32k_fs_LR.surf.gii \
/studies/201601-108/scripts/granger_visual/megconnectome-3.0/template/Sphere.4k.R.surf.gii \
BARYCENTRIC \
$SUBJECT_ID.R.midthickness.4k_fs_LR.surf.gii
printf "\nFinished Downsampling from 32k to 4k for %s Right Hemisphere \n\n" "$SUBJECT_ID"


