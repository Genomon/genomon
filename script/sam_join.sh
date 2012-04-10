#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

INPUTDIR=$1
OUTPUTDIR=$2
PIPEDIR=$3
PYTHON=$4

${PYTHON} ${PIPEDIR}/sam_join.py ${INPUTDIR} ${OUTPUTDIR}
