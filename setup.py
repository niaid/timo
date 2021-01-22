import os
from distutils.core import setup
from Cython.Build import cythonize

os.environ['CFLAGS'] = '-O3 -Wall'

setup(
     ext_modules = cythonize('analyzer.pyx')
     )
