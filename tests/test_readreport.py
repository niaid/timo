
import unittest
import getData
import subprocess
import os

class TestReadReport(unittest.TestCase):

    scriptDir = os.path.dirname(os.path.realpath(__file__))
    rootDir = os.path.dirname(scriptDir)
    dataDir = rootDir + '/Data'


    @classmethod
    def setUpClass(cls):
        getData.getData()


    def test_readreport(self):
        print("\nTesting readreport")
        print(self.dataDir)

        ret = subprocess.run( [ 'python', self.rootDir+'/readreport_v4_2.py', 
            '--infile', self.dataDir+'/CV_19_fixed.cov19.rmd.merged.bam', 
            '--ref', self.dataDir+'/SARS-COV-2.fasta'
            ] )

        print("readreport returns", ret)
        if ret.returncode:
            self.fail("readreport returncode = " + str(ret.returncode))

        output = self.rootDir + '/FILES/fullvarlist/CV_19_fixed.STRAIN.SARS-CoV2.0.01.snplist.csv'
        result = self.dataDir + '/Results/CV_19_fixed.STRAIN.SARS-CoV2.0.01.snplist.csv'

        ret = subprocess.run( [ 'python', self.rootDir+'/tools/compare_csv.py', 
            output, result] )
        
        if ret.returncode:
            self.fail("compare_csv returncode = " + str(ret.returncode))
