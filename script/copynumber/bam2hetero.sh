#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

#!/bin/bash
#$ -S /bin/bash
#$ -cwd

INPUTBAM=$1
TARGETDIR=$2
TYPE=$3
NUM=$4
REGION=$5
GENREF=$6
SAMTOOLS=$7
SCRIPTDIR=$8
CN_SCRIPTDIR=$9

source ${SCRIPTDIR}/utility.sh

# sleep
sh ${SCRIPTDIR}/sleep.sh

REGION_TMP=${REGION/:/_}
REGION_FILE_NAME=${REGION_TMP/-/_}


# extract .bam for a diveded regions form recal.bam 
# remove reads whose mapping quality is less than 20
##########
echo "${SAMTOOLS} view -h -q 20 -b ${INPUTBAM} ${REGION} >  ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam"
${SAMTOOLS} view -h -q 20 -b ${INPUTBAM} ${REGION} >  ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam
check_error $?


# pileup diveded .bam files.
##########
echo "${SAMTOOLS} mpileup -BQ0 -d10000000 -f ${GENREF} ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam > ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup"
${SAMTOOLS} mpileup -BQ0 -d10000000 -f ${GENREF} ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam > ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup
check_error $?


# make count files for mismatches, insertions and deletions
# mismatch count is performed considering bases whose quality is more than 15.
##########
echo "perl ${CN_SCRIPTDIR}/pileup2base.pl 15 ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del"
perl ${CN_SCRIPTDIR}/pileup2base.pl 15 ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del
check_error $?


echo "rm ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam"
rm ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam
check_error $?

echo "rm ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup"
rm ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup
check_error $?

