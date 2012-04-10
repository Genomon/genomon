#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -e ../log
#$ -o ../log

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

BWA=$1

../bin/${BWA}/bwa index -a bwtsw ../ref/hg19_${BWA}/hg19.fasta
