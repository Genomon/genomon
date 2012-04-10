#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

INPUT_BAM=$1
OUTPUT_TXT=$2
SAMTOOLS=$3
SCRIPTDIR=$4

source ${SCRIPTDIR}/utility.sh

# sleep 
sh ${SCRIPTDIR}/sleep.sh

echo "${SAMTOOLS} view -H ${INPUT_BAM} > ${OUTPUT_TXT}.header"
${SAMTOOLS} view -H ${INPUT_BAM} > ${OUTPUT_TXT}.header
check_error $?

echo "grep ^@RG ${OUTPUT_TXT}.header > ${OUTPUT_TXT}.tmp"
grep ^@RG ${OUTPUT_TXT}.header > ${OUTPUT_TXT}.tmp
check_error $?

echo "perl ${SCRIPTDIR}/make_readgroup_list.pl ${OUTPUT_TXT}.tmp ${OUTPUT_TXT}"
perl ${SCRIPTDIR}/make_readgroup_list.pl ${OUTPUT_TXT}.tmp ${OUTPUT_TXT}
check_error $?

echo "rm ${OUTPUT_TXT}.header"
rm ${OUTPUT_TXT}.header
check_error $?

echo "rm ${OUTPUT_TXT}.tmp"
rm ${OUTPUT_TXT}.tmp 
check_error $?

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__

