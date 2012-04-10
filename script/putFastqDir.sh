#! /bin/sh
#$ -S /bin/sh
#$ -e ../log
#$ -o ../log
#$ -cwd 

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

# delete outputfile
export LANG=C

FILTER_FLG="FALSE"
while getopts f OPT
do
  case $OPT in
    "f") FILTER_FLG="TRUE"  ;;
  esac
done
shift `expr $OPTIND - 1`

INPUTPATH=$1
SAMPLE=$2
RUNDATE=$3
TYPE=$4

INPUTDIR=../data/input
IN_SAMPLE_DIR=${INPUTDIR}/${SAMPLE}
IN_DATE_DIR=${IN_SAMPLE_DIR}/${RUNDATE}
FILTDIR=${IN_DATE_DIR}/${TYPE}

if [ $# -ne 4 ]; then
    echo "Illigal argument error "
    echo "Number of arguments is fault : $#"
    exit 1
fi

if [ ! -d ${IN_SAMPLE_DIR} ] ; then
    mkdir ${IN_SAMPLE_DIR}
fi
if [ ! -d ${IN_DATE_DIR} ] ; then
    mkdir ${IN_DATE_DIR}
fi
if [ ! -d ${FILTDIR} ] ; then
    mkdir ${FILTDIR}
fi

echo "FILTER_FLG : ${FILTER_FLG}"

# delete outputfile
##################################
gzfiles=(`find ${INPUTPATH} -name "*gz" -print | sort`)

for (( i = 0; i < ${#gzfiles[*]}; i++ ))
do
    gzfile=${gzfiles[i]}
    headline=`zcat ${gzfile} | head -n1`
    flowcell=`echo ${headline} | awk '{split($0, ARRAY, ":"); print ARRAY[3]}'`
    lane=`echo ${headline} | awk '{split($0, ARRAY, ":"); print ARRAY[4]}'`
    pair=`echo ${headline} | awk '{split($0, ARRAY, ":"); split(ARRAY[7], ARRAY2, " "); print ARRAY2[2]}'`
    tag=`echo ${headline} | awk '{split($0, ARRAY, ":"); print ARRAY[10]}'`
    flowcelllaneDir=${FILTDIR}/${flowcell}.${lane}.${tag} 
    filtfile=${SAMPLE}_${TYPE}_R${pair}.fastq

    if [ ! -d ${flowcelllaneDir} ] ; then
        mkdir ${flowcelllaneDir}
    fi

    if [ -f ${flowcelllaneDir}/${filtfile} ] ; then
        rm ${flowcelllaneDir}/${filtfile}
    fi

done

# gunzip file and filter
##################################
for (( i = 0; i < ${#gzfiles[*]}; i++ ))
do
    gzfile=${gzfiles[i]}
    echo ${gzfile}
    headline=`zcat ${gzfile} | head -n1`
    flowcell=`echo ${headline} | awk '{split($0, ARRAY, ":"); print ARRAY[3]}'`
    lane=`echo ${headline} | awk '{split($0, ARRAY, ":"); print ARRAY[4]}'`
    pair=`echo ${headline} | awk '{split($0, ARRAY, ":"); split(ARRAY[7], ARRAY2, " "); print ARRAY2[2]}'`
    tag=`echo ${headline} | awk '{split($0, ARRAY, ":"); print ARRAY[10]}'`
    flowcelllaneDir=${FILTDIR}/${flowcell}.${lane}.${tag} 
    filtfile=${SAMPLE}_${TYPE}_R${pair}.fastq

    if [ ${FILTER_FLG} = "TRUE" ] ; then
        echo "filter ${gzfile} >> ${flowcelllaneDir}/${filtfile}"
        gzip -dc ${gzfile} | grep -A 3 '^@.* [^:]*:N:[^:]*:' | grep -v '^--$' >> ${flowcelllaneDir}/${filtfile}
    else
        echo "not filter ${gzfile} >> ${flowcelllaneDir}/${filtfile}"
        gzip -dc ${gzfile}  >> ${flowcelllaneDir}/${filtfile}
    fi
done


