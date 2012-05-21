#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

#!/bin/bash
#$ -S /bin/bash
#$ -e ../log
#$ -o ../log
#$ -cwd


python -u ./copy_num.py $*

