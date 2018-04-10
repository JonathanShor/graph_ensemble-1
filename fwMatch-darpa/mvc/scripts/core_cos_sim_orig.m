function [pred,sim_core,sim_thresh,sim_avg,acc,prc,rec] = core_cos_sim_orig(core,data,true_label)
% calculate cosine similarity using ensembles
% data is num_frame-by-num_neuron

% noise quantile
qnoise = 0.7;

num_node = size(data,2);
core_vec = zeros(num_node,1);
core_vec(core) = 1;
sim_core = 1-pdist2(data,core_vec','cosine')';
sim_avg = [mean(sim_core(true_label==0)),mean(sim_core(true_label==1))];
sim_thresh = 3*std(sim_core(sim_core<=quantile(sim_core,qnoise)))+...
    mean(sim_core(sim_core<=quantile(sim_core,qnoise)));
pred = sim_core>sim_thresh;

% prediction statistics
TP = sum(pred==1&true_label==1);
TN = sum(pred==0&true_label==0);
FP = sum(pred==1&true_label==0);
FN = sum(pred==0&true_label==1);
acc = (TP+TN)/(TP+TN+FN+FP);
prc = TP/(TP+FP);
rec = TP/(TP+FN);

end