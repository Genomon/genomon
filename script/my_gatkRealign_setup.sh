#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

GENREF=$1
GATK=$2
JAVA=$3
TMP=$4
SCRIPTDIR=$5

source ${SCRIPTDIR}/utility.sh


echo Realign reads around target intervals
${JAVA} -Xms12g -Xmx12g -Djava.io.tmpdir=${TMP} -jar ${GATK}/GenomeAnalysisTK.jar \
  -T IndelRealigner \
  -targetIntervals ../install/gatksetup/1.interval_list \
  -R ${GENREF} \
  -I ../install/gatksetup/ga.bam \
  -o ../install/gatksetup/realigned.bam \
  -compress 0 \
  -baq OFF
check_error $?


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
