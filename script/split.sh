#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

LINES=$1
SUFFIX=$2
INPUT=$3
OUTPUTDIR=$4
OUTPUTPREFIX=$5

split -l ${LINES} -a ${SUFFIX} ${INPUT} "${OUTPUTDIR}/${OUTPUTPREFIX}"

splitfastqfiles=(`find ${OUTPUTDIR} -type f -name ${OUTPUTPREFIX}* -print | sort`)
for (( i = 0; i < ${#splitfastqfiles[*]}; i++ ))
do
    splitfastq=${splitfastqfiles[i]}
    filetmp=`echo ${splitfastq} | sed -e "s/\.fastq//"`
    filefastq=${filetmp}.fastq
    mv ${splitfastq} ${filefastq}
done

