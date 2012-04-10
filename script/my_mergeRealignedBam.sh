#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

INPUTPATH=$1
OUTPUTPATH=$2
BAIT_NUM=$3
PICARD=$4
JAVA=$5
TMP=$6
SCRIPTDIR=$7

source ${SCRIPTDIR}/utility.sh

# sleep 
sh ${SCRIPTDIR}/sleep.sh

RECORDS_IN_RAM=2500000

num=1
strfiles=""
while [ ${num} -le ${BAIT_NUM} ];
do
    file=(`ls ${INPUTPATH}/temp${num}.*_realigned.bam`)
    if [ ! -f ${file} ]; then
        echo "${file} : No such file or directory"
        exit 1
    fi
    echo $file
    strfiles="${strfiles}"" ""INPUT=${file}"
    num=`expr ${num} + 1`
done

echo "java MergeSamFiles.jar"
${JAVA} -Xms12g -Xmx12g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/MergeSamFiles.jar \
${strfiles} \
OUTPUT=${OUTPUTPATH}/realigned.bam \
VALIDATION_STRINGENCY=SILENT \
MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo "java BuildBamIndex.jar"
${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/BuildBamIndex.jar \
INPUT=${OUTPUTPATH}/realigned.bam \
VALIDATION_STRINGENCY=SILENT \
MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

