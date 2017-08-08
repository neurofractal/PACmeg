%% Run Freesurfer 5.3 to generate a 3D cortical mesh for source localisation 

%% IMPORTANT

% ALWAYS export your mri_aligned variable. This has been aligned to the
% correct co-ordinate system.

%% Run the following lines in Matlab
% Load mri_realigned (change for your data)

subject = '1410';
subname =['Subject' subject];
cd(sprintf('/studies/201601-108/data_analysis/%s/visual/',subject)); 
load('mri_realigned');

cfg = [];
ft_sourceplot(cfg,mri_realigned); drawnow;

% save the MRI in a FreeSurfer compatible format
cfg             = [];
cfg.filename    = subname;
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri_realigned);
clear mri_realigned

% Segment using SPM

mri = ft_read_mri([subname '.mgz']);
mri.coordsys = 'neuromag';

cfg = [];
cfg.output = 'brain';
seg = ft_volumesegment(cfg, mri);
mri.anatomy = mri.anatomy.*double(seg.brain);

% Save in freesurfer format
cfg             = [];
cfg.filename    = ([subname 'masked']);
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri);

cfg = [];
ft_sourceplot(cfg,mri); drawnow;

% Make directory to hold freesurfer output (change as necessary)
mkdir('/mnt/scratch14/freesurfer1410'); cd;

%% Now to freesurfer
% Type / copy+paste the remaining lines into a terminal

export FREESURFER_HOME=/apps/freesurfer5.3
% Change accordingly
export SUBJECTS_DIR=/mnt/scratch14/freesurfer1410
source $FREESURFER_HOME/SetUpFreeSurfer.sh
mksubjdirs $SUBJECTS_DIR/Subject1410
cd

%% Part 2

% cd to location of SubjectXXmasked.mgz
cp Subject1410masked.mgz $SUBJECTS_DIR/Subject1410/mri/Subject1410masked.mgz
cp Subject1410.mgz       $SUBJECTS_DIR/Subject1410/mri/Subject1410.mgz
cd $SUBJECTS_DIR/Subject1410/mri

mri_convert -c -oc 0 0 0 Subject1410masked.mgz brainmask.mgz
mri_convert -c -oc 0 0 0 Subject1410.mgz       orig.mgz
cd

recon-all -talairach      -subjid Subject1410
recon-all -nuintensitycor -subjid Subject1410
recon-all -normalization  -subjid Subject1410
recon-all -gcareg         -subjid Subject1410
recon-all -canorm         -subjid Subject1410
recon-all -careg          -subjid Subject1410
recon-all -careginv       -subjid Subject1410
recon-all -calabel        -subjid Subject1410
recon-all -normalization2 -subjid Subject1410
recon-all -maskbfs        -subjid Subject1410
recon-all -segmentation   -subjid Subject1410
recon-all -fill           -subjid Subject1410
cd

%% Part 3
recon-all -fill       -subjid Subject1410
recon-all -tessellate -subjid Subject1410
recon-all -smooth1    -subjid Subject1410
recon-all -inflate1   -subjid Subject1410
recon-all -qsphere    -subjid Subject1410
recon-all -fix        -subjid Subject1410
recon-all -white      -subjid Subject1410
recon-all -finalsurfs -subjid Subject1410
recon-all -smooth2    -subjid Subject1410
recon-all -inflate2   -subjid Subject1410
recon-all -cortparc2 -subjid Subject1410

# then use a shortcut command to do the rest, but we need the rawavg.mgz file to exist
cp $SUBJECTS_DIR/Subject1410/mri/Subject1410.mgz $SUBJECTS_DIR/Subject1410/mri/rawavg.mgz
recon-all -autorecon3 -subjid Subject1410
cd




