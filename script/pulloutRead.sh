#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

KEYFILE=$1
INPUTDIR=$2
OUTPUTDIR=$3
NUM=$4
REGION=$5
SAMTOOLS=$6
SCRIPTDIR=$7

source ${SCRIPTDIR}/utility.sh

# sleep 
sh ${SCRIPTDIR}/sleep.sh

REGION_TMP=${REGION/:/_}
REGION_FILE_NAME=${REGION_TMP/-/_}
echo ${REGION_FILE_NAME} 

BAM_NAME=temp${NUM}.${REGION_FILE_NAME}_realigned.bam
SAM_NAME=temp${NUM}.${REGION_FILE_NAME}_realigned.sam

strkeystmp=""
while read key
do
    strkeystmp="ID:${key}|${strkeystmp}"
done < ${KEYFILE}
lastindex=`expr ${#strkeystmp} - 1`
awkstrkeys=`echo ${strkeystmp} | cut -c1-${lastindex}`
echo "${awkstrkeys}"

strkeystmp=""
while read key
do
    strkeystmp="RG:Z:${key}|${strkeystmp}"
done < ${KEYFILE}
lastindex=`expr ${#strkeystmp} - 1`
egrepstrkeys=`echo ${strkeystmp} | cut -c1-${lastindex}`
echo "${egrepstrkeys}"

echo "make header of sam file"
${SAMTOOLS} view -H ${INPUTDIR}/${BAM_NAME} | awk '{ if(( $0~/^@RG/ && $0~/'${awkstrkeys}'/ ) || ( $0!~/^@RG/ )){print $0}}' > ${OUTPUTDIR}/${SAM_NAME} 
check_error $?

echo "make body of sam file"
${SAMTOOLS} view ${INPUTDIR}/${BAM_NAME} | egrep ${egrepstrkeys} >> ${OUTPUTDIR}/${SAM_NAME}
check_error $?

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
