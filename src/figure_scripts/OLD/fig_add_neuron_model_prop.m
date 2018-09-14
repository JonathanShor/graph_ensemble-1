function [] = fig_add_neuron_model_prop(param)

% parameters
expt_name = param.expt_name;
ee = param.ee;
ge_type = param.ge_type;
fig_path = param.fig_path.graph_prop;
save_path = param.result_path.stats_path;
result_path_base = param.result_path_base;
savestr = param.savestr;
ccode_path = param.ccode_path;

ndeg_bin_range = param.ndeg_bin_range;
lcc_bin_range = param.lcc_bin_range;
cent_bin_range = param.cent_bin_range;
mc_sz_bin_range = param.mc_sz_bin_range;

linew = param.linew;

load(ccode_path);

% initialize results
num_expt = length(expt_name);
mc_sz = cell(num_expt,2);
mc_num = zeros(num_expt,2);
dens = cell(num_expt,2);
lcc = cell(num_expt,2);
ndeg = cell(num_expt,2);
cent = cell(num_expt,2);

mc_sz_cum = cell(num_expt,2);
lcc_cum = cell(num_expt,2);
ndeg_cum = cell(num_expt,2);
cent_cum = cell(num_expt,2);

%% go over experiments
for n = 1:length(expt_name)
    
    expt_ee = ee{n};
    load([param.data_path expt_name{n} '\' expt_name{n} '.mat']);
    fprintf('Processing %s_%s...\n',expt_name{n},expt_ee{1});

    % load model
    model_path = [result_path_base '\' expt_name{n} '\models\']; 
    plain_model = load([model_path  expt_name{n} '_' expt_ee{1} ...
        '_loopy_best_model_' ge_type '.mat']);
    plain_graph = plain_model.graph;
    num_node = size(plain_graph,1);

    an_model = load([model_path  expt_name{n} '_' expt_ee{2} ...
        '_loopy_best_model_' ge_type '.mat']);
    an_graph = an_model.graph;
    num_node_an = size(an_graph,1);

    num_stim = num_node_an - num_node;
    
    % load data
    load([param.data_path expt_name{n} '\' expt_name{n} '.mat']);
    load([param.data_path expt_name{n} '\Pks_Frames.mat']);
    data_high = Spikes(:,Pks_Frame)';
    
    %% plot structure
    coord_ext = Coord_active;
    coord_ext(end+1,:) = [0 max(coord_ext(:,2))];
    coord_ext(end+1,:) = [0 0];
    
    figure; set(gcf,'color','w','position',[600 600 900 300],'paperpositionmode','manual');
    subplot(1,2,1)
    plotGraphModel(plain_graph,Coord_active,plain_model.edge_pot,0.2);
    title('original')
    subplot(1,2,2)
    plotGraphModel(an_graph,coord_ext,an_model.edge_pot,0.2);
    title('add neuron')

    saveas(gcf,[fig_path expt_name{n} expt_ee{1} '_crf_cc_model_' ge_type '.fig'])
    print(gcf,'-dpdf','-painters',[fig_path expt_name{n} expt_ee{1} ...
        '_crf_cc_model_' ge_type '.pdf'])

    %% plot maximal cliques
%     plotLatentNeuronMC(plain_graph,Coord_active);
%     print(gcf,'-dpdf','-painters',[fig_path expt_ee{e} '_crf_mc_'...
%         ge_type '.pdf'])

    %% maximal cliques
    % plain model
    mc = maximalCliques(plain_graph);
    mc_plain = cell(size(mc,2),1);
    for ii = 1:size(mc,2)
        mc_plain{ii} = find(mc(:,ii));
    end

    % add neuron
    mc = maximalCliques(an_graph);
    mc_an = cell(size(mc,2),1);
    for ii = 1:size(mc,2)
        mc_an{ii} = find(mc(:,ii));
    end
    mc_an_sz = cellfun('length',mc_an);
    
    %% compare with identified cores
    load([result_path_base '\' expt_name{n} '\core\' expt_ee{2} '_mc_svd_core_' ...
        ge_type '.mat']);
    
    % visual ensembles
    [core_plain,core_plain_spont] = find_spont_core(mc_an,core_crf);
    
    % cosine similarity with spont activity
    num_frame = length(Pks_Frame);
    spont_label = double(vis_stim(Pks_Frame)==0)';
    num_core_spont = length(core_plain_spont);
    spont_sim = zeros(num_core_spont,num_frame);
    spont_pred = zeros(num_core_spont,num_frame);
    spont_acc = zeros(num_core_spont,1);
    th = zeros(num_core_spont,1);
    for ii = 1:num_core_spont
        [spont_pred(ii,:),spont_sim(ii,:),th(ii),~,spont_acc(ii)] = core_cos_sim(core_plain_spont{ii},...
            data_high,spont_label);
    end
    
    % plot all predictions
    plot_pred_raster(spont_pred,spont_label',cmap)
    
    %% mc number
    mc_num(n,1) = length(mc_plain);
    mc_num(n,2) = length(mc_an);

    %% mc size
    mc_sz{n,1} = cellfun('length',mc_plain);
    mc_sz{n,2} = cellfun('length',mc_an);

    % cumulative distribution
    mc_sz_cum{n,1} = calc_cum_dist(mc_sz{n,1},mc_sz_bin_range);
    mc_sz_cum{n,2} = calc_cum_dist(mc_sz{n,2},mc_sz_bin_range);

    %% ------------- graph properties ---------------- %
    % 1. connection density
    dens{n,1} = sum(plain_graph(:))/num_node/(num_node-1);
    dens{n,2} = sum(an_graph(:))/num_node_an/(num_node_an-1);

    % 2. node degree
    ndeg{n,1} = sum(plain_graph,2)/2/num_node;
    ndeg{n,2} = sum(an_graph,2)/2/num_node_an;
    ndeg_cum{n,1} = calc_cum_dist(ndeg{n,1},ndeg_bin_range);
    ndeg_cum{n,2} = calc_cum_dist(ndeg{n,2},ndeg_bin_range);

    % 3. local clustering coefficient
    lcc{n,1} = local_cluster_coeff(plain_graph);
    lcc{n,2} = local_cluster_coeff(an_graph);
    lcc_cum{n,1} = calc_cum_dist(lcc{n,1},lcc_bin_range);
    lcc_cum{n,2} = calc_cum_dist(lcc{n,2},lcc_bin_range);

    % 4. centrality
    cent{n,1} = eigenvec_centrality(plain_graph);
    cent{n,2} = eigenvec_centrality(an_graph);
    cent_cum{n,1} = calc_cum_dist(cent{n,1},cent_bin_range);
    cent_cum{n,2} = calc_cum_dist(cent{n,2},cent_bin_range);

end

%% save results
save([save_path 'plain_addneuron_graph_prop_' savestr '_' ge_type '.mat'],'expt_name','ee','mc_sz','mc_sz_cum',...
    'mc_num','dens','ndeg','ndeg_cum','lcc','lcc_cum','-v7.3');

%%
figure; set(gcf,'color','w','position',[2454,301,560,465])

% density
boxwd = 0.2;
subplot(2,3,1);hold on;
dens_plain = cell2mat(dens(:,1)');
h = boxplot(dens_plain,'positions',0.5,'width',boxwd,'colors',mycc.black);
setBoxStyle(h,linew);
dens_an = cell2mat(dens(:,2)');
h = boxplot(dens_an,'positions',1,'width',boxwd,'colors',mycc.orange);
set(h(7,:),'visible','off')
setBoxStyle(h,linew);
xlim([0 1.5])
ylim([min([dens_plain,dens_an])-0.02 max([dens_plain,dens_an])]+0.02)
gcapos = get(gca,'position');
title('density')
set(gca,'xtick',[0.5 1],'xticklabel',{'original','add neuron'},'linewidth',linew)
set(gca,'position',gcapos);

% node degree
subplot(2,3,2)
plot_addneuron_cum_hist(ndeg_cum,mycc,ndeg_bin_range,linew);
gcapos = get(gca,'position');
title('node degree');ylabel('p');
set(gca,'position',gcapos);
legend off; box on

% lcc
subplot(2,3,3)
plot_addneuron_cum_hist(lcc_cum,mycc,lcc_bin_range,linew);
gcapos = get(gca,'position');
title('lcc');ylabel('p');
set(gca,'position',gcapos);
legend off; box on

% centrality
subplot(2,3,4)
plot_addneuron_cum_hist(cent_cum,mycc,cent_bin_range,linew);
gcapos = get(gca,'position');
title('centrality');ylabel('p');
set(gca,'position',gcapos);
legend off; box on

% maximal clique number
boxwd = 0.2;
subplot(2,3,5);hold on;
h = boxplot(mc_num(:,1),'positions',0.5,'width',boxwd,'colors',mycc.black);
setBoxStyle(h,linew);
h = boxplot(mc_num(:,2),'positions',1,'width',boxwd,'colors',mycc.orange);
set(h(7,:),'visible','off')
setBoxStyle(h,linew);
xlim([0 1.5])
ylim([min(mc_num(:))-50 max(mc_num(:))+50])
gcapos = get(gca,'position');
title('NMC')
set(gca,'xtick',[0.5 1],'xticklabel',{'original','add neuron'},'linewidth',linew)
set(gca,'position',gcapos);

% maximal clique size
subplot(2,3,6)
plot_addneuron_cum_hist(mc_sz_cum,mycc,mc_sz_bin_range,linew);
gcapos = get(gca,'position');
title('sMC');ylabel('p');
set(gca,'position',gcapos);
box on

saveas(gcf,[fig_path 'add_neuron_graph_prop_all.pdf']);


end
