% loopy data processing pipeline

rng(1000);

%% set parameters
param = struct();
param.expt_name = {'m21_d2_vis','m37_d2'};
param.ee = {{'all_high_add_neuron'},{'all_high_add_neuron'}};
param.num_stim = [2,1];
param.ge_type = 'thresh'; % 'full', 'on', 'thresh'
param.savestr = 'add_neuron';

% param.epth = 0.3; % quantile threshold of edge potential
param.epth = 0.05;

param.num_shuff = 100;
param.num_rand = 100;
param.k_seq = 2:6;
param.k = 3;
param.p = 0.05;

param.mc_minsz = 3;

param.data_path = 'C:\Shuting\graph_ensemble\data\';
param.shuff_path_base = [param.data_path 'shuffled\'];
param.result_path_base = 'C:\Shuting\graph_ensemble\results';
param.result_path.stats_path = [param.result_path_base '\stats\'];
param.fig_path.graph_prop = [param.result_path_base '\fig\graph_prop\'];
param.fig_path.core = [param.result_path_base '\fig\core\'];
param.fig_path.ens = [param.result_path_base '\fig\ens\'];
param.fig_path.pred = [param.result_path_base '\fig\pred\'];
param.fig_path.stats = [param.result_path_base '\fig\stats\'];
param.fig_path.opto_spont = [param.result_path_base '\fig\opto_spont\'];
param.fig_path.opto_stim = [param.result_path_base '\fig\opto_stim\'];
param.fig_path.pa = [param.result_path_base '\fig\pa\'];
param.ccode_path = [param.result_path_base '\mycc.mat']; % color code
param.rwbmap = [param.result_path_base '\rwbmap.mat']; % red white blue map
param.graymap = [param.result_path_base '\graymap.mat']; % gray map
param.bluemap = [param.result_path_base '\bluemap.mat']; % blue map
param.redmap = [param.result_path_base '\redmap.mat']; % red map

param.OSI_thresh = 0.4;

% parameters for reduced models
param.maxf = 1000; % max frames for reduced models
param.winsz = 100;

% param.comm_sz_bin_range = 0:0.02:0.6;
% param.comm_deg_bin_range = 0:0.1:5; %0:0.02:1;
% param.comm_ov_bin_range = 0:0.02:0.6;
% param.comm_mem_bin_range = 0:0.02:0.7;
param.ndeg_bin_range = 0:0.01:0.25;
param.lcc_bin_range = 0:0.02:1;
param.cent_bin_range = 0:0.02:1;
param.mc_sz_bin_range = 0:1:15;
param.epsum_bin_range = -1:0.1:0.2;

% plotting parameters
param.linew = 0.5;

%% process data
% make shuffled data for CC graph
makeShuffledData(param);

% make cc graph
makeCCgraph(param);

% threshold edge potentials
threshCRFgraphs(param);

% threshold reduced models
for n = 1:length(param.expt_name)
    load([param.data_path param.expt_name{n} '\Pks_Frames.mat']);
    num_frame = length(Pks_Frame);
    trunc_vec = param.winsz:param.winsz:min([param.maxf,...
        floor(num_frame/param.winsz)*param.winsz]);
    for ii = 1:length(trunc_vec)
        param_rd = param;
        param_rd.expt_name = param.expt_name(n);
        param_rd.ee = {{[param.ee{n}{1} '_' num2str(trunc_vec(ii))]}};
        threshCRFgraphs(param_rd);
    end
end

% calculate cc and crf maximal cliques
calcGraphMC(param);

% calculate random graph maximal cliques
randGraphMC(param);

% % calculate cc and crf graph communities
% calcGraphComm(param);
% 
% % random graph properties for cc and crf
% randGraphStatsCC(param);
% randGraphStatsCRF(param);
% 
% % random graph comm and clique stats
% randGraphCommStats(param)

%% figures
fig2_crf_LL_pred_add_neuron(param);

fig4_cc_crf_mc_graph_prop(param);

fig5_ensemble_identification_add_neuron_CRFSVD(param);
fig5_plot_crf_pred_cos_CRFSVD(param);

fig6_ensemble_reduction_add_neuron(param);

%% compare add neuron with no add neuron models
an_param = param;
an_param.expt_name = {'m21_d2_vis','m37_d2'};
an_param.ee = {{'all_high','all_high_add_neuron'},{'all_high','all_high_add_neuron'}};

threshCRFgraphs(an_param);
calcGraphMC(an_param);

fig_add_neuron_model_prop(an_param);

%% opto spont data
% optogenetic experiments
opto_param = param;
opto_param.npot_bin_range = -1:0.05:1;
opto_param.epot_bin_range = -1:0.05:1;
opto_param.expt_name = {'m23_d1_opto'};
opto_param.ee = {{'high_pre_add_neuron','high_post_add_neuron'}};

threshCRFgraphs(opto_param);

fig7_opto_spont(opto_param);

%% opto stim data
opto_stim_param = param;
opto_stim_param.npot_bin_range = -1:0.05:1;
opto_stim_param.epot_bin_range = -1:0.05:1;
opto_stim_param.expt_name = {'m52_d1_opto'};
opto_stim_param.ee = {{'high_all'}};
opto_stim_param.ndeg_quant = 0.2;

threshCRFgraphs(opto_stim_param);

fig7_opto_stim(opto_stim_param);

%% supplementary figures
% PA dataset
pa_param = param;
pa_param.expt_name = {'pa_511510718_TF1'};
pa_param.ee = {{'vis_high_add_neuron'}};
figS1_pa_pred(pa_param);

figS2_cc_pred(param);
figS3_OSI_pred(param);
figS5_graph_core(param);

cmp_param = param;
cmp_param.expt_name = {'m21_d2_vis','m37_d2'};
cmp_param.ee = {{'all_high','all_high_add_neuron'},{'all_high','all_high_add_neuron'}};
figS2_compare_add_neuron(cmp_param);



