#!/bin/sh

#### USER CHANGES THESE VARIABLES DEPENDING ON RUN ######
### run: bash ./run_IndexVariants.sh
JOB_NAME="COV19-Variants"
RUNDIR="/scratch/kej310/COV19/NYU/"
BAM_DIR="/scratch/kej310/COV19/NYU/retry/" #using bam because of index
STRAIN="cov19" #lowercase strain name
REFSEQ="/scratch/kej310/COV19/NYU/reference/cov19/SARS-COV-2.fasta"
USER='kej310@nyu.edu' #email for running information
array=0-1 #number of samples! (not number of bams...) originally 0-21


#### DON'T TOUCH BELOW HERE #####
cd ${RUNDIR}
sbatch --mail-type=END --mail-user=$USER --job-name=$JOB_NAME -a ${array} index_variants.sh ${BAM_DIR} ${RUNDIR} ${STRAIN} ${REFSEQ}

