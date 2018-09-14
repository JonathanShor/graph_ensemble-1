function [] = figS3_OSI_pred(param)

% parameters
expt_name = param.expt_name;
ee = param.ee;
p = param.p;
ge_type = param.ge_type;
data_path = param.data_path;
fig_path = param.fig_path.core;
result_path_base = param.result_path_base;
savestr = param.savestr;
ccode_path = param.ccode_path;
OSI_thresh = param.OSI_thresh;
mc_minsz = param.mc_minsz;
linew = param.linew;

load(ccode_path);

%% initialize
num_expt = length(expt_name);
num_crf_osi = zeros(num_expt,1);
num_crf = zeros(num_expt,1);
num_osi = zeros(num_expt,1);
num_cell = zeros(num_expt,1);

cos_sim = {};
cos_sim_avg = [];
cos_thresh = [];
pred = {};
pred_stats = [];

sample_step = 0.1;
num_rand = 100;

sample_seq = -0.9:sample_step:0;
[~,indx] = min(abs(sample_seq));
sample_seq(indx) = 0;

% initialize
stats_pl_all_svd = [];
msim_pl_all_svd = [];

expt_count = 0;

%% graph properties
for n = 1:length(expt_name)
    
    expt_ee = ee{n}{1};

    model_path = [result_path_base '\' expt_name{n} '\models\']; 
    
    load([data_path expt_name{n} '\' expt_name{n} '.mat']);
    svd_data = load([data_path 'ensembles\' expt_name{n} '_core_svd.mat']);
    best_model = load([model_path expt_name{n} '_' expt_ee ...
        '_loopy_best_model_' ge_type '.mat']);
    load([data_path expt_name{n} '\Pks_Frames.mat']);
    data_high = Spikes(:,Pks_Frame)';
    vis_stim_high = vis_stim(Pks_Frame);
    num_stim = length(unique(vis_stim))-1;
    num_node = size(best_model.graph,1)-num_stim;
    
    %% find ensembles
    % load results: 'core_crf','core_svd'
    load([result_path_base '\' expt_name{n} '\core\' expt_ee '_crf_svd_core.mat']);
        
    % high OSI
    core_osi = cell(num_stim,1);
    [OSI,OSIstim] = calcOSI(Spikes,vis_stim);
    for ii = 1:num_stim
        core_osi{ii} = find((OSI>OSI_thresh)&(OSIstim==ii));
    end
    
    %% plot ensemble
    rr = 1;
    figure;
    set(gcf,'color','w','position',[2041 430 543 338]);
    set(gcf,'paperpositionmode','auto')
    for ss = 1:num_stim
        
        expt_count = expt_count+1;
        true_label = double(vis_stim_high==ss)';
        
        crf_osi = intersect(core_crf{ss},core_osi{ss});
        crf_svd = intersect(core_crf{ss},core_svd{ss});
        num_cell(expt_count) = size(Spikes,1);
        num_crf(expt_count) = length(core_crf{ss});
        num_osi(expt_count) = length(core_osi{ss});
        num_svd(expt_count) = length(core_svd{ss});
        num_crf_osi(expt_count) = length(crf_osi);
        num_crf_svd(expt_count) = length(crf_svd);
        
        % prediction
        % crf
        [pred.crf{expt_count},cos_sim.crf{expt_count},cos_thresh.crf(expt_count),...
            cos_sim_avg.crf(expt_count,:),acc,prc,rec] = core_cos_sim(core_crf{ss},data_high,true_label);
        pred_stats.crf(expt_count,:) = [acc,prc,rec];
        % svd
        [pred.svd{expt_count},cos_sim.svd{expt_count},cos_thresh.svd(expt_count),...
            cos_sim_avg.svd(expt_count,:),acc,prc,rec] = core_cos_sim(core_svd{ss},data_high,true_label);
        pred_stats.svd(expt_count,:) = [acc,prc,rec];
        % osi
        [pred.osi{expt_count},cos_sim.osi{expt_count},cos_thresh.osi(expt_count),...
            cos_sim_avg.osi(expt_count,:),acc,prc,rec] = core_cos_sim(core_osi{ss},data_high,true_label);
        pred_stats.osi(expt_count,:) = [acc,prc,rec];
        
        subplot(2,num_stim,ss);
        plotCoreOverlay(Coord_active,core_crf{ss},core_svd{ss},mycc.orange,...
            mycc.green,rr)
        subplot(2,num_stim,2*ss-1);
        plotCoreOverlay(Coord_active,core_crf{ss},core_osi{ss},mycc.orange,...
            mycc.gray,rr)
        
        % randomly take out cores - svd
        num_core = length(core_svd{ss});
        noncore = setdiff(1:num_node,core_svd{ss});
        core_plus_seq = round(num_core*sample_seq);
        for ii = 1:length(sample_seq)
            for jj = 1:num_rand
                if core_plus_seq(ii) < 0
                    rand_core = core_osi{ss}(randperm(num_core,num_core+core_plus_seq(ii)));
                else
                    rand_core = noncore(randperm(length(noncore),core_plus_seq(ii)));
                    rand_core = [core_osi{ss};rand_core'];
                end
                
                % predict
                [~,~,~,sim_avg,acc,prc,rec] = core_cos_sim(rand_core,data_high,true_label);
                msim_pl_all_svd(expt_count,ii,jj,:) = sim_avg;
                stats_pl_all_svd(expt_count,ii,jj,:) = [acc,prc,rec];
                
            end
        end
        
        % randomly take out cores - osi
        num_core = length(core_osi{ss});
        noncore = setdiff(1:num_node,core_osi{ss});
        core_plus_seq = round(num_core*sample_seq);
        for ii = 1:length(sample_seq)
            for jj = 1:num_rand
                if core_plus_seq(ii) < 0
                    rand_core = core_osi{ss}(randperm(num_core,num_core+core_plus_seq(ii)));
                else
                    rand_core = noncore(randperm(length(noncore),core_plus_seq(ii)));
                    rand_core = [core_osi{ss};rand_core'];
                end
                
                % predict
                [~,~,~,sim_avg,acc,prc,rec] = core_cos_sim(rand_core,data_high,true_label);
                msim_pl_all_osi(expt_count,ii,jj,:) = sim_avg;
                stats_pl_all_osi(expt_count,ii,jj,:) = [acc,prc,rec];
                
            end
        end
        
    end

    print(gcf,'-dpdf','-painters',[fig_path expt_name{n} '_' expt_ee '_' ...
        savestr '_mc_osi_core.pdf'])
    
end

%% plot core numbers
stepsz = 0.5;
ww = 0.3;

figure
set(gcf,'color','w');
set(gcf,'position',[2096 452 447 233])
set(gcf,'paperpositionmode','auto')

% ensemble number
subplot(1,2,1); hold on
h = boxplot(num_osi./num_cell,'positions',stepsz,'width',ww,'colors',mycc.black);
setBoxStyle(h,linew);
xlim([0 2*stepsz])
ylim([0 max(num_osi./num_cell)])
set(gca,'xcolor','w')
ylabel('cells (%)')
box off

% CRF+osi
subplot(1,2,2); hold on
h = boxplot(num_crf_osi./num_crf,'positions',stepsz,'width',ww,'colors',mycc.black);
setBoxStyle(h,linew);
xlim([0 3*stepsz])
ylim([0 1])
ylabel('OSI in CRF (%)')
set(gca,'xcolor','w')
box off

saveas(gcf,[fig_path expt_ee '_' savestr '_mc_osi_core_nums.pdf'])

%% plot stats
figure;
set(gcf,'color','w','position',[2038 520 778 221]);
set(gcf,'paperpositionmode','auto')

stepsz = 0.5;
binsz = 0.1;
ww = 0.2;

% mean sim value
subplot(1,4,1); hold on
scatter((stepsz-binsz)*ones(size(cos_sim_avg(:,1))),cos_sim_avg(:,1),30,mycc.gray,'+','linewidth',linew);
scatter((stepsz+binsz)*ones(size(cos_sim_avg(:,2))),cos_sim_avg(:,2),30,mycc.black,'+','linewidth',linew);
plot([(stepsz-binsz)*ones(size(cos_sim_avg(:,1))),(stepsz+binsz)*ones(size(cos_sim_avg(:,1)))]',...
    cos_sim_avg','color',mycc.gray);
plot([stepsz-binsz*1.5,stepsz-binsz*0.5],nanmean(cos_sim_avg(:,1))*ones(2,1),'color',...
    mycc.black,'linewidth',3*linew);
plot([stepsz+binsz*0.5,stepsz+binsz*1.5],nanmean(cos_sim_avg(:,2))*ones(2,1),'color',...
    mycc.black,'linewidth',3*linew);
xlim([0.2 2*stepsz-0.2])
set(gca,'xcolor','w')
ylabel('Similarity')

% accuracy
subplot(1,4,2); hold on
h = boxplot(pred_stats(:,1),'positions',stepsz,'width',ww,'colors',mycc.black);
setBoxStyle(h,linew)
xlim([0 2*stepsz]); ylim([0 1])
ylabel('Accuracy')
set(gca,'xcolor','w')
box off

% precision
subplot(1,4,3); hold on
h = boxplot(pred_stats(:,2),'positions',stepsz,'width',ww,'colors',mycc.black);
setBoxStyle(h,linew)
xlim([0 2*stepsz]); ylim([0 1])
ylabel('Precision')
set(gca,'xcolor','w')
box off

% recall
subplot(1,4,4); hold on
h = boxplot(pred_stats(:,3),'positions',stepsz,'width',ww,'colors',mycc.black);
setBoxStyle(h,linew)
xlim([0 2*stepsz]); ylim([0 1])
set(gca,'xtick',[1,2]*stepsz);
ylabel('Recall')
set(gca,'xcolor','w')
box off

saveas(gcf,[fig_path expt_ee '_mc_osi_core_pred_' ge_type '_stats.pdf'])

%% plot reduction results
binsz = 0.02;
wr = 0.3;

figure
set(gcf,'color','w')
set(gcf,'position',[1991 327 650 333]);
set(gcf,'paperpositionmode','auto')

% plus/minus similarity
subplot(2,2,1);
gcapos = get(gca,'position');
plot_box_seq_pair(msim_pl_all_svd,sample_seq,binsz,wr,sample_step,linew,mycc)
set(gca,'xtick',sample_seq,'xticklabel',num2str(100*(1+sample_seq')));
ylim([0 0.5])
ylabel('Similarity');box off
set(gca,'position',gcapos);

% plus/minus statistics
subplot(2,2,2);
gcapos = get(gca,'position');
plot_box_seq_single(stats_pl_all_svd(:,:,:,1),sample_seq,wr,sample_step,linew,mycc)
ylim([0 1])
set(gca,'xtick',sample_seq,'xticklabel',num2str(100*(1+sample_seq')));
ylabel('Accuracy');box off
set(gca,'position',gcapos);

subplot(2,2,3);
gcapos = get(gca,'position');
plot_box_seq_single(stats_pl_all_svd(:,:,:,2),sample_seq,wr,sample_step,linew,mycc)
ylim([0 1])
set(gca,'xtick',sample_seq,'xticklabel',num2str(100*(1+sample_seq')));
ylabel('Precision');box off
set(gca,'position',gcapos);
xlabel('core neurons (%)')

subplot(2,2,4);
gcapos = get(gca,'position');
plot_box_seq_single(stats_pl_all_svd(:,:,:,3),sample_seq,wr,sample_step,linew,mycc)
ylim([0 1])
set(gca,'xtick',sample_seq,'xticklabel',num2str(100*(1+sample_seq')));
ylabel('Recall');box off
xlabel('core neurons (%)')
set(gca,'position',gcapos);

print(gcf,'-dpdf','-painters','-bestfit',[fig_path expt_ee ...
    '_OSI_reduction_pred_stats_' ge_type '.pdf'])

end
