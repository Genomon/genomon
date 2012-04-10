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

# make read group list 
##########################
jobIDs = []
for type in TYPES:
    inputbam  = outputWorkDir + '/map_bwa/'+ type +'/ga.bam'
    outputReadgroupList  = outputWorkDir + '/map_bwa/'+ type +'/readgroup.list'

    cmd = ['-l' ,'s_vmem=2G,mem_req=2', \
    dir['script'] + '/make_readgroup_file.sh', \
    inputbam, \
    outputReadgroupList, \
    bin['samtools'], \
    dir['script']]
    jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('make read group list',jobIDs)


# merge normal bam and tumor bam 
##########################
jobIDs = []
bamListCsvStrTmp = ''
for type in TYPES:
    bamListCsvStrTmp = bamListCsvStrTmp + outputWorkDir + '/map_bwa/'+ type +'/ga.bam' + ','
outputbam = outputWorkDir + '/map_bwa/merge/ga.bam'

lastindex = len(bamListCsvStrTmp) - 1
bamListCsvStr = bamListCsvStrTmp[0:lastindex]

cmd = ['-l' ,'s_vmem=16G,mem_req=16', \
dir['script'] + '/mergebam.sh', \
bamListCsvStr, \
outputbam, \
dir['script'], \
bin['java6'], \
bin['picard'], \
dir['tmp']]
jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('merge normal and tumor bam',jobIDs)


# realign  
##########################
jobIDs = []
inputbam  = outputWorkDir + '/map_bwa/merge/ga.bam'
outputdir = outputWorkDir + '/realign_gatk/merge/tmp'
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


# pull out tumor or normal reads from merge realigned bam 
##########################
jobIDs = []
inputdir = outputWorkDir + '/realign_gatk/merge/tmp'
for type in TYPES:
    rglist  = outputWorkDir + '/map_bwa/'+ type +'/readgroup.list'
    outputdir = outputWorkDir + '/realign_gatk/'+ type +'/tmp'
    for NUM in range(1, BAIT_NUM + 1):
        intervallist = INTERVAL +'/'+ str(NUM) + '.interval_list'
        region = util.get_interval_region(intervallist)
        cmd = ['-l' ,'s_vmem=2G,mem_req=2', \
        dir['script'] + '/pulloutRead.sh', \
        rglist, \
        inputdir, \
        outputdir, \
        str(NUM), \
        region, \
        bin['samtools'], \
        dir['script']]
        jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('pull out tumor or normal reads from merge realigned bam',jobIDs)


# convert sam to bam 
##########################
jobIDs = []
for type in TYPES:
    inoutdir = outputWorkDir + '/realign_gatk/'+ type +'/tmp'
    for NUM in range(1, BAIT_NUM + 1):
        intervallist = INTERVAL +'/'+ str(NUM) + '.interval_list'
        region = util.get_interval_region(intervallist)
        cmd = ['-l' ,'s_vmem=16G,mem_req=16', \
        dir['script'] + '/sam2orgbam_realignment.sh', \
        inoutdir, \
        str(NUM), \
        region, \
        bin['picard'], \
        bin['java6'], \
        dir['tmp'], \
        dir['script']]
        jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('convert sam to bam',jobIDs)


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
jobIDs = []
inputdir  = outputWorkDir + '/map_bwa/merge'
cmd = [dir['script'] + '/rm.sh' , \
inputdir]
jobIDs.append(util.qsub_cmd(cmd,qsub))

inputdir = outputWorkDir + '/realign_gatk/merge'
cmd = [dir['script'] + '/rm.sh' , \
inputdir]
jobIDs.append(util.qsub_cmd(cmd,qsub))

for type in TYPES:
    inputdir  = outputWorkDir + '/realign_gatk/'+ type +'/tmp'
    cmd = [dir['script'] + '/rm.sh' , \
    inputdir]
    jobIDs.append(util.qsub_cmd(cmd,qsub))

util.syncbarrier('Cleaning up tmp directory',jobIDs)


