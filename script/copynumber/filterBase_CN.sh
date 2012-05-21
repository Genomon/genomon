#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

#!/bin/bash
#$ -S /bin/bash
#$ -cwd

TARGETDIR=$1
NUM=$2
REGION=$3
TYPE1=$4 # normal control
TYPE2=$5 # tumor TAM AMKL
SCRIPTDIR=$6
CN_SCRIPTDIR=$7

source ${SCRIPTDIR}/utility.sh

# sleep
sh ${SCRIPTDIR}/sleep.sh

REGION_TMP=${REGION/:/_}
REGION_FILE_NAME=${REGION_TMP/-/_}


# filter candidate of variation between.${REGION_FILE_NAME}.${TYPE}.and normal
##########
echo "perl ${CN_SCRIPTDIR}/filterBase_CN.pl ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.base ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base > ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base.filt"
perl ${CN_SCRIPTDIR}/filterBase_CN.pl ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE1}.base ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base > ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base.filt
check_error $?


echo "rm ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base"
# rm ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.base
# check_error $?
echo "rm ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.ins"
# rm ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.ins
# check_error
echo "rm ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.del"
# rm ${TARGETDIR}/temp${NUM}.${REGION_FILE_NAME}.${TYPE2}.del
# check_error $?

