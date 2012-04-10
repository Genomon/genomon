#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

INFASTQ=$1
OUTFASTQ=$2
TMPOUTFASTQ=$3
CASAVACODE=$4
ADAPTERS=$5
CUTADAPT=$6
SCRIPTDIR=$7

echo $1
echo $2
echo $3
echo $4
echo $5
echo $6
echo $7
echo $8

source ${SCRIPTDIR}/utility.sh

# sleep 
sh ${SCRIPTDIR}/sleep.sh

adapters=`echo "${ADAPTERS}" | sed -e 's/,/ /g'`
for adapter in ${adapters}
do
    optadapters="${optadapters}"" ""-a ${adapter}"
done

echo "${CUTADAPT} ${optadapters} ${INFASTQ} > ${TMPOUTFASTQ}"
${CUTADAPT} ${optadapters} ${INFASTQ} > ${TMPOUTFASTQ}
check_error $?

echo "${SCRIPTDIR}/fastqNPadding.pl ${CASAVACODE} ${TMPOUTFASTQ} > ${OUTFASTQ}"
${SCRIPTDIR}/fastqNPadding.pl ${CASAVACODE} ${TMPOUTFASTQ} > ${OUTFASTQ}
check_error $?

