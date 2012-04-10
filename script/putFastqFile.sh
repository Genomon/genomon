#! /bin/sh
#$ -S /bin/sh
#$ -e ../log
#$ -o ../log
#$ -cwd 

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

export LANG=C

FILTER_FLG="FALSE"
while getopts f OPT
do
  case $OPT in
    "f") FILTER_FLG="TRUE"  ;;
  esac
done
shift `expr $OPTIND - 1`

INPUTFILE=$1
SAMPLE=$2
RUNDATE=$3
TYPE=$4
LANE=$5
PAIR=$6

if [ $# -ne 6 ]; then
    echo "Illigal argument error "
    echo "Number of arguments is fault : $#"
    exit 1
fi
if [ ! -e ${INPUTFILE} ]; then
    echo "Illigal argument error "
    echo "INPUTFILE must be Fasta File : ${INPUTFILE}"
    exit 1
fi

echo "FILTER_FLG : ${FILTER_FLG}"

INPUTDIR=../data/input
SAMPLE_DIR=${INPUTDIR}/${SAMPLE}
DATE_DIR=${SAMPLE_DIR}/${RUNDATE}
TYPE_DIR=${DATE_DIR}/${TYPE}
LANE_DIR=${TYPE_DIR}/${LANE}

if [ ! -d ${SAMPLE_DIR} ] ; then
    mkdir ${SAMPLE_DIR}
fi
if [ ! -d ${DATE_DIR} ] ; then
    mkdir ${DATE_DIR}
fi
if [ ! -d ${TYPE_DIR} ] ; then
    mkdir ${TYPE_DIR}
fi
if [ ! -d ${LANE_DIR} ] ; then
    mkdir ${LANE_DIR}
fi

# delete outputfile
##################################

if [ ${FILTER_FLG} = "TRUE" ] ; then
    echo "filter ${INPUTFILE} >  ${LANE_DIR}/${SAMPLE}_${TYPE}_R${PAIR}.fastq"
    case "$INPUTFILE" in
    *\.bz2)
      bzip2 -dc ${INPUTFILE} | grep -A 3 '^@.* [^:]*:N:[^:]*:' | grep -v '^--$' > ${LANE_DIR}/${SAMPLE}_${TYPE}_R${PAIR}.fastq
      ;;
    *)
      cat ${INPUTFILE} | grep -A 3 '^@.* [^:]*:N:[^:]*:' | grep -v '^--$' > ${LANE_DIR}/${SAMPLE}_${TYPE}_R${PAIR}.fastq
      ;;
    esac
else
    echo "no filter ${INPUTFILE} >  ${LANE_DIR}/${SAMPLE}_${TYPE}_R${PAIR}.fastq"
    case "$INPUTFILE" in
    *\.bz2)
      bzip2 -dc ${INPUTFILE} > ${LANE_DIR}/${SAMPLE}_${TYPE}_R${PAIR}.fastq
      ;;
    *)
      ln -f ${INPUTFILE} ${LANE_DIR}/${SAMPLE}_${TYPE}_R${PAIR}.fastq
      ;;
    esac
fi
