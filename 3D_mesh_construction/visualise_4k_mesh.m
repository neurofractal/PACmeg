%% First run resample.sh on all participants

%% Now we need to save all .gii files to one location

subject = {'1408'};
for i =1:length(subject)
    cd(['/mnt/scratch14/freesurfer' subject{i} '/Subject' subject{i} '/surf']);
    
    % Go to fs_LR_output_directory /subject/bem & use following in FT
    copyfile(['Subject' subject{i} '.L.midthickness.4k_fs_LR.surf.gii'],'/studies/201601-108/data_analysis/mesh_granger');
    copyfile(['Subject' subject{i} '.R.midthickness.4k_fs_LR.surf.gii'],'/studies/201601-108/data_analysis/mesh_granger');
    
    headshape = ft_read_headshape({['Subject' subject{i} '.L.midthickness.4k_fs_LR.surf.gii'],['Subject' subject{i} '.R.midthickness.4k_fs_LR.surf.gii']}); 
    
    figure; ft_plot_mesh(headshape); camlight;
    title([subject{i}],'FontSize', 20);
end
