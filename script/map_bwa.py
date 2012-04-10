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
parser.add_option("-s", action="store_true", dest="sanger", default=False)
parser.add_option("-a", action="store_true", dest="adapter", default=False)

(options, args) = parser.parse_args()
JOBSELECT = options.jobsel
SANGERFLG = options.sanger
ADAPTERFLG = options.adapter

USER = userinfo['name']
util = utility(USER) 

SAMPLE  = args[0]
RUNDATE = args[1]
BAIT = args[2]

LOGDIR= dir['log'] + '/' + SAMPLE +'_'+ RUNDATE 
util.check_mkdir(LOGDIR)

qsub = ['qsub']
if (JOBSELECT == 's'):
    qsub.extend(['-l', 'sjob'])
elif (JOBSELECT == "l"):
    qsub.extend(['-l', 'ljob'])
qsub.extend(['-e', LOGDIR, '-o', LOGDIR])

casavacode = '2'
if SANGERFLG:
    casavacode = '1'

sysWorkDir    = dir['sys']    + '/' + SAMPLE + '/' + RUNDATE
inputWorkDir  = dir['input']  + '/' + SAMPLE + '/' + RUNDATE
outputWorkDir = dir['output'] + '/' + SAMPLE + '/' + RUNDATE
mergeDir      = dir['output'] + '/' + SAMPLE + '/merge' 

##################### make directory start ###############################

# check input folder 
typeInputDirs = os.listdir(inputWorkDir)
if (len(typeInputDirs) <= 0):
    print 'There is no sub directory in input dir :', inputWorkDir
    sys.exit()

# make folder
util.check_mkdir(dir['sys']    + '/' + SAMPLE)
util.check_mkdir(dir['sys']    + '/' + SAMPLE + '/' + RUNDATE)
util.check_mkdir(dir['output'] + '/' + SAMPLE)
util.check_mkdir(dir['output'] + '/' + SAMPLE + '/' + RUNDATE)
util.check_mkdir(dir['output'] + '/' + SAMPLE + '/' + RUNDATE + '/map_bwa')
util.check_mkdir(dir['output'] + '/' + SAMPLE + '/' + RUNDATE + '/summary')
util.check_mkdir(dir['output'] + '/' + SAMPLE + '/merge'  )
util.check_mkdir(dir['output'] + '/' + SAMPLE + '/merge/map_bwa'  )

if os.path.exists(sysWorkDir + '/fixnfo.txt'):
    os.remove(sysWorkDir + '/fixnfo.txt')

for typeDir in typeInputDirs:
    util.check_mkdir(outputWorkDir + '/map_bwa/' + typeDir)
    util.check_mkdir(outputWorkDir + '/summary/' + typeDir)
    util.check_mkdir(mergeDir      + '/'         + typeDir)

    util.make_fixnfo_file(sysWorkDir+'/fixnfo.txt', inputWorkDir+'/'+typeDir, typeDir) 

fixnfoLines = util.get_fixnfo_file_data(sysWorkDir + '/fixnfo.txt')
if (len(fixnfoLines) <= 0):
    print 'There is no data in fixnfoLines : ' + inputWorkDir + '/' + typeDir 
else:
    print fixnfoLines

