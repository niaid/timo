#! /usr/bin/env python

import os.path
import tools.compare_csv

filenames = [ 'CV-39_fixed.STRAIN.SARS-CoV2.0.01.snplist.csv',
              'CV-44_fixed.STRAIN.SARS-CoV2.0.01.snplist.csv',
              'CV-46_fixed.STRAIN.SARS-CoV2.0.01.snplist.csv',
              'CV_03_fixed.STRAIN.SARS-CoV2.0.01.snplist.csv',
              'CV_19_fixed.STRAIN.SARS-CoV2.0.01.snplist.csv',
              'CV_30_fixed.STRAIN.SARS-CoV2.0.01.snplist.csv' ]


for x in filenames:
    print(x)

srcdir = 'orig/FILES/fullvarlist/'
#targetdir = 'p2/FILES/fullvarlist/'
targetdir = 'p3/FILES/fullvarlist/'

total_bad_count = 0

for x in filenames:
   src = srcdir + x
   target = targetdir + x
   print (src, target)

   src_csv = tools.compare_csv.load_csv(src)
   target_csv = tools.compare_csv.load_csv(target)

   bad = tools.compare_csv.compare_csvs(src_csv, target_csv, 2, 1e-6)
   total_bad_count = total_bad_count + bad

print("")
print(total_bad_count, "total mismatches")
