#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

SAM=$1
SAI1=$2
SAI2=$3
SEQ1=$4
SEQ2=$5
REF=$6
ID=$7
LB=$8
PL=$9
SM=${10}
BWA=${11}
SCRIPTDIR=${12}

# sleep 
sh ${SCRIPTDIR}/sleep.sh

echo "${BWA} sampe -f ${SAM} -r "@RG\tID:${ID}\tPL:${PL}\tLB:${LB}\tSM:${SM}" -P ${REF} ${SAI1} ${SAI2} ${SEQ1} ${SEQ2}"
${BWA} sampe -f ${SAM} -r "@RG\tID:${ID}\tPL:${PL}\tLB:${LB}\tSM:${SM}" -P ${REF} ${SAI1} ${SAI2} ${SEQ1} ${SEQ2}