for line in fixnfoLines:
    lineArr  = line.split(':')
    type  = lineArr[0]
    lanef = lineArr[1]
    util.check_mkdir(outputWorkDir + '/map_bwa/' + type + '/' + lanef)
    util.check_mkdir(outputWorkDir + '/summary/' + type + '/' + lanef)
    util.check_mkdir(outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/tmp')
    util.check_mkdir(outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/split')
    util.check_mkdir(outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/tmpsam')
    util.check_mkdir(outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/sam')
    util.check_mkdir(outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/adapter')
    util.check_mkdir(outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/adapter/tmp')
    util.check_mkdir(outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/sanger')


##################### make directory end ###############################

for line in fixnfoLines:
    lineArr = line.split(':')
    type  = lineArr[0]
    lanef = lineArr[1] 
    targetDir = inputWorkDir + '/' + type
    # check input folder 
    typeInputDirs = os.listdir(targetDir)
    if (len(typeInputDirs) <= 0):
        print 'There is no sub directory in input work dir :', targetDir
        sys.exit()


# Converting sequence texts to Sanger format
############################################
if SANGERFLG:
    jobIDs = []
    for line in fixnfoLines:
        lineArr = line.split(':')
        type  = lineArr[0]
        lanef = lineArr[1] 
        inputDir  = inputWorkDir  + '/' + type + '/' + lanef
        sangerDir = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/sanger' 
        absfastfiles = glob.glob(inputDir + '/*.fastq')

        for absfastfile in absfastfiles:
            fastfile = absfastfile.replace(inputDir + '/', '') 
            cmd = ['-l' ,'s_vmem=2G,mem_req=2', \
                dir['script'] + '/maq_sol2sanger.sh', \
                absfastfile, \
                sangerDir + '/' + fastfile, \
                bin['maq'], \
                dir['script']]
            jobIDs.append(util.qsub_cmd(cmd,qsub))

    util.syncbarrier('Converting sequence texts to Sanger format',jobIDs)


# split
#####################
splitfactor = str(16000000)
splitsuffix = str(3)
jobIDs = []
for line in fixnfoLines:
    lineArr = line.split(':')
    type  = lineArr[0]
    lanef = lineArr[1]

    inputDir  = inputWorkDir  + '/' + type + '/' + lanef
    if SANGERFLG:
        inputDir = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/sanger' 
    outputDir = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/split'

    absfastfiles = glob.glob(inputDir + '/*.fastq')
    for absfastfile in absfastfiles:
        fastfile = absfastfile.replace(inputDir + '/', '') 
        cmd = [dir['script'] + '/split.sh', \
            splitfactor, \
            splitsuffix, \
            absfastfile, \
            outputDir, \
            fastfile + '_']

        jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('Splitting fasta files',jobIDs)


# Removing adaptor Sequences
################################
if ADAPTERFLG:
    jobIDs = []
    for line in fixnfoLines:
        lineArr = line.split(':')
        type  = lineArr[0]
        lanef = lineArr[1]

        inputDir  = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/split' 
        outputDir = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/adapter'
        tmpOutputDir = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/adapter/tmp'

        absfastqfileR1s = glob.glob(inputDir + '/*_R1_*')
        for absfastqfileR1 in absfastqfileR1s:
            fastqfile = absfastqfileR1.replace(inputDir + '/', '')
            cmd = ['-l' ,'s_vmem=2G,mem_req=2', \
                dir['script'] + '/cutadapt.sh', \
                absfastqfileR1, \
                outputDir + '/' + fastqfile, \
                tmpOutputDir + '/' + fastqfile, \
                casavacode, \
                adapter['read1'], \
                bin['cutadapt'], \
                dir['script']]
            jobIDs.append(util.qsub_cmd(cmd,qsub))

        absfastqfileR2s = glob.glob(inputDir + '/*_R2_*')
        for absfastqfileR2 in absfastqfileR2s:
            fastqfile = absfastqfileR2.replace(inputDir + '/', '')
            cmd = ['-l' ,'s_vmem=2G,mem_req=2', \
                dir['script'] + '/cutadapt.sh', \
                absfastqfileR2, \
                outputDir + '/' + fastqfile, \
                tmpOutputDir + '/' + fastqfile, \
                casavacode, \
                adapter['read2'], \
                bin['cutadapt'], \
                dir['script']]
            jobIDs.append(util.qsub_cmd(cmd,qsub))

    util.syncbarrier('Removing adaptor Sequences',jobIDs)


# bwa align
#####################
jobIDs = []
for line in fixnfoLines:
    lineArr = line.split(':')
    type  = lineArr[0]
    lanef = lineArr[1] 
    inputDir  = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/split'
    if ADAPTERFLG:
        inputDir  = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/adapter'
    outputDir = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/tmp'

    absfastfiles = glob.glob(inputDir + '/*.fastq')
    for absfastfile in absfastfiles:
        fastfile = absfastfile.replace(inputDir + '/', '') 

        cmd = ['-l' ,'s_vmem=16G,mem_req=16', \
            dir['script'] + '/bwa_aln.sh', \
            inputDir   + '/' + fastfile, \
            outputDir  + '/' + fastfile + '.sai', \
            data['hg19fasta'], \
            bin['bwa'], \
            dir['script']]

        jobIDs.append(util.qsub_cmd(cmd,qsub))

util.syncbarrier('alignment sequences',jobIDs)


# bwa sampe
#####################
jobIDs = []
for line in fixnfoLines:
    lineArr = line.split(':')
    type  = lineArr[0]
    lanef = lineArr[1] 
    inputDir  = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/split'
    if ADAPTERFLG:
        inputDir  = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/adapter'
    outputDir = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/tmp'
    tmpsamDir = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/tmpsam'
    absfastfileR1s = glob.glob(inputDir + '/*_R1_*')
     
    # Need to include a way of modifying Library and Platform variables
    library = 'lib'
    platform = 'ILLUMINA'

    #
    # e.g. 
    # fastfileR1 : SAMPLE_TYPE_R1.fastq.filt
    # fastfileR2 : SAMPLE_TYPE_R2.fastq.filt
    # outputsam  : SAMPLE_TYPE.fastq.filt.sam
    # 
    for absfastfileR1 in absfastfileR1s:                           # 
        fastfileR1 = absfastfileR1.replace(inputDir + '/','')      # delete abs path 
        fastfileR2 = fastfileR1.replace('_R1_', '_R2_')            # make pair and fast file name
        outputtmp = fastfileR1.replace('_R1_', '_')                # make sam file name
        outputsam = outputtmp + '.sam'                             #
        readgroupID = RUNDATE + "." + lanef                        # make read group id

        cmd = ['-l' ,'s_vmem=16G,mem_req=16', \
            dir['script']   + '/bwa_sampe.sh' , \
            tmpsamDir + '/' + outputsam, \
            outputDir + '/' + fastfileR1 + '.sai', \
            outputDir + '/' + fastfileR2 + '.sai', \
            inputDir  + '/' + fastfileR1, \
            inputDir  + '/' + fastfileR2, \
            data['hg19fasta'] , \
            readgroupID , \
            library, \
            platform, \
            SAMPLE, \
            bin['bwa'], \
            dir['script'] ]

        jobIDs.append(util.qsub_cmd(cmd,qsub))

util.syncbarrier('Joining paired end sequences',jobIDs)


# sam join
#####################
jobIDs = []
for line in fixnfoLines:
    lineArr = line.split(':')
    type  = lineArr[0]
    lanef = lineArr[1] 
    inputDir   = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/tmpsam'
    outputDir  = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/sam'

    cmd = ['-l' ,'s_vmem=2G,mem_req=2', \
        dir['script'] + '/sam_join.sh', \
        inputDir, \
        outputDir, \
        dir['script'], \
        bin['python2.6']]
    jobIDs.append(util.qsub_cmd(cmd,qsub))
    
util.syncbarrier('Assembling paired end sequences',jobIDs)


# sam 2 org bam 
#####################
# -input- 
# samfile      : ga.sam
# -output-
# bamtemp      : ga.bam.tmp
# bamsorted    : ga.bam.sorted
# bamdedup     : ga.bam.dedup
# bam          : ga.bam
# metrics      : ga.metrics
jobIDs = []
for line in fixnfoLines:
    lineArr = line.split(':')
    type  = lineArr[0]
    lanef = lineArr[1] 
    samDir     = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/sam'
    bamDir     = outputWorkDir + '/map_bwa/' + type + '/' + lanef
    metricsDir = outputWorkDir + '/summary/' + type + '/' + lanef
    
    abssamfiles = glob.glob(samDir + '/ga.sam')
    if (len(abssamfiles) == 1):
        abssamfile = abssamfiles[0]
        bamtmp    = abssamfile.replace('.sam','.bam.tmp')
        bamsorted = abssamfile.replace('.sam','.bam.sorted')

        cmd = ['-l' ,'s_vmem=16G,mem_req=16',\
        dir['script'] + '/sam2orgbam.sh', \
        abssamfile, \
        bamtmp, \
        bamsorted, \
        bamDir + '/ga.bam', \
        metricsDir + '/ga.metrics', \
        bin['picard'], \
        bin['java6'], \
        dir['tmp'], \
        dir['script']]

        jobIDs.append(util.qsub_cmd(cmd,qsub))
    else:
        print "Error : there are many sam files in output folder"
        
util.syncbarrier('Converting SAM to BAM.\nSorting BAM.\nMakring duplicate reads.\n',jobIDs)


# check bam line size 
#####################
jobIDs = []
for line in fixnfoLines:
    lineArr = line.split(':')
    type  = lineArr[0]
    lanef = lineArr[1] 
    bamfile = outputWorkDir + '/map_bwa/' + type + '/' + lanef + '/ga.bam'
    
    inputDir  = inputWorkDir  + '/' + type + '/' + lanef
    absfastfiles = glob.glob(inputDir + '/*_R1.fastq')

    for absfastfile in absfastfiles:
        cmd = [dir['script'] + '/checkLineSizeAlignmentBam.sh', \
            absfastfile, \
            bamfile, \
            bin['samtools'], \
            dir['script']]
        jobIDs.append(util.qsub_cmd(cmd,qsub))

util.syncbarrier('check bam line size.\n',jobIDs)


# merge alignment bam 
#####################
jobIDs = []
tmpTypeArr = []
typeArr = []
for line in fixnfoLines:
    lineArr = line.split(':')
    tmpTypeArr.append(lineArr[0])
typeArr = list(set(tmpTypeArr))

for typeMain in typeArr:
    strLanesTmp = ""
    for line in fixnfoLines:
        lineArr = line.split(':')
        type  = lineArr[0]
        lanef = lineArr[1] 

        if(typeMain == type):
            strLanesTmp = strLanesTmp + ' ' + lanef

    strLanes  = strLanesTmp.lstrip()
    outputDir = outputWorkDir + '/map_bwa/' + typeMain 

    cmd = ['-l' ,'s_vmem=16G,mem_req=16', \
        dir['script'] + '/my_mergeAlignmentBam.sh', \
        outputDir, \
        strLanes, \
        bin['picard'], \
        bin['java6'], \
        dir['tmp'], \
        dir['script']]

    jobIDs.append(util.qsub_cmd(cmd,qsub))
util.syncbarrier('Merging alignment Bam Files',jobIDs)


# bam 2 summary 
#####################
jobIDs = []
tmpTypeArr = []
typeArr = []
for line in fixnfoLines:
    lineArr = line.split(':')
    type  = lineArr[0]
    tmpTypeArr.append(lineArr[0])
    lanef = lineArr[1] 
    bamDir     = outputWorkDir + '/map_bwa/' + type + '/' + lanef
    summaryDir = outputWorkDir + '/summary/' + type + '/' + lanef   
 
    cmd = ['-l' ,'s_vmem=8G,mem_req=8', \
        dir['script'] + '/bam2summary.sh', \
        bamDir, \
        summaryDir, \
        dir['db'], \
        BAIT, \
        data['hg19fasta'], \
        bin['picard'], \
        bin['java6'], \
        dir['tmp'], \
        dir['script']]

    jobIDs.append(util.qsub_cmd(cmd,qsub))

typeArr = list(set(tmpTypeArr))
for type in typeArr:
    bamDir     = outputWorkDir + '/map_bwa/' + type 
    summaryDir = outputWorkDir + '/summary/' + type 
 
    cmd = ['-l' ,'s_vmem=8G,mem_req=8', \
        dir['script'] + '/bam2summary.sh', \
        bamDir, \
        summaryDir, \
        dir['db'], \
        BAIT, \
        data['hg19fasta'], \
        bin['picard'], \
        bin['java6'], \
        dir['tmp'], \
        dir['script']]

    jobIDs.append(util.qsub_cmd(cmd,qsub))

util.syncbarrier('Bam 2 summary',jobIDs)


# clean up tmp file
##########################
jobIDs = []
for line in fixnfoLines:
    lineArr = line.split(':')
    type  = lineArr[0]
    lanef = lineArr[1] 

    outputDir = outputWorkDir + '/map_bwa/' + type + '/' + lanef
    cmd = [dir['script'] + '/rm.sh' , \
           outputDir]
    jobIDs.append(util.qsub_cmd(cmd,qsub))

util.syncbarrier('Cleaning up',jobIDs)


# generate csv file
#########################
# jobIDs = []
# tmpTypeArr = []
# typeArr = []
# for line in fixnfoLines:
#    lineArr = line.split(':')
#    type  = lineArr[0]
#    tmpTypeArr.append(lineArr[0])
#
# typeArr = list(set(tmpTypeArr))
# for type in typeArr:
#    alignmentSummaryFile = outputWorkDir + '/summary/' + type + '/AlignmentSummaryMetrics.txt'   
#    calculateHsFile = outputWorkDir + '/summary/' + type + '/CalculateHsMetrics.txt'   
#    cmd = ['-l', 's_vmem=2G,mem_req=2', dir['script'] + '/copySummaryIntoImportDir.sh', \
#    alignmentSummaryFile, calculateHsFile, dir['summary'], SAMPLE, RUNDATE, type, '', '', '', BAIT, 'exon']
#    jobIDs.append(util.qsub_cmd(cmd,qsub))
#
# util.syncbarrier('make summary data file ',jobIDs)

