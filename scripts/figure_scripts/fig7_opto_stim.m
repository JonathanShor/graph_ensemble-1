function [] = fig7_opto_stim(param)

% parameters
expt_name = param.expt_name;
ge_type = param.ge_type;
data_path = param.data_path;
fig_path = param.fig_path.opto_stim;
save_path = param.result_path.stats_path;
result_path_base = param.result_path_base;
ccode_path = param.ccode_path;
linew = param.linew;
epsum_quant = param.ndeg_quant;
epsum_bin_range = param.epsum_bin_range;

load(ccode_path);
gmap = load(param.graymap);
rmap = load(param.redmap);

epsum = cell(length(expt_name),2);
epsum_cum = cell(length(expt_name),2);

%%
for n = 1:length(expt_name)
    
    expt_ee = param.ee{n}{1};
    model_path = [result_path_base '\' expt_name{n} '\models\']; 
    load([data_path expt_name{n} '\' expt_name{n} '.mat']);
    load([data_path expt_name{n} '\Stim_cells.mat']);
    num_node = size(Spikes,1);
    nostim_cells = setdiff(1:num_node,Stim_cells);
    
    model = load([model_path expt_name{n} '_' expt_ee '_loopy_best_model_' ge_type '.mat']);
    model.graph = full(model.graph);
    
    % convert to on edges
    model.ep_on = getOnEdgePot(model.graph,model.G)';

    % node degree
    epsum{n,1} = sum(model.ep_on(Stim_cells,Stim_cells),2);
    epsum{n,2} = sum(model.ep_on(nostim_cells,nostim_cells),2);
    epsum_cum{n,1} = calc_cum_dist(epsum{n,1},epsum_bin_range);
    epsum_cum{n,2} = calc_cum_dist(epsum{n,2},epsum_bin_range);
    core_epsum_stim = find(epsum{n,1}>quantile(epsum{n,1},1-epsum_quant));
    
    % plot pre and post models
    figure; set(gcf,'color','w','position',[2154 340 941 597])
    cc_range = [min(model.ep_on(:)) max(model.ep_on(:))];
    ep_range = [-1 0.2];
    subplot(1,2,1)
    plotGraphModelHighlightEP(model.graph(Stim_cells,Stim_cells),...
        Coord_active(Stim_cells,:),model.ep_on(Stim_cells,Stim_cells),...
        cc_range,ep_range,gmap.cmap,[]);
    subplot(1,2,2)
    plotGraphModelHighlightEP(model.graph(nostim_cells,nostim_cells),...
        Coord_active(nostim_cells,:),model.ep_on(nostim_cells,nostim_cells),...
        cc_range,ep_range,rmap.cmap,[]);
    print(gcf,'-dpdf','-painters','-bestfit',[fig_path expt_name{n} '_ON_' ...
        ge_type '_stim_graph.pdf']);
    
    save([result_path_base '\' expt_name{n} '\core\' expt_name{n} '_' ...
        expt_ee '_' ge_type '_stim_epsum_core.mat'],'core_epsum_stim');
    
end

%% plot stats
stepsz = 0.5;
binsz = 0.1;
ww = 0.2;

figure; set(gcf,'color','w','position',[2006 450 371 295])
plot_opto_stim_cum_hist(epsum_cum,mycc,epsum_bin_range,linew);
gcapos = get(gca,'position');
xlabel('sum(edge pot)');ylabel('log(p)');
set(gca,'position',gcapos);
legend off; box off

saveas(gcf,[fig_path 'on_unnormalized_' ge_type '_opto_stim_epsum.pdf']);
    
end