#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

OUTPUTPATH=$1
LANES=$2
PICARD=$3
JAVA=$4
TMP=$5
SCRIPTDIR=$6

source ${SCRIPTDIR}/utility.sh

# sleep 
sh ${SCRIPTDIR}/sleep.sh

RECORDS_IN_RAM=2500000

strfiles=""
count=0
for lane in ${LANES}
do
    echo "${OUTPUTPATH}/${lane}/"
    for file in `find ${OUTPUTPATH}/${lane}/ -name "ga.bam"`
    do
        strfiles="${strfiles}"" ""INPUT=${file}"
        count=`expr $count + 1`
    done
done

echo Merge alignment BAM files
echo "BAM files count : ${count}"

if [ $count -ge 2 ]; then
    ${JAVA} -Xms12g -Xmx12g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/MergeSamFiles.jar \
    ${strfiles} \
    OUTPUT=${OUTPUTPATH}/ga.bam \
    VALIDATION_STRINGENCY=SILENT \
    MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
    check_error $?

    echo Create BAM index
    ${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/BuildBamIndex.jar \
    INPUT=${OUTPUTPATH}/ga.bam \
    VALIDATION_STRINGENCY=SILENT \
    MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
    check_error $?

elif [ $count -eq 1 ]; then
    ln -f ${OUTPUTPATH}/${lane}/ga.bam ${OUTPUTPATH}/ga.bam
    check_error $?
    ln -f ${OUTPUTPATH}/${lane}/ga.bai ${OUTPUTPATH}/ga.bai
    check_error $?

else
    echo "there is no ${OUTPUTPATH}/ga.bam"
    echo "please check it"
    exit 1
fi

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
