#!/bin/bash -l

#The prolog is a regular sh script
#if we want to execute tools, the tools have to be loaded:
source switch_to_2015a
module load Bowtie2/2.2.4-intel-2015a

#This is setting the variables needed in this sh script
CLONE_DIR="$VSC_DATA"; #This one must be the directory where you performed the git clone
GIT_DIR="$CLONE_DIR/vsc_ngs_workshop";
GENOME_DIR="$GIT_DIR/results/denovo";
OUTPUT_DIR="$GIT_DIR/results/mapping";

mkdir -p $VSC_SCRATCH/genome;
cd $VSC_SCRATCH/genome;

rsync -ahrL $GENOME_DIR/genome_k31-unitigs.fa .;
mv genome_k31-unitigs.fa genome.fa;

#creating index
bowtie2-build $VSC_SCRATCH/genome/genome.fa $VSC_SCRATCH/genome/genome;

