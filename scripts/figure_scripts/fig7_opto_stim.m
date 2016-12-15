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

redmap = load(param.redmap);
bluemap = load(param.bluemap);
redmap_light = load(param.redmap_light);

%%
for n = 1:length(expt_name)
    
    expt_ee = param.ee{n}{1};
    model_path = [result_path_base '\' expt_name{n} '\models\']; 
    load([data_path expt_name{n} '\' expt_name{n} '.mat']);
    load([data_path expt_name{n} '\stim_indx.mat']); % stim_indx
    
    model = load([model_path expt_name{n} '_' expt_ee '_loopy_best_model_' ge_type '.mat']);
    model.graph = full(model.graph);
    
    num_node = size(model.graph,1);
    num_stim_cell = length(stim_indx);
    num_nostim_cell = num_node-num_stim_cell;
    nostim_indx = setdiff(1:num_node,stim_indx);
    
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
    
    %% plot model
    figure; set(gcf,'color','w','position',[2154 560 479 377])
    cc_range = [];
    ep_range = [-1.5 0.1];
    plotGraphModelHighlightEP(model.graph,coords,model.ep_on,...
        cc_range,ep_range,gmap.cmap,[]);
    print(gcf,'-dpdf','-painters',[fig_path expt_name{n} '_ON_' ...
        ge_type '_epsum_graph.pdf']);
    
    %% temporarily set recall/norecall cell indx here
    stim_recall = 44;
    stim_norecall = 39;
    
    %% plot node strength against lcc
    lcc = local_cluster_coeff(model.graph);
    
    nodesz = 30;
    figure; set(gcf,'color','w','position',[1983 442 339 290])
    hold on
    scatter(epsum{n},lcc,nodesz,mycc.gray_light,'filled')
    scatter(epsum{n}(stim_indx),lcc(stim_indx),nodesz,mycc.red_light,'filled')
    scatter(epsum{n}(stim_recall),lcc(stim_recall),nodesz,mycc.red,'filled')
    scatter(epsum{n}(stim_norecall),lcc(stim_norecall),nodesz,mycc.blue,'filled')
    xlabel('node strength'); ylabel('local clustering coeff')
    
    print(gcf,'-dpdf','-painters',[fig_path expt_name{n} '_nodestrength_lcc.pdf']);
    
    %% plot epsum raster
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
    
    %% circle representation
    cells1 = setdiff(stim_indx,stim_recall)';
    cells2 = setdiff(stim_indx,stim_norecall)';
    num_half = round(num_nostim_cell/2); num_half(2) = num_nostim_cell-num_half;
    sort_indx1 = [nostim_indx(1:num_half(1)),stim_recall,...
        nostim_indx(num_half(1)+1:sum(num_half)),cells1];
    sort_indx2 = [nostim_indx(1:num_half(1)),stim_norecall,...
        nostim_indx(num_half(1)+1:sum(num_half)),cells2];
    
    % node colors for recall experiment
    nodec1 = zeros(num_node,3);
    nodec1(1:num_half(1),:) = repmat(mycc.gray_light,num_half(1),1);
    nodec1(num_half(1)+1,:) = mycc.red;
    nodec1(num_half(1)+2:num_nostim_cell+1,:) = repmat(mycc.gray_light,num_half(2),1);
    nodec1(num_nostim_cell+2:end,:) = repmat(mycc.red_light,num_stim_cell-1,1);
    
    % node colors for norecall experiment
    nodec2 = nodec1;
    nodec2(num_half(1)+1,:) = mycc.blue;
    
    % edge colors for recall experiment
    maxep = max(max(model.ep_on(stim_indx,stim_indx)));
    minep = min(min(model.ep_on(stim_indx,stim_indx)));
    edge_list1 = zeros(sum(model.graph(:))/2,2);
    [edge_list1(:,2),edge_list1(:,1)] = find(tril(model.graph(sort_indx1,sort_indx1)));
    edgec1 = num2cell(edge_list1);
    for ii = 1:size(edge_list1,1)
        if ismember(edge_list1(ii,1),[num_half(1)+1,num_nostim_cell+2:num_node]) && ...
                ismember(edge_list1(ii,2),[num_half(1)+1,num_nostim_cell+2:num_node])
            ep = model.ep_on(sort_indx1(edge_list1(ii,1)),sort_indx1(edge_list1(ii,2)));
            edgec1{ii,3} = redmap_light.cmap(ceil((ep-minep)/(maxep-minep)*64),:);
        else
            edgec1{ii,3} = mycc.gray_light; % NaN
        end
    end
    
    % edge colors for norecall experiment
    edge_list2 = zeros(sum(model.graph(:))/2,2);
    [edge_list2(:,2),edge_list2(:,1)] = find(tril(model.graph(sort_indx2,sort_indx2)));
    edgec2 = num2cell(edge_list2);
    for ii = 1:size(edge_list2,1)
        if ismember(edge_list2(ii,1),[num_half(1)+1,num_nostim_cell+2:num_node]) && ...
                ismember(edge_list2(ii,2),[num_half(1)+1,num_nostim_cell+2:num_node])
            ep = model.ep_on(sort_indx2(edge_list2(ii,1)),sort_indx2(edge_list2(ii,2)));
            edgec2{ii,3} = redmap_light.cmap(ceil((ep-minep)/(maxep-minep)*64),:);
        else
            edgec2{ii,3} = mycc.gray_light; % NaN
        end
    end
    
    % plot
    figure; set(gcf,'color','w','position',[2022 313 894 372]);
    subplot(1,2,1); title('recalled')
    visGraphCirc(model.graph(sort_indx1,sort_indx1),'edgeColor',edgec1,...
        'nodeColor',nodec1);
    subplot(1,2,2); title('not recalled')
    visGraphCirc(model.graph(sort_indx2,sort_indx2),'edgeColor',edgec2,...
        'nodeColor',nodec2);
    
    print(gcf,'-dpdf','-painters','-bestfit',[fig_path expt_name{n} '_circlelayout_' ...
        ge_type '_stim_neuron.pdf']);
    
    
end

end