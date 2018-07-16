#!/usr/bin/python
# -*- coding: utf-8 -*-
import time
import sys
import os
import shutil
import subprocess

# *** START USER EDITABLE VARIABLES ***
EXPT_NAME = "temporal"
DATA_DIR = "~/data/"
USER = "jds2270"
EMAIL = "jds2270@columbia.edu"
# *** END USER EDITABLE VARIABLES ***


MODEL_TYPE = "loopy"
TRAIN_TEMPLATE_FOLDER_NAME = "{}_template".format(EXPT_NAME)
#SHUFFLE_TEMPLATE_FOLDER_NAME = # TODO


def check_templates():
    """Make template folders from master templates if they do not exist already
    """
    # Check train
    if not os.path.exists(TRAIN_TEMPLATE_FOLDER_NAME):
        shutil.copytree("temporal_template", TRAIN_TEMPLATE_FOLDER_NAME)

    # TODO: Check stuffle


def setup_train_working_dir(condition_names):
    for condition in condition_names:
        data_file = "{}_{}".format(EXPT_NAME, condition)
        experiment = "{}_{}_{}".format(EXPT_NAME, condition, MODEL_TYPE)
        print("Copying {} to {}".format(TRAIN_TEMPLATE_FOLDER_NAME, experiment))
        shutil.copytree(TRAIN_TEMPLATE_FOLDER_NAME, experiment)

        with open("{}{}write_configs_for_loopy.m".format(experiment, os.sep), 'w') as f:
            f.write("create_config_files( ...\n")
            f.write("    'experiment_name', '{}', ...\n".format(experiment))
            f.write("    'email_for_notifications', '{}', ...\n".format(EMAIL))
            f.write("    'yeti_user', '{}', ...\n".format(USER))
            f.write("    'compute_true_logZ', false, ...\n")
            f.write("    'reweight_denominator', 'mean_degree', ...\n")
            f.write("    's_lambda_splits', 6, ...\n")
            f.write("    's_lambdas_per_split', 1, ...\n")
            f.write("    's_lambda_min', 2e-03, ...\n")
            f.write("    's_lambda_max', 5e-01, ...\n")
            f.write("    'density_splits', 1, ...\n")
            f.write("    'densities_per_split', 6, ...\n")
            f.write("    'density_min', 0.1, ...\n")
            f.write("    'density_max', 0.3, ...\n")
            f.write("    'p_lambda_splits', 5, ...\n")
            f.write("    'p_lambdas_per_split', 1, ...\n")
            f.write("    'p_lambda_min', 1e+01, ...\n")
            f.write("    'p_lambda_max', 1e+04, ...\n")
            f.write("    'time_span', 2);\n")
        f.closed
        print("done writing write_configs_for_loopy.m\n")

        # print("file: get_real_data.m\n")
        # with open("{}{}get_real_data.m".format(experiment, os.sep), 'w') as f:
        #     f.write("function [data,variable_names, stimuli] = get_real_data()\n")
        #     f.write("load(['".$DATA_DIR."' ...\n")
        #     f.write("          '".$DATA_FILE.".mat']);\n")
        #     f.write("fprintf('Loaded: %s\\n', ['".$DATA_DIR."' ...\n".
        #         "'".$DATA_FILE.".mat']);\n")
        #     f.write("%data is time_frames by number_of_neurons\n")
        #     f.write("data = full(data);\n")
        #     f.write("N = size(data,2);\n")
        #     f.write("fprintf('data is : %d, %d\\n', size(data,1), size(data,2));\n")
        #     f.write("variable_names = {};\n")
        #     f.write("for i = 1:N\n")
        #     f.write("\tvariable_names(end+1) = {int2str(i)};\n")
        #     f.write("end\n")
        #     f.write("if exist('stimuli', 'var') == 1\n")
        #     f.write("    stimuli = full(stimuli);\n")
        #     f.write("    fprintf('stimuli is : %d, %d\\n', size(stimuli,1), size(stimuli,2));\n")
        #     f.write("else\n")
        #     f.write("    stimuli = [];\n")
        #     f.write("end\n")
        #     f.write("end\n")
        # f.closed
        # print "done writing get_real_data.m\n";

        curr_dir = os.curdir()
        print("curr_dir = {}.\n".format(curr_dir))
        os.chdir(experiment)
        print("changed into dir: {}\n".format(os.curdir()))
        scommand = "matlab -nodesktop -nodisplay -r \"try, write_configs_for_{}, catch, end, exit\"".format(MODEL_TYPE)
        print("About to run:\n{}\n".format(scommand))
        # system($scommand);
        # print "Done running system command\n";
        # chdir($curr_dir);
        # print "changed into dir: ".cwd()."\n";


if __name__ == '__main__':
    start_time = time.time()
    conditions = sys.argv[1:]
    if conditions:
        check_templates()
        setup_train_working_dir(conditions)
    else:
        raise TypeError("At least one condition name must be passed on the command line.\n")

    print("Total run time: {0:.2f} seconds".format(time.time() - start_time))
