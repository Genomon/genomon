#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

echo $(( $RANDOM % 30 ))
cnt=`echo $(( $RANDOM % 30 ))`
echo "sleep ${cnt} start"
date
sleep ${cnt}
date
echo "sleep ${cnt} end"
 
