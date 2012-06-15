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
BAIT = args[2] +'.bed'

TYPES = []
TYPES.append(args[3])
TYPES.append(args[4])
#if (len(args) > 5 and args[5] != ''):
#  TYPES.append(args[5])

# args check
# if (len(args) != 5 and len(args) != 6):
if (len(args) != 5):
    print "len(args) is fault"
    sys.exit()

LOGDIR= dir['log'] +'/'+ SAMPLE +'_'+ RUNDATE
util.check_mkdir(LOGDIR)

CN_SCRIPT_DIR = dir['script'] + '/copynumber'

qsub = ['qsub']
if (JOBSELECT == 's'):
    qsub.extend(['-l', 'sjob'])
elif (JOBSELECT == "l"):
    qsub.extend(['-l', 'ljob'])
qsub.extend(['-e', LOGDIR, '-o', LOGDIR])

outputWorkDir = dir['output'] + '/' + SAMPLE + '/' + RUNDATE

##################### make directory start ###############################

util.check_mkdir(outputWorkDir + '/copyNum')
util.check_mkdir(outputWorkDir + '/copyNum/total')
util.check_mkdir(outputWorkDir + '/copyNum/alleleSpecific')
util.check_mkdir(outputWorkDir + '/copyNum/alleleSpecific/tmp')

if not (os.path.exists(dir['db'] +'/'+ BAIT)):
    print BAIT + ' is not found \n'
    sys.exit()

##################### make directory end ###############################

BAIT_NUM = util.checkFileNum(INTERVAL)

# total depth
##########################
jobIDs = []
for type in TYPES:
    inputbam  = outputWorkDir + '/map_bwa/'+ type +'/ga.bam'
    outputdir = outputWorkDir + '/copyNum/total'

    cmd = ['-l' ,'s_vmem=8G,mem_req=8', \
    CN_SCRIPT_DIR + '/totalDepth.sh', \
    inputbam, \
    outputdir, \
    type, \
    dir['db'] +'/'+ BAIT, \
    bin['samtools'], \
    bin['bedtools'], \
    dir['script'], \
    CN_SCRIPT_DIR]
    jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('total depth',jobIDs)


# make count file for mismatches 
##########################
jobIDs = []
for type in TYPES:
    inputbam  = outputWorkDir + '/map_bwa/'+ type +'/ga.bam'
    outputdir = outputWorkDir + '/copyNum/alleleSpecific/tmp'
    
    for NUM in range(1, BAIT_NUM + 1):
        intervallist = INTERVAL +'/'+ str(NUM) + '.interval_list'
        region = util.get_interval_region(intervallist)
        cmd = ['-l' ,'s_vmem=4G,mem_req=4', \
        CN_SCRIPT_DIR + '/bam2hetero.sh', \
        inputbam, \
        outputdir, \
        type, \
        str(NUM), \
        region, \
        data['hg19fasta'], \
        bin['samtools'], \
        dir['script'], \
        CN_SCRIPT_DIR]
        jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('make count files for mismatches',jobIDs)


# filter base for copy number 
##########################
jobIDs = []
for type in TYPES[1:]:
    outputdir = outputWorkDir + '/copyNum/alleleSpecific/tmp'
    
    for NUM in range(1, BAIT_NUM + 1):
        intervallist = INTERVAL +'/'+ str(NUM) + '.interval_list'
        region = util.get_interval_region(intervallist)
        cmd = ['-l' ,'s_vmem=2G,mem_req=2', \
        CN_SCRIPT_DIR + '/filterBase_CN.sh', \
        outputdir, \
        str(NUM), \
        region, \
        TYPES[0], \
        type, \
        dir['script'], \
        CN_SCRIPT_DIR]
        jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('filter base for copy number',jobIDs)


# make as count bait file
##########################
jobIDs = []
targetdir = outputWorkDir + '/copyNum'
totaldir  = targetdir     + '/total'
alleledir = targetdir     + '/alleleSpecific'
alleletmp = alleledir     + '/tmp'
    
cmd = ['-l' ,'s_vmem=8G,mem_req=8', \
CN_SCRIPT_DIR + '/makeAsCountBait.sh', \
SAMPLE, \
TYPES[0], \
str(BAIT_NUM), \
targetdir, \
alleledir, \
alleletmp, \
totaldir, \
data['hg19fasta'], \
dir['script'], \
bin['bedtools'], \
bin['R'], \
CN_SCRIPT_DIR]
jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('make as count bait file',jobIDs)


# make shmmg 
##########################
jobIDs = []
targetdir = outputWorkDir + '/copyNum'
totaldir  = targetdir     + '/total'
    
for type in TYPES[1:]:
    cmd = ['-l' ,'s_vmem=2G,mem_req=2', \
    CN_SCRIPT_DIR + '/makeShmmg.sh', \
    SAMPLE, \
    TYPES[0], \
    type, \
    targetdir, \
    totaldir, \
    dir['script'], \
    bin['R'], \
    CN_SCRIPT_DIR]
    jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('make shmmd',jobIDs)


