#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

import os
import subprocess
import time
import glob
import sys
import ConfigParser
import re
import shutil

class conf_utility:

    def __init__(self):
        #load init file
        CONFIG_FILE = os.path.join(os.path.dirname(__file__), "exon_pipeline.config")
        conf = ConfigParser.SafeConfigParser()
        conf.read(CONFIG_FILE)
      
        if os.path.exists(CONFIG_FILE):
            f = open(CONFIG_FILE, "r")
            conf.readfp(f)
            f.close()
        else:
            print 'There is no %s' % CONFIG_FILE
            import sys
            sys.exit()


        user_name = conf.get('user-info','name')
        self.userinfo = {'name' : user_name}

        dir_project = conf.get('directory-path','project')
        dir_script  = dir_project +'/'+ conf.get('directory-path','script')
        dir_ref     = dir_project +'/'+ conf.get('directory-path','ref')
        dir_input   = dir_project +'/'+ conf.get('directory-path','input')
        dir_output  = dir_project +'/'+ conf.get('directory-path','output')
        dir_result  = dir_project +'/'+ conf.get('directory-path','result')
        dir_db      = dir_project +'/'+ conf.get('directory-path','db')
        dir_sys     = dir_project +'/'+ conf.get('directory-path','sys')
        dir_tmp     = dir_project +'/'+ conf.get('directory-path','tmp')
        dir_log     = dir_project +'/'+ conf.get('directory-path','log')
        dir_inhouse = dir_project +'/'+ conf.get('directory-path','inhousedata')
        dir_summary = dir_project +'/'+ conf.get('directory-path','summarydata')
        self.dir = {'script' : dir_script,
                    'ref'    : dir_ref, 
                    'input'  : dir_input,
                    'output' : dir_output,
                    'result' : dir_result,
                    'db'     : dir_db,
                    'sys'    : dir_sys,
                    'tmp'    : dir_tmp,
                    'log'    : dir_log,
                    'summary': dir_summary,
                    'inhouse': dir_inhouse
                    }

        ref_hg19  = dir_project +'/'+ conf.get('data-file','hg19fasta')
        dbsnprod  = dir_project +'/'+ conf.get('data-file','dbsnprod')
        self.data = {'hg19fasta' : ref_hg19,
                     'dbsnprod' : dbsnprod}

        read1       =  conf.get('adapter','read1')
        read2       =  conf.get('adapter','read2')
        self.adapter = {'read1'      : read1,
                        'read2'      : read2}

        bwa          = dir_project +'/'+ conf.get('bin','bwa')
        picard       = dir_project +'/'+ conf.get('bin','picard')
        samtools     = dir_project +'/'+ conf.get('bin','samtools')
        bedtools     = dir_project +'/'+ conf.get('bin','bedtools')
        cutadapt     = dir_project +'/'+ conf.get('bin','cutadapt')
        annovar      = dir_project +'/'+ conf.get('bin','annovar')
        javatools    = dir_project +'/'+ conf.get('bin','javatools')
        python2_6_5  = conf.get('bin','python2.6')
        java6        = conf.get('bin','java6')
        maq          = conf.get('bin','maq')
        R            = conf.get('bin','R')
        gatk         = dir_project +'/'+ conf.get('bin','gatk')
        gatk1_0      = dir_project +'/'+ conf.get('bin','gatk1_0')
        self.bin = {'bwa'         : bwa,
                    'picard'      : picard,
                    'samtools'    : samtools,
                    'bedtools'    : bedtools,
                    'cutadapt'    : cutadapt,
                    'annovar'     : annovar,
                    'javatools'   : javatools,
                    'python2.6'   : python2_6_5,
                    'java6'       : java6,
                    'maq'         : maq,
                    'R'           : R,
                    'gatk'        : gatk,
                    'gatk1_0'     : gatk1_0
                    }

        inhouse  =  conf.get('db','inhouseflg')
        cosmic   =  conf.get('db','cosmicflg')
        self.db = {'inhouseflg' : inhouse,
                   'cosmicflg'  : cosmic}
        
        ngs_dbname    =  conf.get('ngsdb','dbname')
        ngs_hostname  =  conf.get('ngsdb','hostname')
        ngs_port      =  conf.get('ngsdb','port')
        ngs_user      =  conf.get('ngsdb','user')
        ngs_password  =  conf.get('ngsdb','password')
        self.ngsdb    = {'dbname'    : ngs_dbname,
                         'hostname'  : ngs_hostname,
                         'port'      : ngs_port,
                         'user'      : ngs_user,
                         'password'  : ngs_password}
        
        
        return 

    def getUserInfo(self):
        return self.userinfo
    
    def getDirectoryPath(self):
        return self.dir
    
    def getDataFilePath(self):
        return self.data
    
    def getAdapterPath(self):
        return self.adapter
    
    def getBinFilePath(self):
        return self.bin

    def getDB(self):
        return self.db

    def getNgsDB(self):
        return self.ngsdb

