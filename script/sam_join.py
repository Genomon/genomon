#! /usr/bin/env python

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

import sys
import os

def sam_join(InputDir,OutputDir):
    
    files = os.listdir(InputDir)
    
    fname = OutputDir + '/ga.sam'
    dstfile = open(fname,'w')
    
    setHeader = 0
    for file in files:
        fname = InputDir + '/' + file
        srcfile = open(fname,'r')
        for line in srcfile:
            if (setHeader == 0):
                dstfile.write(line)
            else:       
                if(line[0] != '@' ):
                    dstfile.write(line)
        srcfile.close()
        setHeader = 1
    dstfile.close()    
    return

if __name__ == "__main__":
    sam_join(sys.argv[1],sys.argv[2])
