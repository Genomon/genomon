#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

#!/bin/bash
#$ -S /bin/bash
#$ -cwd

INPUTBAM=$1
TARGETDIR=$2
TYPE=$3
BAIT=$4
SAMTOOLS=$5
BEDTOOLS=$6
SCRIPTDIR=$7
CN_SCRIPTDIR=$8

source ${SCRIPTDIR}/utility.sh

sh ${SCRIPTDIR}/sleep.sh

echo "${BEDTOOLS}/mergeBed -i ${BAIT} > ${TARGETDIR}/${TYPE}.bait.bed"
${BEDTOOLS}/mergeBed -i ${BAIT} > ${TARGETDIR}/${TYPE}.bait.bed
check_error $?

# remove duplicate reads
echo "${SAMTOOLS} view -F 1024 -b ${INPUTBAM} > ${TARGETDIR}/${TYPE}.tmp.bam"
${SAMTOOLS} view -F 1024 -b ${INPUTBAM} > ${TARGETDIR}/${TYPE}.tmp.bam
check_error $?

# generate coverage infomation using Bedtools
echo "${BEDTOOLS}/coverageBed -abam ${TARGETDIR}/${TYPE}.tmp.bam -b ${TARGETDIR}/${TYPE}.bait.bed -d > ${TARGETDIR}/${TYPE}.coverage"
${BEDTOOLS}/coverageBed -abam ${TARGETDIR}/${TYPE}.tmp.bam -b ${TARGETDIR}/${TYPE}.bait.bed -d > ${TARGETDIR}/${TYPE}.coverage
check_error $?

# count the sum of depth for each bait
echo "perl ${CN_SCRIPTDIR}/procCoverage.pl ${TARGETDIR}/${TYPE}.coverage > ${TARGETDIR}/${TYPE}.count"
perl ${CN_SCRIPTDIR}/procCoverage.pl ${TARGETDIR}/${TYPE}.coverage > ${TARGETDIR}/${TYPE}.count
check_error $?

echo "rm ${TARGETDIR}/${TYPE}.bait.bed"
rm ${TARGETDIR}/${TYPE}.bait.bed
check_error $?

echo "rm ${TARGETDIR}/${TYPE}.tmp.bam"
rm ${TARGETDIR}/${TYPE}.tmp.bam
check_error $?

echo "rm ${TARGETDIR}/${TYPE}.coverage"
rm ${TARGETDIR}/${TYPE}.coverage
check_error $?

