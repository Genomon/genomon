#! /bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

INPUTPATH=$1
TYPE1=$2 # e.g. tumor TAM
TYPE2=$3 # e.g. normal
BAIT_NUM=$4

num=1
strfiles=""
while [ ${num} -le ${BAIT_NUM} ];
do
    file=${INPUTPATH}/tmp/temp${num}.*.${TYPE1}_${TYPE2}.anno
    if [ ! -f ${file} ]; then
        echo "${file} : No such file or directory"
        exit 1
    fi
    echo $file
    strfiles="${strfiles}"" ""${file}"
    num=`expr ${num} + 1`
done
cat ${strfiles} > ${INPUTPATH}/output.${TYPE1}_${TYPE2}.anno

