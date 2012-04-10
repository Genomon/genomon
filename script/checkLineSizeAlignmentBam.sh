#! /bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

FASTQ_R1=$1
BAM=$2
SAMTOOLS=$3
SCRIPTDIR=$4

source ${SCRIPTDIR}/utility.sh

# sleep 
sh ${SCRIPTDIR}/sleep.sh

fastqR1linesize=`wc -l ${FASTQ_R1} | cut -d' ' -f1`
check_error $?

fastqhalfsize=`expr ${fastqR1linesize} / 2`
check_error $?

bamlinesize=`${SAMTOOLS} view ${BAM} | wc -l ${FASTQ} | cut -d' ' -f1`
check_error $?

echo "${FASTQ_R1} : harf line size : ${fastqhalfsize}"
echo "${BAM} : line size : ${bamlinesize}"

if [ ${fastqhalfsize} -ne ${bamlinesize} ]; then
  echo "ERROR"
  echo "fastqR1 half line size : ${fastqhalfsize} "
  echo "bam line size          : ${bamlinesize}"
  exit 1
fi

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
