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
parser.add_option("-i", action="store", type="string", dest="interval", default='interval_list_hg19_nongap')

(options, args) = parser.parse_args()
JOBSELECT = options.jobsel
INTERVAL = dir['db'] + '/' + options.interval

USER = userinfo['name']
util = utility(USER) 

SAMPLE  = args[0]
RUNDATE = args[1]

TYPES = []
TYPES.append(args[2])
if (len(args) > 3):
  TYPES.append(args[3])
if (len(args) > 4 and args[4] != ''):
  TYPES.append(args[4])

LOGDIR= dir['log'] +'/'+ SAMPLE +'_'+ RUNDATE
util.check_mkdir(LOGDIR)

qsub = ['qsub']
if (JOBSELECT == 's'):
    qsub.extend(['-l', 'sjob'])
elif (JOBSELECT == "l"):
    qsub.extend(['-l', 'ljob'])
qsub.extend(['-e', LOGDIR, '-o', LOGDIR])

sysWorkDir    = dir['sys']    + '/' + SAMPLE + '/' + RUNDATE
outputWorkDir = dir['output'] + '/' + SAMPLE + '/' + RUNDATE

##################### make directory start ###############################

util.check_mkdir(outputWorkDir + '/map_bwa/merge')
util.check_mkdir(outputWorkDir + '/realign_gatk')
util.check_mkdir(outputWorkDir + '/realign_gatk/merge')
util.check_mkdir(outputWorkDir + '/realign_gatk/merge/tmp')
for type in TYPES:
    util.check_mkdir(outputWorkDir + '/realign_gatk/'+ type)
    util.check_mkdir(outputWorkDir + '/realign_gatk/'+ type +'/tmp')

##################### make directory end ###############################

BAIT_NUM = util.checkFileNum(INTERVAL)


# realign  
##########################
jobIDs = []
for type in TYPES:
  inputbam  = outputWorkDir + '/map_bwa/'+ type +'/ga.bam'
  outputdir = outputWorkDir + '/realign_gatk/'+ type +'/tmp'
  for NUM in range(1, BAIT_NUM + 1):
    intervallist = INTERVAL +'/'+ str(NUM) + '.interval_list'
    region = util.get_interval_region(intervallist)
    cmd = ['-l' ,'s_vmem=12G,mem_req=12', \
    dir['script'] + '/my_gatkRealign.sh', \
    inputbam, \
    outputdir, \
    INTERVAL, \
    str(NUM), \
    region, \
    data['hg19fasta'], \
    bin['gatk'], \
    bin['java6'], \
    dir['tmp'], \
    dir['script'], \
    bin['samtools'], \
    bin['picard']]
    jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('gatk realign',jobIDs)


# merge realigned bam
##########################
jobIDs = []
for type in TYPES:
    inputdir  = outputWorkDir + '/realign_gatk/'+ type +'/tmp'
    outputdir = outputWorkDir + '/realign_gatk/'+ type 
    cmd = ['-l' ,'s_vmem=16G,mem_req=16', \
    dir['script'] + '/my_mergeRealignedBam.sh', \
    inputdir, \
    outputdir, \
    str(BAIT_NUM), \
    bin['picard'], \
    bin['java6'], \
    dir['tmp'], \
    dir['script']]
    jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('merge realigned bam',jobIDs)


# clean up merge aligned bam 
##########################
for type in TYPES:
    inputdir  = outputWorkDir + '/realign_gatk/'+ type +'/tmp'
    cmd = [dir['script'] + '/rm.sh' , \
    inputdir]
    jobIDs.append(util.qsub_cmd(cmd,qsub))

util.syncbarrier('Cleaning up tmp directory',jobIDs)


