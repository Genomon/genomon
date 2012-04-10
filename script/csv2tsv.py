#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

import csv
from optparse import OptionParser

parser = OptionParser()
(options, args) = parser.parse_args()

CSV  = args[0]
TSV = args[1]

reader = csv.reader(file(CSV, "rb"))
writer = csv.writer(file(TSV, "wb"), delimiter='\t')
writer.writerows(reader)

