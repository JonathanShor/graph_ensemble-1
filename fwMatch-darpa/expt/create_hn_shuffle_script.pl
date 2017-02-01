#!/usr/bin/perl
use Cwd;
$EXPT_NAME = "m37_d2";
#@EE = ("all_high_add_neuron_100", "all_high_add_neuron_200", "all_high_add_neuron_300", "all_high_add_neuron_400", "all_high_add_neuron_500", "all_high_add_neuron_600", "all_high_add_neuron_700", "all_high_add_neuron_800", "all_high_add_neuron_900", "all_high_add_neuron_1000");
@EE = ("all_high_add_neuron_100", "all_high_add_neuron_200", "all_high_add_neuron_300", "all_high_add_neuron_400", "all_high_add_neuron_500", "all_high_add_neuron_600", "all_high_add_neuron_700");
$NUM_STIM = 2;
$MODEL_TYPE = "loopy";
$DATA_DIR = "/vega/brain/users/sh3276/data/luis";
#@DENSITY = (0.25,0.3,0.29,0.27,0.29,0.27,0.27,0.28,0.29,0.30);
#@S_LAMBDA = (0.5,0.0549,0.1657,0.0549,0.1657,0.0549,0.1657,0.1657,0.1657,0.006);
#@P_LAMBDA = (10,56.2341,56.2341,56.2341,316.2278,316.2278,316.2278,316.2278,316.2278,1.7783e+03);
@DENSITY = (0.27,0.26,0.3,0.3,0.28,0.26,0.3);
@S_LAMBDA = (0.0182,0.1657,0.1657,0.0549,0.0549,0.1657,0.1657);
@P_LAMBDA = (56.2341,56.2341,56.2341,316.2278,316.2278,316.2278,316.2278);
$NSHUFFLE = 100;

