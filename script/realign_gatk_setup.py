#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

import os
import subprocess
import time
import glob
import sys
import ConfigParser
import re
import shutil
from optparse import OptionParser
from command_utility import utility
from config_utility import conf_utility


conf = conf_utility() 
dir = conf.getDirectoryPath()
data = conf.getDataFilePath()
adapter = conf.getAdapterPath()
bin = conf.getBinFilePath()
userinfo = conf.getUserInfo()

# args
##############
USER = userinfo['name']
util = utility(USER) 

LOGDIR= dir['log']
util.check_mkdir(LOGDIR)

qsub = ['qsub']
qsub.extend(['-e', LOGDIR, '-o', LOGDIR])

# INTERVAL = dir['db'] + '/' + options.interval
# BAIT_NUM = util.checkFileNum(INTERVAL)

# realign  
##########################
jobIDs = []
cmd = ['-l' ,'s_vmem=16G,mem_req=16', \
dir['script'] + '/my_gatkRealign_setup.sh', \
data['hg19fasta'], \
bin['gatk'], \
bin['java6'], \
dir['tmp'], \
dir['script']]
jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('gatk realign',jobIDs)

