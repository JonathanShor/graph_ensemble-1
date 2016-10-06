% script for calculating binary spike matrix from PA dataset

dpath = 'C:\Shuting\graph_ensemble\data\pa_raw\';
ecid = {'ecid_511507650','ecid_511509529','ecid_511510650','ecid_511510718',...
    'ecid_511510855','ecid_511510670'};

qnoise = 0.3;
num_id = length(ecid);
for n = 1:num_id
    
    load([dpath ecid{n} '.mat']); % raw, corrected, dff, stim_info
    
    % get spikes
    th = quantile(dff,qnoise,2)*ones(1,size(dff,2));
    dff_th = dff;
    dff_th(dff<=th) = NaN;
    baseline = 3*nanstd(dff_th,[],2)+nanmean(dff_th,2);
    Spikes = dff>baseline*ones(1,size(dff,2)); % num_neuron-by-num_frame
    
    % extract stim vector
    vis_stim = zeros(1,size(dff,2));
    tf = zeros(1,size(dff,2));
    for ii = 1:length(stim_info.orientation)
        if ~isnan(stim_info.orientation(ii))
            vis_stim(stim_info.start(ii):stim_info.end(ii)) = stim_info.orientation(ii)/45+1;
            tf(stim_info.start(ii):stim_info.end(ii)) = stim_info.temporal_frequency(ii);
        else
            vis_stim(stim_info.start(ii):stim_info.end(ii)) = -1;
        end
    end
    
    % save result
    save([dpath ecid{n} '_spikes.mat'],'Spikes','vis_stim','tf','-v7.3');
    
end
