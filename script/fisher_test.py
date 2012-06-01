#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

import os
import subprocess
import time
import glob
import sys
from optparse import OptionParser
from command_utility import utility
from config_utility import conf_utility

conf = conf_utility() 
dir = conf.getDirectoryPath()
data = conf.getDataFilePath()
bin = conf.getBinFilePath()
db = conf.getDB()
userinfo = conf.getUserInfo()

# args
##############################################
parser = OptionParser()
parser.add_option("-j", "--job", action="store", type="string", dest="jobsel", default='m')
parser.add_option("-m", "--mapqual", action="store", type="string", dest="mapqual", default='30')
parser.add_option("-b", "--basequal", action="store", type="string", dest="basequal", default='15')
parser.add_option("-i", "--interval", action="store", type="string", dest="interval", default='interval_list_hg19_nongap')
parser.add_option("-x", "--maxindel", action="store", type="string", dest="maxindel", default='2')
parser.add_option("-f", "--bamname", action="store", type="string", dest="bamfile", default='realigned.bam')
parser.add_option("-g", "--bamdir", action="store", type="string", dest="bamdir", default='realign_gatk')
parser.add_option("-t", "--targetdir", action="store", type="string", dest="targetdir", default='merge')

(options, args) = parser.parse_args()

JOBSELECT = options.jobsel
MAP_QUAL_THRES = options.mapqual
BASE_QUAL_THRES = options.basequal
INTERVAL = dir['db'] + '/' + options.interval
MAX_INDEL = options.maxindel
BAM_FILE = options.bamfile
BAM_DIR = options.bamdir
TARGET_DIR = options.targetdir

USER = userinfo['name']
util = utility(USER) 

SAMPLE  = args[0]
RUNDATE = args[1]
TYPES = []
TYPES.append(args[2])
if (len(args) >= 4):
  TYPES.append(args[3])
if (len(args) == 5):
  TYPES.append(args[4])

# args check
# if (len(args) != 4 and len(args) != 5):
#    print "len(args) is fault"
#    sys.exit()

LOGDIR= dir['log'] +'/'+ SAMPLE +'_'+ RUNDATE
util.check_mkdir(LOGDIR)

qsub = ['qsub']
if (JOBSELECT == 's'):
    qsub.extend(['-l', 'sjob'])
elif (JOBSELECT == "l"):
    qsub.extend(['-l', 'ljob'])
qsub.extend(['-e', LOGDIR, '-o', LOGDIR])

mergeDir   = dir['output'] + '/' + SAMPLE +'/'+ TARGET_DIR +'/'+ BAM_DIR 
psampleDir = dir['result'] + '/' + SAMPLE +'_'+ RUNDATE
fisherDir  = dir['result'] + '/' + SAMPLE +'_'+ RUNDATE + '/fisher_test'
ftmpDir    = fisherDir + '/tmp'

##################### main start #############################

# check files
##########################
util.check_mkdir(psampleDir)
util.check_mkdir(fisherDir)
util.check_mkdir(ftmpDir)

for type in TYPES:
    inputbamDir = mergeDir +'/'+ type
    if not ( os.path.isdir(inputbamDir)):
        print inputbamDir + ' is not found \n'
        sys.exit()
    inputbamFile = inputbamDir + '/' + BAM_FILE
    if not ( os.path.exists(inputbamFile)):
        print inputbamFile + ' is not found \n'
        sys.exit()

if not ( os.path.isdir(INTERVAL)):
    print INTERVAL + ' is not found \n'
    sys.exit()

BAIT_NUM = util.checkFileNum(INTERVAL)


# bam2 fisher
##########################
jobIDs = []
for type in TYPES:
    for NUM in range(1, BAIT_NUM + 1):
        inputbamFile = mergeDir +'/'+ type +'/'+ BAM_FILE
        intervallist = INTERVAL +'/'+ str(NUM) + '.interval_list'
        region = util.get_interval_region(intervallist)
        cmd = ['-l', 's_vmem=4G,mem_req=4', \
        dir['script']+ '/bam2fisher_variant.sh', \
        inputbamFile, \
        fisherDir, \
        str(NUM), \
        region, \
        type, \
        MAP_QUAL_THRES, \
        BASE_QUAL_THRES, \
        INTERVAL, \
        MAX_INDEL, \
        data['hg19fasta'], \
        dir['script'], \
        bin['samtools'], \
        bin['R']]
        jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('Extracting putative mutation sites',jobIDs)


# fisher diff
##########################
jobIDs = []
for type in TYPES[1:]:
    for NUM in range(1, BAIT_NUM + 1):
        intervallist = INTERVAL +'/'+ str(NUM) + '.interval_list'
        region = util.get_interval_region(intervallist)
        cmd = ['-l', 's_vmem=4G,mem_req=4', \
        dir['script']+ '/bam2fisher_diff.sh', \
        fisherDir, \
        type, \
        TYPES[0], \
        str(NUM), \
        region, \
        dir['script'], \
        bin['R']]
        jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('Extracting diff mutation tites',jobIDs)


# merge anno file
##########################
jobIDs = []
for type in TYPES:
    cmd = [dir['script'] + '/my_mergeAnnovar.sh', \
    fisherDir, \
    type, \
    str(BAIT_NUM)]
    jobIDs.append(util.qsub_cmd(cmd,qsub))

for type in TYPES[1:]:
    cmd = [dir['script'] + '/my_mergeAnnovardiff.sh', \
    fisherDir, \
    type, \
    TYPES[0], \
    str(BAIT_NUM)]
    jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('Extracting merge annovar file ',jobIDs)


# annovar 
##########################
jobIDs = []
if (len(TYPES) == 1):
    cmd = ['-l', 's_vmem=8G,mem_req=8', \
    dir['script'] + '/my_annovar.sh', \
    SAMPLE +'_'+ RUNDATE, \
    TYPES[0], \
    '---', \
    fisherDir, \
    bin['annovar'], \
    dir['script'], \
    dir['tmp'], \
    bin['python2.6']]
    jobIDs.append(util.qsub_cmd(cmd,qsub))

for type in TYPES[1:]:
    cmd = ['-l', 's_vmem=8G,mem_req=8', \
    dir['script'] + '/my_annovar.sh', \
    SAMPLE +'_'+ RUNDATE, \
    type, \
    TYPES[0], \
    fisherDir, \
    bin['annovar'], \
    dir['script'], \
    dir['tmp'], \
    bin['python2.6']]
    jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('Adding annotations to the result',jobIDs)

# clean up tmp file 
##########################
jobIDs = []
cmd = [dir['script'] + '/rm.sh' , \
fisherDir + '/tmp']
jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('Cleaning up',jobIDs)

