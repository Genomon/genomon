#!/bin/bash
#$ -S /bin/bash
#$ -e ../log
#$ -o ../log
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

python -u ./map_bwa.py $*

