#!/bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

RECORDS_IN_RAM=5000000

INPUTPATH=$1
OUTPUTDIR=$2
DBDIR=$3
BAIT=$4
GENREF=$5
PICARD=$6
JAVA=$7
TMP=$8
SCRIPTDIR=$9

source ${SCRIPTDIR}/utility.sh

# sleep 
sh ${SCRIPTDIR}/sleep.sh

ORIGINALBED=${DBDIR}/${BAIT}.bed
TMPPICARDBED=${DBDIR}/${BAIT}.noheader.picard.bed
PICARDBED=${DBDIR}/${BAIT}.picard.bed
HEADERTXT=${DBDIR}/header.txt

if [ -s ${HEADERTXT} ]; then
    echo "${HEADERTXT} exists."
else
    echo "${HEADERTXT} dose not exists or is empty."
    exit 1
fi

if [ -s ${PICARDBED} ]; then
    echo "${PICARDBED} exists."
else
    echo "make ${PICARDBED}"

    if [ -s ${ORIGINALBED} ]; then
        awk '{print $1"\t"$2"\t"$3"\t"$6"\t"$4}' ${ORIGINALBED} > ${TMPPICARDBED}
        cat ${HEADERTXT} ${TMPPICARDBED} > ${PICARDBED}
    else
        echo "${ORIGINALBED} does not exits or is empty."
        exit 1
    fi
fi


echo "java CollectAlignmentSummaryMetrics.jar"
${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/CollectAlignmentSummaryMetrics.jar \
    INPUT=${INPUTPATH}/ga.bam \
    OUTPUT=${OUTPUTDIR}/AlignmentSummaryMetrics.txt \
    R=${GENREF} \
    VALIDATION_STRINGENCY=SILENT \
    MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?


echo "java CollectGcBiasMetrics.jar"
${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/CollectGcBiasMetrics.jar \
    INPUT=${INPUTPATH}/ga.bam \
    OUTPUT=${OUTPUTDIR}/GcBiasDetailMetrics.txt \
    SUMMARY_OUTPUT=${OUTPUTDIR}/GcBiasSummaryMetrics.txt \
    R=${GENREF} \
    CHART_OUTPUT=${OUTPUTDIR}/GcBiasDetailMetrics.pdf \
    VALIDATION_STRINGENCY=SILENT \
    MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?


echo "java CollectInsertSizeMetrics.jar"
${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/CollectInsertSizeMetrics.jar \
    INPUT=${INPUTPATH}/ga.bam \
    OUTPUT=${OUTPUTDIR}/InsertSizeMetrics.txt \
    HISTOGRAM_FILE=${OUTPUTDIR}/InsertSizeMetrics.pdf \
    R=${GENREF} \
    VALIDATION_STRINGENCY=SILENT \
    MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?


echo "java MeanQualityByCycle.jar"
${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/MeanQualityByCycle.jar \
    INPUT=${INPUTPATH}/ga.bam \
    OUTPUT=${OUTPUTDIR}/MeanQualityByCycle.txt \
    CHART_OUTPUT=${OUTPUTDIR}/MeanQualityByCycle.pdf \
    R=${GENREF} \
    VALIDATION_STRINGENCY=SILENT \
    MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?


echo "java QualityScoreDistribution.jar"
${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/QualityScoreDistribution.jar \
    INPUT=${INPUTPATH}/ga.bam \
    OUTPUT=${OUTPUTDIR}/QualityScoreDistribution.txt \
    CHART_OUTPUT=${OUTPUTDIR}/QualityScoreDistribution.pdf \
    R=${GENREF} \
    VALIDATION_STRINGENCY=SILENT \
    MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?


echo "java CalculateHsMetrics.jar"
${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/CalculateHsMetrics.jar \
    INPUT=${INPUTPATH}/ga.bam \
    OUTPUT=${OUTPUTDIR}/CalculateHsMetrics.txt \
    BAIT_INTERVALS=${PICARDBED} \
    TARGET_INTERVALS=${PICARDBED} \
    VALIDATION_STRINGENCY=SILENT \
    MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?


echo "java EstimateLibraryComplexity.jar"
${JAVA} -Xms4g -Xmx4g -Djava.io.tmpdir=${TMP} -jar ${PICARD}/EstimateLibraryComplexity.jar \
    INPUT=${INPUTPATH}/ga.bam \
    OUTPUT=${OUTPUTDIR}/EstimateLibraryComplexity.txt \
    VALIDATION_STRINGENCY=SILENT \
    MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__

