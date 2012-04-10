#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

RECORDS_IN_RAM=5000000

DIR=$1
NUM=$2
REGION=$3
PICARD=$4
JAVA=$5
TMP=$6
SCRIPTDIR=$7

source ${SCRIPTDIR}/utility.sh

# sleep 
sh ${SCRIPTDIR}/sleep.sh

REGION_TMP=${REGION/:/_}
REGION_FILE_NAME=${REGION_TMP/-/_}
echo ${REGION_FILE_NAME} 

BAM_NAME=temp${NUM}.${REGION_FILE_NAME}_realigned.bam
SAM_NAME=temp${NUM}.${REGION_FILE_NAME}_realigned.sam
METRICS=temp${NUM}.${REGION_FILE_NAME}.metrics

echo "java SortSam.jar"
${JAVA} -Xms12g -Xmx12g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/SortSam.jar \
INPUT=${DIR}/${SAM_NAME} \
OUTPUT=${DIR}/${BAM_NAME}.sorted \
SORT_ORDER=coordinate \
VALIDATION_STRINGENCY=SILENT \
MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo "java MarkDuplicates.jar"
${JAVA} -Xms12g -Xmx12g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/MarkDuplicates.jar \
INPUT=${DIR}/${BAM_NAME}.sorted \
OUTPUT=${DIR}/${BAM_NAME} \
METRICS_FILE=${DIR}/${METRICS} \
VALIDATION_STRINGENCY=SILENT \
MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo "java BuildBamIndex.jar"
${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/BuildBamIndex.jar \
INPUT=${DIR}/${BAM_NAME} \
VALIDATION_STRINGENCY=SILENT \
MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo "rm ${DIR}/${BAM_NAME}.sorted"
rm ${DIR}/${BAM_NAME}.sorted
check_error $?

echo "rm ${DIR}/${SAM_NAME}"
rm ${DIR}/${SAM_NAME}
check_error $?

