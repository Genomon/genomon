#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

INPUT=$1
OUTPUT=$2
REF=$3
BWA=$4
SCRIPTDIR=$5

# sleep 
sh ${SCRIPTDIR}/sleep.sh

echo ${INPUT}
${BWA} aln -f ${OUTPUT} -t 8 ${REF} ${INPUT} 
