#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

#! /bin/bash
#$ -S /bin/bash
#$ -cwd

SAMPLE=$1
TYPE=$2
BAIT_NUM=$3
TARGETDIR=$4
ALLELEDIR=$5
ALLELETMP=$6
TOTALDIR=$7
GENREF=$8
SCRIPTDIR=$9
BEDTOOLS=${10}
R=${11}
CN_SCRIPTDIR=${12}

source ${SCRIPTDIR}/utility.sh

sh ${SCRIPTDIR}/sleep.sh


echo -n > ${ALLELEDIR}/hetero.txt
for i in `seq 1 1 ${BAIT_NUM}`
do
    echo "cat ${ALLELETMP}/temp${i}.chr*.base.filt >> ${ALLELEDIR}/hetero.txt"
    cat ${ALLELETMP}/temp${i}.chr*.base.filt >> ${ALLELEDIR}/hetero.txt
    check_error $?
done

echo "${BEDTOOLS}/fastaFromBed -fi ${GENREF} -bed ${TOTALDIR}/${TYPE}.count -fo ${TARGETDIR}/${SAMPLE}.fa -tab"
${BEDTOOLS}/fastaFromBed -fi ${GENREF} -bed ${TOTALDIR}/${TYPE}.count -fo ${TARGETDIR}/${SAMPLE}.fa -tab
check_error $?

echo "perl ${CN_SCRIPTDIR}/hetero2abnum2.pl ${ALLELEDIR}/hetero.txt > ${TARGETDIR}/${SAMPLE}.as_count"
perl ${CN_SCRIPTDIR}/hetero2abnum2.pl ${ALLELEDIR}/hetero.txt > ${TARGETDIR}/${SAMPLE}.as_count
check_error $?

echo "${BEDTOOLS}/intersectBed -a ${TOTALDIR}/${TYPE}.count -b ${TARGETDIR}/${SAMPLE}.as_count -wa -wb > ${TARGETDIR}/${SAMPLE}.as_count.bait.tmp"
${BEDTOOLS}/intersectBed -a ${TOTALDIR}/${TYPE}.count -b ${TARGETDIR}/${SAMPLE}.as_count -wa -wb > ${TARGETDIR}/${SAMPLE}.as_count.bait.tmp
check_error $?

echo "${R} --vanilla --slave --args ${TARGETDIR}/${SAMPLE}.as_count.bait.tmp ${TARGETDIR}/${SAMPLE}.as_count.bait < ${CN_SCRIPTDIR}/getBaitwiseAsCount.R"
${R} --vanilla --slave --args ${TARGETDIR}/${SAMPLE}.as_count.bait.tmp ${TARGETDIR}/${SAMPLE}.as_count.bait < ${CN_SCRIPTDIR}/getBaitwiseAsCount.R
check_error $?

echo "rm -r ${ALLELETMP}"
rm -r ${ALLELETMP}
check_error $?


