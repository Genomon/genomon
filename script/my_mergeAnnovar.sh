#! /bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

INPUTPATH=$1
TYPE=$2
BAIT_NUM=$3

num=1
strfiles=""
while [ ${num} -le ${BAIT_NUM} ];
do
    file=${INPUTPATH}/tmp/temp${num}.*.${TYPE}.anno
    if [ ! -f ${file} ]; then
        echo "${file} : No such file or directory"
        exit 1
    fi
    echo $file
    strfiles="${strfiles}"" ""${file}"
    num=`expr ${num} + 1`
done
cat ${strfiles} > ${INPUTPATH}/output.${TYPE}.anno

