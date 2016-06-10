#!/bin/bash -l
module use /apps/leuven/thinking/2015a/modules/all 
module load Bowtie2/2.2.4-intel-2015a

GENOME_DIR="$VSC_DATA/tutorial/denovo/abyss_output/";

cd $VSC_SCRATCH;
mkdir genome;
cd genome;
rsync -ahr --copy-links $GENOME_DIR/genome_k31-unitigs.fa .;
mv genome_k31-unitigs.fa genome.fa;

#creating index
bowtie2-build $VSC_SCRATCH/genome/genome.fa $VSC_SCRATCH/genome/genome;

