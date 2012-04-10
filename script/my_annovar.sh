#! /bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012


SAMPLE_FOLDER=$1
TYPE=$2  # e.g. tumor TAM
TYPE2=$3 # e.g. normal
INPUTPATH=$4
ANNOPATH=$5
SCRIPTDIR=$6
INHOUSEFLG=$7 # 0:false 1:true
COSMICFLG=$8  # 0:false 1:true
JAVA=$9
JAVATOOLS=${10}
TMPDIR=${11}
PYTHON=${12}
DEBUG_MODE=${13}

source ${SCRIPTDIR}/utility.sh

# sleep 
if [ -z DEBUG_MODE ]; then
  sh ${SCRIPTDIR}/sleep.sh
fi

OUTFILE_PREFIX=sum_${SAMPLE_FOLDER}_${TYPE}


CURRDIR=`pwd`
cd ${ANNOPATH}
echo "./summarize_annovar.pl -buildver hg19 -verdbsnp 131 ${INPUTPATH}/output.${TYPE}_${TYPE2}.anno humandb/ -outfile ${OUTFILE_PREFIX}"
./summarize_annovar.pl -buildver hg19 -verdbsnp 131 ${INPUTPATH}/output.${TYPE}_${TYPE2}.anno humandb/ -outfile ${OUTFILE_PREFIX}
check_error $?
cd ${CURRDIR}


echo "cp ${ANNOPATH}/${OUTFILE_PREFIX}.exome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.csv"
cp ${ANNOPATH}/${OUTFILE_PREFIX}.exome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.csv
check_error $?

echo "cp ${ANNOPATH}/${OUTFILE_PREFIX}.genome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.csv"
cp ${ANNOPATH}/${OUTFILE_PREFIX}.genome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.csv
check_error $?


echo "${PYTHON} ${SCRIPTDIR}/csv2tsv.py ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.txt"
${PYTHON} ${SCRIPTDIR}/csv2tsv.py ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.txt
check_error $?

echo "${PYTHON} ${SCRIPTDIR}/csv2tsv.py ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.txt"
${PYTHON} ${SCRIPTDIR}/csv2tsv.py ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.txt
check_error $?


echo "perl ${SCRIPTDIR}/procSummary.pl ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.exome.result.txt"
perl ${SCRIPTDIR}/procSummary.pl ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.exome.result.txt
check_error $?

echo "perl ${SCRIPTDIR}/procSummary.pl ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.genome.result.txt"
perl ${SCRIPTDIR}/procSummary.pl ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.genome.result.txt
check_error $?


rm ${ANNOPATH}/${OUTFILE_PREFIX}.*
check_error $?
rm ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.csv
check_error $?
rm ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.csv
check_error $?

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
