#!/bin/bash
#$ -S /bin/bash
#$ -l s_vmem=16G,mem_req=16
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

BAMFILES=$1
OUTPUT=$2
SCRIPTDIR=$3
JAVA=$4
PICARD=$5
TMP=$6

RECORDS_IN_RAM=2500000

source ${SCRIPTDIR}/utility.sh

# sleep 
sh ${SCRIPTDIR}/sleep.sh

if [ -f ${OUTPUT} ]; then
  rm ${OUTPUT}
  check_error $?
fi

outputbai=`echo ${OUTPUT} | sed -e "s/\.bam/.bai/"`
if [ -f ${outputbai} ]; then
  rm ${outputbai}
  check_error $?
fi


files=`echo "${BAMFILES}" | sed -e 's/,/ /g'`
for file in ${files}
do
    strfiles="${strfiles}"" ""INPUT=${file}"
done

echo Merge bam files
${JAVA} -Xms12g -Xmx12g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/MergeSamFiles.jar \
  ${strfiles} \
  OUTPUT=${OUTPUT} \
  VALIDATION_STRINGENCY=SILENT \
  TMP_DIR=${TMP} \
  MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo Create bam index
${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/BuildBamIndex.jar \
  INPUT=${OUTPUT} \
  VALIDATION_STRINGENCY=SILENT \
  TMP_DIR=${TMP} \
  MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
