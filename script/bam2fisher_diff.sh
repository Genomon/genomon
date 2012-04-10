#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

OUTPUTPATH=$1
TYPE1=$2  # e.g. tumor TAM 
TYPE2=$3  # e.g. normal
NUM=$4
REGION=$5
SCRIPTDIR=$6
R=$7
DEBUG_MODE=$8

source ${SCRIPTDIR}/utility.sh

# sleep 
if [ -z DEBUG_MODE ]; then
  sh ${SCRIPTDIR}/sleep.sh
fi

REGION_TMP=${REGION/:/_}
REGION_FILE_NAME=${REGION_TMP/-/_}
echo ${REGION_FILE_NAME} 

# filter candidate of variation between tumor and normal
##########
echo "perl ${SCRIPTDIR}/filterBase.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.base ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.filt"
perl ${SCRIPTDIR}/filterBase.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.base ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.filt
check_error $?

echo "perl ${SCRIPTDIR}/filterBase_del.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.del ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.del ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.filt"
perl ${SCRIPTDIR}/filterBase_del.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.del ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.del ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.filt  
check_error $?

echo "perl ${SCRIPTDIR}/filterBase_ins.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.ins ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.ins ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.filt"
perl ${SCRIPTDIR}/filterBase_ins.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.ins ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.ins ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.filt
check_error $?
##########


# caluculate p-value of Fisher's exact test for each candidate variation extract variations with low p-values
##########
if [ ! -s ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.filt ]; then
    echo "make empty file : ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.fisher"
    echo -n > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.fisher
else 
    echo "${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.fisher < ${SCRIPTDIR}/proc_fisherTest.R"
    ${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.fisher < ${SCRIPTDIR}/proc_fisherTest.R
    check_error $?
fi

if [ ! -s ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.filt ]; then
    echo "make empty file : ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.fisher"
    echo -n > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.fisher
else 
    echo "${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.fisher < ${SCRIPTDIR}/proc_fisherTest_insdel.R"
    ${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.fisher < ${SCRIPTDIR}/proc_fisherTest_insdel.R
    check_error $?
fi  

if [ ! -s ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.filt ]; then
    echo "make empty file : ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.fisher"
    echo -n > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.fisher
else 
    echo "${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.fisher < ${SCRIPTDIR}/proc_fisherTest_insdel.R"
    ${R} --vanilla --slave --args ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.filt ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.fisher < ${SCRIPTDIR}/proc_fisherTest_insdel.R
    check_error $?
fi
##########


# merge and convert the format of three variation files (mutation, insertion and deletion) for Annovar
##########
echo "perl ${SCRIPTDIR}/procForAnnovar.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.fisher ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.fisher ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.fisher > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.anno"
perl ${SCRIPTDIR}/procForAnnovar.pl ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.fisher ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.fisher ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.fisher > ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.anno
check_error $?
##########

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.base ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.base"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.base

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.del ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.del"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.del

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.del ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.del"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.del

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.ins ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.ins"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.ins

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.ins ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.ins"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.ins

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.filt ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.filt"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.filt

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.filt ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.filt"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.filt

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.filt ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.filt"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.filt

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.fisher ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.fisher"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.base.fisher

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.fisher ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.fisher"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.ins.fisher

check_empty_file ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.fisher ${OUTPUTPATH}/enpty_tmp_file.list
echo "rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.fisher"
rm ${OUTPUTPATH}/tmp/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}_${TYPE2}.del.fisher

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__

