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
parser = OptionParser()
parser.add_option("-j", action="store", type="string", dest="jobsel", default='m')
parser.add_option("-f", "--bamname", action="store", type="string", dest="bamfile", default='ga.bam')
parser.add_option("-g", "--bamdir", action="store", type="string", dest="bamdir", default='map_bwa')
parser.add_option("-t", "--targetdir", action="store", type="string", dest="targetdir", default='merge')

(options, args) = parser.parse_args()
JOBSELECT = options.jobsel
BAM_FILE = options.bamfile
BAM_DIR = options.bamdir
TARGET_DIR = options.targetdir

USER = userinfo['name']
util = utility(USER) 

BAMFILES  = args[0]
SAMPLE    = args[1]
TYPE      = args[2]

LOGDIR= dir['log'] +'/'+ SAMPLE +'_'+ TARGET_DIR
util.check_mkdir(LOGDIR)

qsub = ['qsub']
if (JOBSELECT == 's'):
    qsub.extend(['-l', 'sjob'])
elif (JOBSELECT == "l"):
    qsub.extend(['-l', 'ljob'])
qsub.extend(['-e', LOGDIR, '-o', LOGDIR])

outputWorkDir = dir['output'] +'/'+ SAMPLE +'/'+ TARGET_DIR +'/'+ BAM_DIR 
outputbam     = outputWorkDir +'/'+  TYPE  +'/'+ BAM_FILE
util.check_mkdir(outputWorkDir)

##################### make directory start ###############################

util.check_mkdir(outputWorkDir)
util.check_mkdir(outputWorkDir +'/'+ TYPE)

# merge normal bam and tumor bam 
##########################
jobIDs = []
cmd = ['-l' ,'s_vmem=16G,mem_req=16', \
dir['script'] + '/mergebam.sh', \
BAMFILES, \
outputbam, \
dir['script'], \
bin['java6'], \
bin['picard'], \
dir['tmp']]
jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('merge normal and tumor bam',jobIDs)

