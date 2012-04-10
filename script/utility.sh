#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

check_mkdir()
{

if [ -d $1 ]
then
    echo "$1 exists."
else
    echo "$1 does not exits."
    mkdir -p $1
fi
}


check_exist_file()
{

if [ -f $1 ]
then
    echo "$1 exists."
else
    echo "$1 does not exits."
    exit 1
fi

}


check_error()
{

if [ $1 -ne 0 ]; then
    echo "FATAL ERROR: pipeline script"
    echo "ERROR CODE: $1"
    exit $1
fi
}

check_empty_file()
{

echo "check empty file : $1"
if [ ! -s $1 ]; then
    echo "empty file : $1" >> $2
fi

}

