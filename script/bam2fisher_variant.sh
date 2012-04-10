#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

INPUTBAM=$1
OUTPUTPATH=$2
NUM=$3
REGION=$4
TYPE=$5
MAP_QUAL_THRES=$6
BASE_QUAL_THRES=$7
INTERVAL=$8
MAX_INDEL=$9
GENREF=${10}
SCRIPTDIR=${11}
SAMTOOLS=${12}
R=${13}
DEBUG_MODE=${14}

source ${SCRIPTDIR}/utility.sh

# sleep 
if [ -z DEBUG_MODE ]; then
  sh ${SCRIPTDIR}/sleep.sh
fi

REGION_TMP=${REGION/:/_}
REGION_FILE_NAME=${REGION_TMP/-/_}
echo ${REGION_FILE_NAME} 

# extract .bam for a diveded regions form recal.bam 
# remove reads which have more than 5 mis-matches
# remove reads whose mapping quality is less than 30
##########
echo "${SAMTOOLS} view -h -q ${MAP_QUAL_THRES} ${INPUTBAM} ${REGION} > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam"
${SAMTOOLS} view -h -q ${MAP_QUAL_THRES} ${INPUTBAM} ${REGION} > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam
check_error $?

echo "perl ${SCRIPTDIR}/mismatchFilter.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam ${MAX_INDEL} > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam.filt"
perl ${SCRIPTDIR}/mismatchFilter.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam ${MAX_INDEL} > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam.filt
check_error $?

echo "${SAMTOOLS} view -bS ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam.filt > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam"
${SAMTOOLS} view -bS ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam.filt > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam
check_error $?

##########


# pileup diveded .bam files.
##########
echo "${SAMTOOLS} mpileup -BQ0 -d10000000 -f ${GENREF} ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup"
${SAMTOOLS} mpileup -BQ0 -d10000000 -f ${GENREF} ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup
check_error $?
##########


# make count files for mismatches, insertions and deletions
# mismatch count is performed considering bases whose quality is more than 15.
##########
echo "perl ${SCRIPTDIR}/pileup2base.pl ${BASE_QUAL_THRES} ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del"
perl ${SCRIPTDIR}/pileup2base.pl ${BASE_QUAL_THRES} ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del
check_error $?
##########


# filter candidate of variation
##########
echo "perl ${SCRIPTDIR}/filterBase.barcode.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.filt"
perl ${SCRIPTDIR}/filterBase.barcode.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.filt 
check_error $?

echo "perl ${SCRIPTDIR}/filterBase_del.barcode.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.filt"
perl ${SCRIPTDIR}/filterBase_del.barcode.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.filt
check_error $?

echo "perl ${SCRIPTDIR}/filterBase_ins.barcode.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.filt"
perl ${SCRIPTDIR}/filterBase_ins.barcode.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.filt
check_error $?


if [ ! -s ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.filt ]; then
    echo "make empty file : ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.fisher"
    echo -n > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.fisher
else 
    echo "${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.fisher < ${SCRIPTDIR}/proc_fisherTest.barcode.R"
    ${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.fisher < ${SCRIPTDIR}/proc_fisherTest.barcode.R
    check_error $?
fi

if [ ! -s ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.filt ]; then
    echo "make empty file : ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.fisher"
    echo -n > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.fisher
else 
    echo "${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.fisher < ${SCRIPTDIR}/proc_fisherTest_insdel.barcode.R"
    ${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.fisher < ${SCRIPTDIR}/proc_fisherTest_insdel.barcode.R
    check_error $?
fi

if [ ! -s ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.filt ]; then
    echo "make empty file : ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.fisher"
    echo -n > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.fisher
else 
    echo "${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.fisher < ${SCRIPTDIR}/proc_fisherTest_insdel.barcode.R"
    ${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.fisher < ${SCRIPTDIR}/proc_fisherTest_insdel.barcode.R
    check_error $?
fi


# gather base count, deletion count and insertion count files 
echo "perl ${SCRIPTDIR}/gatherFisher.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.fisher ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.fisher  ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.fisher > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.anno"
perl ${SCRIPTDIR}/gatherFisher.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.fisher ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.fisher  ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.fisher > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.anno 
check_error $?

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam.filt ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam.filt"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.sam.filt

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.bam

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.pileup

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.filt ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.filt"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.filt

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.filt ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.filt"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.filt

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.filt ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.filt"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.filt

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.fisher ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.fisher"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.base.fisher

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.fisher ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.fisher"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.ins.fisher

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.fisher ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.fisher"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE}.del.fisher

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__

