#!/bin/bash
#$ -S /bin/bash
#$ -l s_vmem=2G,mem_req=2
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

INPUT=$1
OUTPUT=$2

source ${SCRIPTDIR}/utility.sh

if [ -f ${OUTPUT} ]; then
  rm ${OUTPUT}
  check_error $?
fi

ln ${INPUT} ${OUTPUT}
check_error $?

inputbai=`echo ${INPUT} | sed -e "s/\.bam/.bai/"`
outputbai=`echo ${OUTPUT} | sed -e "s/\.bam/.bai/"`

if [ -f ${outputbai} ]; then
  rm ${outputbai}
  check_error $?
fi

ln ${inputbai} ${outputbai}
check_error $?


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
