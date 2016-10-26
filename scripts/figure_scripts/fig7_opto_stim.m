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
    
    model = load([model_path expt_name{n} '_' expt_ee '_loopy_best_model_' ge_type '.mat']);
    model.graph = full(model.graph);
    
    % extend coordinates
    coords = Coord_active;
    coords(end+1,:) = [0 max(coords(:,2))];
    coords(end+1,:) = [0 0];
    coords(end+1,:) = [max(coords(:,1)) 0];
    coords(end+1,:) = [max(coords(:,1)) max(coords(:,2))];
    coords(end+1,:) = [max(coords(:,1))/2 0];
    coords(end+1,:) = [max(coords(:,1))/2 max(coords(:,2))];
    
    % convert to on edges
    model.ep_on = getOnEdgePot(model.graph,model.G)';

    % edge potential sum
    epsum{n} = sum(model.ep_on,2);
    epsum{n}(sum(model.graph,2)==0) = NaN;
    
    % plot model
    figure; set(gcf,'color','w','position',[2154 560 479 377])
    cc_range = [];
    ep_range = [-1.5 0.1];
    plotGraphModelHighlightEP(model.graph,coords,model.ep_on,...
        cc_range,ep_range,gmap.cmap,[]);
    print(gcf,'-dpdf','-painters',[fig_path expt_name{n} '_ON_' ...
        ge_type '_epsum_graph.pdf']);
    
    % plot epsum raster
    wd = 0.01;
    figure; set(gcf,'color','w','position',[2034 331 596 327])
    hold on
    num_node = length(epsum{n});
    edge_map = jet(64);
    for ii = 1:num_node
        cep = epsum{n}(ii);
        if ~isnan(cep)
            cindx = ceil((cep-ep_range(1))/(ep_range(2)-ep_range(1))*64);
        if cindx<=0 || isnan(cindx)
            cindx = 1;
        elseif cindx >= 64
            cindx = 64;
        end
            patch(epsum{n}(ii)+[-wd wd wd -wd -wd],ii+[-0.5 -0.5 0.5 0.5 -0.5],...
                edge_map(cindx,:),'edgecolor',mycc.gray);
        end
    end
    xlim([min(epsum{n})-2*wd max(epsum{n})+2*wd])
    box on
    xlabel('sum(edge pot)'); ylabel('cell index')
    print(gcf,'-dpdf','-painters',[fig_path expt_name{n} '_ON_' ...
        ge_type '_epsum_raster.pdf']);
    
end

end