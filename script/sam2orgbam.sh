#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

RECORDS_IN_RAM=5000000

SAM=$1
BAMtmp=$2
BAMsorted=$3
BAMdedup=$4
METRICS=$5
PICARD=$6
JAVA=$7
TMP=$8
SCRIPTDIR=$9

source ${SCRIPTDIR}/utility.sh

# sleep 
sh ${SCRIPTDIR}/sleep.sh

echo "java SortSam.jar"
${JAVA} -Xms12g -Xmx12g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/SortSam.jar \
INPUT=${SAM} \
OUTPUT=${BAMsorted} \
SORT_ORDER=coordinate \
VALIDATION_STRINGENCY=SILENT \
MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo "java MarkDuplicates.jar"
${JAVA} -Xms12g -Xmx12g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/MarkDuplicates.jar \
INPUT=${BAMsorted} \
OUTPUT=${BAMdedup} \
METRICS_FILE=${METRICS} \
VALIDATION_STRINGENCY=SILENT \
MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo "java BuildBamIndex.jar"
${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/BuildBamIndex.jar \
INPUT=${BAMdedup} \
VALIDATION_STRINGENCY=SILENT \
MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM} 
check_error $?

