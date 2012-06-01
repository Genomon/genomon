#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

INPUT_BAM=$1
OUTPUT_DIR=$2
INTERVAL=$3
NUM=$4
REGION=$5
GENREF=$6
GATK=$7
JAVA=$8
TMP=$9
SCRIPTDIR=${10}
SAMTOOLS=${11}
PICARD=${12}

source ${SCRIPTDIR}/utility.sh

# sleep 
sh ${SCRIPTDIR}/sleep.sh

REGION_TMP=${REGION/:/_}
REGION_FILE_NAME=${REGION_TMP/-/_}
echo ${REGION_FILE_NAME} 

echo "rm ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.bai"
rm ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.bai

echo "${SAMTOOLS} view -h -b ${INPUT_BAM} ${REGION} > ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.bam"
${SAMTOOLS} view -h -b ${INPUT_BAM} ${REGION} > ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.bam
check_error $?

echo Create bam index
${JAVA} -Xms8g -Xmx8g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/BuildBamIndex.jar \
  INPUT=${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.bam \
  VALIDATION_STRINGENCY=SILENT \
  TMP_DIR=${TMP}
check_error $?

echo Create realigner target intervals
# Create target intervals for the realigner (can operate on a per chromosome level for faster processing)
${JAVA} -Xms8g -Xmx8g -Djava.io.tmpdir=${TMP} -jar ${GATK}/GenomeAnalysisTK.jar \
  -T RealignerTargetCreator \
  -R ${GENREF} \
  -I ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.bam \
  -o ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.intervals \
  -L ${INTERVAL}/${NUM}.interval_list \
  -baq OFF
check_error $?

echo Realign reads around target intervals
# Realign reads around previously identified target intervals (can operate on a per chromosome level for faster processing or even on a per interval basis)
${JAVA} -Xms8g -Xmx8g -Djava.io.tmpdir=${TMP} -jar ${GATK}/GenomeAnalysisTK.jar \
  -T IndelRealigner \
  -R ${GENREF} \
  -I ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.bam \
  -targetIntervals ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.intervals \
  -o ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}_realigned.bam \
  -compress 0 \
  -baq OFF
check_error $?

echo Fix Mate Pair Information
# Fix mate pair information in realigned bam file
${JAVA} -Xms8g -Xmx8g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/FixMateInformation.jar \
	INPUT=${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}_realigned.bam \
	SORT_ORDER=coordinate \
	VALIDATION_STRINGENCY=LENIENT
check_error $?


echo "rm ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.bam"
rm ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.bam
check_error $?

echo "rm ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.bai"
rm ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.bai
check_error $?

echo "rm ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.intervals"
rm ${OUTPUT_DIR}/temp${NUM}.${REGION_FILE_NAME}.intervals
check_error $?


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
