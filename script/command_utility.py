#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

import os
import subprocess
import time
import glob
import sys
import ConfigParser
import re

class utility:

    def __init__(self,user):
        self.owner = user 

    def checkFileNum(self,path):
        ch = os.listdir( path )
        counter = 0
        for c in ch:
            if os.path.isdir( path+c ):
                checkFileNum( path+c+sep )
            else:
                counter += 1
        return counter


    def check_mkdir(self,targetDir):
        if ( os.path.isdir(targetDir)):
            pass
        else:
            os.mkdir(targetDir)
        return


    def get_jobID_list(self):
        proc = subprocess.Popen('qstat', stdout=subprocess.PIPE)
        jobs = proc.communicate()[0]
        joblist = []
    
        for jobidx in range(len(jobs.split('\n'))-3):
            joblist.append(jobs.split('\n')[jobidx+2].split()[0])
    
        return joblist


    def qsub_cmd_ori(self,cmd):
        proc = subprocess.Popen(cmd, stdout = subprocess.PIPE)
        jobID = proc.communicate()[0].split()[2]
        return jobID

    def make_fixnfo_file(self, fixnfoFile, targetDir, type):
        flowcellLaneDirs = os.listdir(targetDir)
        dstfile = open(fixnfoFile, 'a')
        for flowcellLaneDir in flowcellLaneDirs: 
            dstfile.write(type + ':' + flowcellLaneDir + '\n')
        dstfile.close()
        return 
    
    def make_fixnfo_file_barcode(self, fixnfoFile, targetDir, sample):
        flowcellLaneDirs = os.listdir(targetDir)
        dstfile = open(fixnfoFile, 'a')
        dstfile.write(sample + '\n')
        dstfile.close()
        return 

    def get_fixnfo_file_data(self,fixnfoFile):
        lineArr = []
        tmplineArr = []
        f = open(fixnfoFile)
        lines = f.readlines()
        f.close()
        for line in lines:
            tmplineArr.append(line.rstrip())
        lineArr = list(set(tmplineArr))
        return lineArr


    def popen_command(self,cmd):
        proc = subprocess.Popen(cmd, stdout = subprocess.PIPE)
        result = proc.communicate()[0]
        return result
        

    def qsub_cmd(self,cmdex,qsub):
        result = ''
        cmd = []
        cmd.extend(qsub)
        cmd.extend(cmdex)
        print cmd
        while True:
            result = self.popen_command(cmd)
            if (result):
                break
            print 'info : retry qsub command'
            print cmd
            time.sleep(10)
        jobID = result.split()[2]
        return jobID
 

    def check_job_status(self,jobIDs):
        joblist = self.get_jobID_list()
        runstatus = []
        for jobID in jobIDs:
            if (jobID in joblist):
                runstatus.append(1)
            else:
                runstatus.append(0)
        return sum(runstatus)     


    def check_job_return_code(self,jobID, jobStatusHash):
        command = ['qacct2', '-o', self.owner, '-j']
        command.append(jobID)
        print command
        proc = subprocess.Popen(command, stdout=subprocess.PIPE)
        result = proc.communicate()[0]
        # if demon is faild (maybe...)
        if not (result):
            print 'info : retry status check '
            return 2

        code1 = ''
        code2 = ''
        resultList = result.split('\n')
        for line in resultList:
            if (code1 == '0' and code2 == '0'):
                break
            name1 = 'failed '
            if line.startswith(name1):
                tmpline = line.strip(name1)
                code1 = tmpline.strip()
            name2 = 'exit_status'
            if line.startswith(name2):
                tmpline = line.strip(name2)
                code2 = tmpline.strip()

        jobStatusHash[jobID] = 'job id : ' + jobID +' '+ name1+'='+code1 +' '+ name2+'='+code2
        if (code1 == '0' and code2 == '0'):
            return 0
        else:
            return 1


    def check_job_control(self,jobIDs,jobStatusHash):
        status = self.check_job_status(jobIDs)
        while(status != 0):
            time.sleep(2)
            status = self.check_job_status(jobIDs)

        returnCodeList = []
        for jobID in jobIDs:
            if not (jobStatusHash.has_key(jobID)):
                returnCode = self.check_job_return_code(jobID, jobStatusHash)
                returnCodeList.append(returnCode)
#               if (returnCode != 0):
                if (returnCode == 2):
                    break 
           
        if 1 in returnCodeList:
            print 'error: check return code'
            for k,v in jobStatusHash.items():
                print v
            sys.exit()

        sumRtrnCode = sum(returnCodeList)
        return sumRtrnCode


    def syncbarrier(self,cmd,jobIDs):
        print cmd , 'started.\n'
        print time.asctime( time.localtime(time.time()) ),'\n'
        print cmd ,'in progress. \n Waiting for submitted jobs to be finished.'
        jobStatusHash = {};
        chkSumCode = self.check_job_control(jobIDs, jobStatusHash)
        while (chkSumCode != 0):        
            time.sleep(60)
            chkSumCode = self.check_job_control(jobIDs, jobStatusHash)
        for k,v in jobStatusHash.items():
            print v
        print cmd ,'finished.'
        print time.asctime( time.localtime(time.time()) ),'\n'
        
        return


    def get_interval_region(self, filename):
        f = open(filename)
        lines = f.readlines()
        f.close()
        lastindex = len(lines)-1
        begstr = lines[0].rstrip()
        endstr = lines[lastindex].rstrip()
        begpos = (begstr.split('-'))[0]
        endpos = (endstr.split('-'))[1]
        region = begpos + '-' + endpos
        return region

    def os_system_bash_execute(self, cmd):
        str = cmd[0]
        for chr in cmd[1:len(cmd)]:
            str = str + ' ' + chr
        print 'bash ' + str
        os.system('bash ' + str)
        return

'''
    # this is old method
    ################################
    def syncbarrier(self,cmd,jobIDs):
        print cmd , 'started.\n'
        print time.asctime( time.localtime(time.time()) ),'\n'
        print cmd ,'in progress. \n Waiting for submitted jobs to be finished.'
        status = self.check_job_status(jobIDs)
        while(status != 0):
            status = self.check_job_status(jobIDs)
        print cmd ,'finished.'
        print time.asctime( time.localtime(time.time()) ),'\n'
        
        return

'''
