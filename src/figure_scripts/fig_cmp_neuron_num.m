function [] = fig_cmp_neuron_num(param)

% parameters
expt_name = param.expt_name;
ee = param.ee;
num_shuff = param.num_shuff;
k = param.k;
p = param.p;
ge_type = param.ge_type;
data_path = param.data_path;
fig_path = param.fig_path.ens;
save_path = param.result_path.stats_path;
result_path_base = param.result_path_base;
savestr = param.savestr;
ccode_path = param.ccode_path;
rwbmap = param.rwbmap;
num_expt = length(expt_name);
linew = param.linew;
rand_perc = param.rand_perc;

num_rep = 10;

load(ccode_path);
load(rwbmap);

%%
shared = [];
for n = 1:num_expt
    
    expt_ee = ee{n};
    num_rand = length(rand_perc);
    part_model = cell(num_rand,num_rep);
    cell_indx = cell(num_rand,num_rep);
    
    model_path = [result_path_base '\' expt_name{n} '\models\']; 
    load([data_path expt_name{n} '\' expt_name{n} '.mat']);
    load([data_path expt_name{n} '\Pks_Frames.mat']);
    num_stim = length(setdiff(vis_stim,0));
    
    full_model = load([model_path expt_name{n} '_' expt_ee{1} ...
        '_loopy_best_model_' ge_type '.mat']);
    for ii = 1:num_rand
        for jj = 1:num_rep
            part_data = load([data_path expt_name{n} '\' expt_name{n} '_' ...
                expt_ee{1} '_' num2str(rand_perc(ii)) '_' num2str(jj) '.mat']);
            cell_indx{ii,jj} = part_data.cell_indx;
            part_model{ii,jj} = load([model_path expt_name{n} '_' expt_ee{1} '_' ...
                num2str(rand_perc(ii)) '_' num2str(jj) '_loopy_best_model_' ...
                ge_type '.mat']);
        end
    end
    
    core = load([result_path_base '\' expt_name{n} '\core\' expt_ee{1} ...
        '_crf_svd_core.mat']);
    
    % compare adjmat
    for ii = 1:num_rand
        num_shared = zeros(num_stim,num_rep);
        for jj = 1:num_stim
            ens = core.core_crf{jj};
            for kk = 1:num_rep
                [ens_shared,ia] = intersect(cell_indx{ii,kk},ens);
                part_graph = part_model{ii,kk}.graph(ia,ia);
                full_graph = full_model.graph(ens_shared,ens_shared);
                num_shared(jj,kk) = sum(sum(abs(part_graph==1&full_graph==1)))/...
                    sum(sum((part_graph+full_graph)~=0));
            end
        end
        shared(ii,:) = num_shared(:);
    end
    
end

%% plot
step = 0.5;
wd = 0.2;

figure; set(gcf,'color','w','position',[2008 289 345 300])
hold on;
for ii = 1:num_rand
    h = boxplot(shared(ii,:),'positions',ii*step,'width',wd,...
        'colors',[0 0 0]);
    setBoxStyle(h,linew);
end
xlim([0,step*(num_rand+1)])
ylim([0 max(shared(:))])
set(gca,'xtick',(1:num_rand)*step,'xticklabel',rand_perc,'XTickLabelRotation',45)
xlabel('population (%)')
ylabel('shared connections(%)')
box off

print(gcf,'-painters','-dpdf','-bestfit',[fig_path 'reduce_neuron_shared.pdf']);



end