for( $i = 0; $i <= $#EE; $i++){
    
    # create experiment directory
    $EXPERIMENT = sprintf("shuffled_%s_%s_%s", $EXPT_NAME, $EE[$i], $MODEL_TYPE);
    mkdir($EXPERIMENT);
    $scommand = sprintf("cp shuffled_%s_template/* %s/", $EXPT_NAME, $EXPERIMENT);
    print "Running: ".$scommand."\n";
    ($status, $result) = system($scommand);

    $DATA_FILE = sprintf("%s_%s",$EXPT_NAME,$EE[$i]);
    $SAVE_DIR = sprintf("%s/shuffled/%s",$DATA_DIR,$EXPERIMENT);
    $SAVE_NAME = sprintf("shuffled_%s_%s", $EXPT_NAME, $EE[$i]);

    # make shuffled data directory
    $scommand = sprintf("mkdir %s", $SAVE_DIR);
    print "Running: ".$scommand."\n";
    ($status, $result) = system($scommand);

    # script for reading data
    print "file: get_real_data.m\n";
    open(my $FID, ">", "$EXPERIMENT/get_real_data.m") 
	or die "cannot open < $!";
    print $FID "function [data,variable_names] = get_real_data(id)\n";
    print $FID "load(['".$SAVE_DIR."/".$SAVE_NAME."_' num2str(id) '.mat']);\n";
    print $FID "fprintf('Loaded: %s/%s_%d.mat\\n', '".$SAVE_DIR."','".$SAVE_NAME."',id);\n";
    print $FID "%data is time_frames by number_of_neurons\n";
    print $FID "data = full(data);\n";
    print $FID "N = size(data,2);\n";
    print $FID "variable_names = {};\n";
    print $FID "for i = 1:N\n";
    print $FID "\tvariable_names(end+1) = {int2str(i)};\n";
    print $FID "end\n";
    print $FID "fprintf('data is : %d, %d\\n', size(data,1), size(data,2));\n";
    print $FID "end\n";
    close($FID);
    
    print "done writing get_real_data.m\n";

    # script for generate shuffled data
    print "file: gn_shuff_data.m\n";
    open(my $FID, ">", "$EXPERIMENT/gn_shuff_data.m")
        or die "cannot open < $!";
    print $FID "addpath(genpath('/vega/brain/users/sh3276/src/'));\n";
    print $FID "load(['".$DATA_DIR."/".$DATA_FILE.".mat']);\n";
    print $FID "fprintf('Loaded: %s\\n', ['".$DATA_DIR."/".$DATA_FILE.".mat']);\n";
    print $FID "num_node = size(data,2);\n";
    print $FID "num_stim = ".$NUM_STIM.";\n";
    print $FID "data_raw = data;\n";
    print $FID "for i = 1:".$NSHUFFLE."\n";
    print $FID "\tdata = zeros(size(data_raw));\n";
    print $FID "\tdata(:,1:num_node-num_stim) = shuffle(data_raw(:,1:num_node-num_stim)','exchange')';\n";
    print $FID "\tdata(:,num_node-num_stim+1:num_node) = data_raw(:,num_node-num_stim+1:num_node);\n";
    print $FID "\tsave(['".$SAVE_DIR."/".$SAVE_NAME."_' num2str(i) '.mat'],'data');\n";
    print $FID "end\n";
    print $FID "fprintf('done shuffling data\\n');\n";
    close($FID);

    print "done writing gn_shuff_data.m\n";

    if($MODEL_TYPE eq "loopy"){
    open(my $FID, ">", "$EXPERIMENT/write_configs_for_loopy.m") 
	or die "cannot open < $!";    
    print $FID "create_config_files( ...\n";
    print $FID "    'experiment_name', '".$EXPERIMENT."', ...\n";
    print $FID "    'email_for_notifications', 'sh3276\@columbia.edu', ...\n";
    print $FID "    'yeti_user', 'sh3276', ...\n";
    print $FID "    'compute_true_logZ', false, ...\n";
    print $FID "    'reweight_denominator', 'mean_degree', ...\n";
    print $FID "    's_lambda_splits', 1, ...\n";
    print $FID "    's_lambdas_per_split', 1, ...\n";
    print $FID "    's_lambda_min', ".$S_LAMBDA[$i].", ...\n";
    print $FID "    's_lambda_max', ".$S_LAMBDA[$i].", ...\n";
    print $FID "    'density_splits', 1, ...\n";
    print $FID "    'densities_per_split', 1, ...\n";
    print $FID "    'density_min', ".$DENSITY[$i].", ...\n";
    print $FID "    'density_max', ".$DENSITY[$i].", ...\n";
    print $FID "    'p_lambda_splits', 1, ...\n";
    print $FID "    'p_lambdas_per_split', 1, ...\n";
    print $FID "    'p_lambda_min', ".$P_LAMBDA[$i].", ...\n";
    print $FID "    'p_lambda_max', ".$P_LAMBDA[$i].", ...\n";
    print $FID "    'num_shuffle', ".$NSHUFFLE.");\n";
    close($FID); 
    print "done writing write_configs_for_loopy.m\n";
    }else{
	#model is tree
    open(my $FID, ">", "$EXPERIMENT/write_configs_for_tree.m") 
	or die "cannot open < $!";    
    print $FID "create_config_files( ...\n";
    print $FID "    'experiment_name', '".$EXPERIMENT."', ...\n";
    print $FID "    'email_for_notifications', 'sh3276\@columbia.edu', ...\n";
    print $FID "    'yeti_user', 'sh3276', ...\n";
    print $FID "    'structure_type', 'tree', ...\n";
    print $FID "    'compute_true_logZ', true, ...\n";
    print $FID "    'p_lambda_splits', 1, ...\n";
    print $FID "    'p_lambdas_per_split', 1, ...\n";
    print $FID "    'p_lambda_min', ".$P_LAMBDA[$i].", ...\n";
    print $FID "    'p_lambda_max', ".$P_LAMBDA[$i].");\n";
    close($FID);

    print "done writing write_configs_for_tree.m\n";
    }

    # write yeti script
    print "file: shuffle_yeti_config.sh\n";
    system(sprintf("rm %s/shuffle_yeti_config.sh",$EXPERIMENT));
    open(my $FID, ">", "$EXPERIMENT/shuffle_yeti_config.sh")
        or die "cannot open < $!";
    print $FID "#!/bin/sh\n";
    print $FID "#yeti_config.sh\n";
    print $FID "#PBS -N ".$EXPERIMENT."\n";
    print $FID "#PBS -W group_list=yetibrain\n";
    print $FID "#PBS -l nodes=1:ppn=1,walltime=02:00:00,mem=4000mb\n";
    print $FID "#PBS -V\n";
    print $FID "#set output and error directories (SSCC example here)\n";
    print $FID "#PBS -o localhost:/vega/brain/users/sh3276/src/fwMatch-darpa/expt/".$EXPERIMENT."/yeti_logs/\n";
    print $FID "#PBS -e localhost:/vega/brain/users/sh3276/src/fwMatch-darpa/expt/".$EXPERIMENT."/yeti_logs/\n";
    print $FID "#Command below is to execute Matlab code for Job Array (Example 4) so that each part writes own output\n";
    print $FID "matlab -nodesktop -nodisplay -r ".
        "\"dbclear all; addpath('/vega/brain/users/sh3276/src/fwMatch-darpa/expt/".$EXPERIMENT."');gn_shuff_data; exit\"\n";
    print $FID "#End of script\n";
    close($FID);

    # write submit script
    print "file: shuffle_start_job.sh\n";
    system(sprintf("rm %s/shuffle_start_job.sh",$EXPERIMENT));
    open(my $FID, ">", "$EXPERIMENT/shuffle_start_job.sh")
        or die "cannot open < $!";
    print $FID "qsub shuffle_yeti_config.sh\n";
    print "done writing yeti scripts\n";
    close($FID);

    $scommand = sprintf("chmod +x %s/shuffle_start_job.sh %s/shuffle_yeti_config.sh",$EXPERIMENT,$EXPERIMENT);
    ($status, $result) = system($scommand);


    $curr_dir = cwd();
    print "curr_dir = ".$curr_dir."\n";
    chdir($EXPERIMENT);
    print "changed into dir: ".cwd()."\n";
    $scommand = "matlab -nodesktop -nodisplay -r ".
#	"\"try, write_configs_for_".$MODEL_TYPE.", catch, end, exit\"";
      "\"write_configs_for_".$MODEL_TYPE.",exit\"";
    print "About to run:\n".$scommand."\n";
    system($scommand);
    print "Done running system command\n";
    chdir($curr_dir);
    print "changed into dir: ".cwd()."\n";
}
