**To create a 3D cortical mesh registered to the CONTE69 brain for MEG source analysis:**

- create aligned MRI named mri_realigned (in MATLAB)
- segment and export to freesurfer *(freesurfer.m)*
- run freesurfer to generate 3D cortical mesh *(freesurfer.m)*
- downsample to 4k vertices per hemisphere *(freesurfer_to_HCP_4k.sh)*
- visualise and save in MATLAB format *(visualise_4k_mesh.m)* 

NOTE: Paths within these scripts will need to be manually changed for your computer
