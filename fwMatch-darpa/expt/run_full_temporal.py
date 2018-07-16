#!/usr/bin/python
# -*- coding: utf-8 -*-
import time
import sys
import os
import shutil
import subprocess

EXPT_NAME = "temporal"
DATA_DIR = "~/data/"
USER = "jds2270"
EMAIL = "jds2270@columbia.edu"

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


def setup_train(condition_names):
    for name in condition_names:
        data_file = "{}_{}".format(EXPT_NAME, name)
        experiment = "{}_{}_{}".format(EXPT_NAME, name, MODEL_TYPE)
        os.mkdir(experiment)




if __name__ == '__main__':
    start_time = time.time()
    conditions = sys.argv[1:]
    if conditions:
        check_templates()
        setup_train(conditions)
    else
        raise TypeError("At least one condition name must be passed on the command line.\n")

    print("Total run time: {0:.2f} seconds".format(time.time() - start_time))
