#! /usr/bin/env python

import os
import subprocess


def getData():

    script_dir = os.path.dirname(os.path.realpath(__file__))
    root_dir = os.path.dirname(script_dir)

    data_files = [
        [ 'CV_19_fixed.cov19.rmd.merged.bam', '5fb5412e50a41e3d195dc035' ],
        [ 'CV_19_fixed.cov19.rmd.merged.bam.bai', '5fb573cd50a41e3d195e569e', ],
        [ 'Results/CV_19_fixed.STRAIN.SARS-CoV2.0.01.snplist.csv', '5fb573db50a41e3d195e56a8' ],
    ]


    data_dir = root_dir + '/Data/'

    url = 'https://data.kitware.com/api/v1/file/'

    for x in data_files:
        name = x[0]
        hash_id = x[1]
        print("")
        print(name, hash_id)

        full_path =  data_dir + name
        if os.path.isfile(full_path):
            print(full_path, "exists")
        else:
            params = [ 'curl', '-o', full_path, url + hash_id + '/download' ]
            print(params)
            subprocess.run(params)

    print("")

if __name__ == '__main__':
    getData()
