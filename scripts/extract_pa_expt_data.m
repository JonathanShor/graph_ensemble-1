
dpath = 'C:\Shuting\graph_ensemble\data\pa_raw\';
spathbase = 'C:\Shuting\graph_ensemble\data\';
ecid = {'511509529','511507650','511510650','511510670','511510718','511510855'};
tf_seq = [1,2,4,8,15];
expt1 = 20000;
expt2 = 40000;

for n = 1:length(ecid)

    load([dpath 'ecid_' ecid{n} '_fr.mat']);
    load([dpath 'ecid_' ecid{n} '_coords.mat']);

    vis_stim(vis_stim==5)=1;
    vis_stim(vis_stim==6)=2;
    vis_stim(vis_stim==7)=3;
    vis_stim(vis_stim==8)=4;
    vis_stim_all = vis_stim;
    Spikes_all = Spikes;
    high_vec = zeros(1,size(Spikes,2));
    high_vec(Pks_Frame)=1;

    %% extract TF=1 for all expt
    spath = [spathbase 'pa_' ecid{n} '_TF1\'];
    sname = ['pa_' ecid{n}];
    if exist(spath,'dir')~=7
        mkdir(spath);
    end

    % expt data
    Spikes = Spikes_all(:,tf==1);
    vis_stim = vis_stim_all(tf==1);
    data = Spikes_all(:,tf==1&high_vec)';
    save([spath sname '_TF1_vis_high_add_neuron.mat'],'data');


    %% extract TF=1 for the first experiment
    spath = [spathbase 'pa_' ecid{n} '_1_TF1\'];
    sname = ['pa_' ecid{n}];
    if exist(spath,'dir')~=7
        mkdir(spath);
    end

    % expt data
    Spikes = Spikes_all(:,1:expt1);
    Spikes = Spikes(:,tf(1:expt1)==1);
    vis_stim = vis_stim_all(1:expt1);
    vis_stim = vis_stim(tf(1:expt1)==1);
    data = Spikes_all(:,1:expt1);
    data = data(:,tf(1:expt1)==1&high_vec(1:expt1))';
    save([spath sname '_1_TF1_vis_high.mat'],'data');

end
