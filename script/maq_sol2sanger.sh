#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

INPUTFILE=$1
OUTPUTFILE=$2
MAQ=$3
SCRIPTDIR=$4

# sleep 
sh ${SCRIPTDIR}/sleep.sh

${MAQ} sol2sanger ${INPUTFILE} ${OUTPUTFILE}


