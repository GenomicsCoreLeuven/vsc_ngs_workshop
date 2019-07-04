#Exercise Solutions

This are solutions for the exercises on the VSC.

> Note: these solutions were made in 2016 for the Thinking cluster. Since 2019, you will have to use the Genius cluster. Therefor some tools and versions are not up to date.

#PART 1: High Performance Computing

##Exercise 1
Since no tasks can be performed without raw data, and results should be kept for longer periodes, storage is an important feature of a cluster. Therefor the first exercise is to check the different environment variables, and find there complete path.
Find the path for the following locations:


| Storage Type | Environment Variable | Path |
|--------------|:--------------------:|------|
| Home | $VSC_HOME | /user/leuven/3XX/vsc3XXXX |
| Data | $VSC_DATA | /data/leuven/3XX/vscXXXX |
| Scratch | $VSC_SCRATCH | /node_scratch NOTE:this is only the scratch of the login node!|
| Node Scratch | $VSC_SCRATCH_NODE | |
| Staging | | /staging/leuven/stg_000XX |
| Archive | | /archive/leuven/arc_000XX |

##Exercise 2
Computing costs money, therefor the VSC uses a credit based system for the accounting.
- Get an overview of your current balance
```bash
module load accounting
gbalance
```
- Get an overview of your transactions of the last month
```bash
gstatement -s 2016-05-01 -e 2016-05-31
```
- Get a quote for 5 minutes computing on 1 node, 5 processors of the ivybridge type
```bash
gquote -l nodes=1:ppn=5:ivybridge,walltime=0:05:00
```
- Get a quote for 20 minutes computing on 2 nodes, 4 processors of the haswell type, using 100Gb of memory
```bash
gquote -l nodes=2:ppn=4:haswell,pmem=100gb,walltime=0:20:00
```
- Get a quote for 1 hour for both the ivybridge and the haswell processor
```bash
gquote -l nodes=1:ppn=1:ivybrige,walltime=1:00:00
gquote -l nodes=1:ppn=1:haswell,walltime=1:00:00
```

##Exercise 3
This exercise uses the paths.pbs script
- Open paths.pbs
```bash
#multiple methods to view:
cat paths.pbs
less paths.pbs
more paths.pbs
#to edit
nano paths.pbs
vim paths.pbs
```
- Edit the PBS header (change the mail, and accounting information)
```
change the mail (-M)
change the accounting (-A)
```
- Ask a quote based on the PBS header
```bash
gqoute -l nodes=1:ppn=1:ivybridge,pmem=6gb,walltime=0:05:00
```
- Start the job on thinking
```bash
qsub paths.pbs
#returns the jobID
```
- Check the start time and status of the job
```bash
showstart jobID
checkjob jobID
qstat -u vsc3XXXX
```
- Check the output of the job
```bash
cat pahts.txt
#output should be similar to exercise 1
```

#PART 2: For Genomics
Up till now the exercises were ment only as an introduction. Here we start with a more real-life example of a bioinformatics project.
Assume this population study:

We have 2 populations, population 1 has 14 individuals, population 2 only 5.
There is no reference genome available.
Are there ‘diagnostic’ variations between the 2 populations.

Project parts:
- Assembly
- Mapping
- Variant calling

The actual data is Phi X 174. The first population is actual sequenced PhiX in the Genomics Core. The second population is simulated data from the ncbi reference genome.


Some more information about Phi X 174: 
- Bacteriophage
- First sequenced DNA virus (1977)
- Circular, single stranded DNA genome of 5386bp, GCcontent 44%
- 95% are coding genes, total of 11 genes
- Used as positive control in Illumina sequencing

##Exercise 4
A *de novo* assembly of a small circular genome. The basic principle is: reads are put together if they overlap, resulting in a contig. In this case, we have a circular genome, with only 1 chromosome. So in the ultimate case, we end with one contig.

ABySS will be used in this exercise. ABySS is a widely used de Bruijn graph assembler. Since circular genomes are hard to assemble (since there is no clear choose where to cut the genome to make it linear), a large kmer size has to be chosen (so it can split the genome easily in one or multiple contigs).
- Since *de novo* assembly generally uses a lot of memory, this task has to run on cerebro. Load Cerebro
```bash
module load cerebro
```
- Load ABySS (in the 2015a toolchain)
```bash
module av
source switch_to_2015a
module av
module load ABySS
```
- Check the abyss.pbs file, change the header/variables if needed
```bash
nano abyss.pbs
```
- Launch the abyss.pbs script. Note taht the returned job ID start with a 3.
```bash
qsub abyss.pbs
#returns a jobID, starting with a 3
```
- Check the output of the assembly
```bash
ls $VSC_DATA/vsc_ngs_workshop/results/denovo
```

##Exercise 5
The next exercise is best to run on thinking.
- List all loaded modules
```bash
module list
```
- Unload or Purge these modules
```bash
module unload cerebro
module purge
```
- Load the thinking module
```bash
module load thinking
```

In this exercise we are going to map multiple samples against our new assembled reference genome. Mapping is the process where you compare your sequences against a reference in order to get the location of your sequence on the reference genome. BWA and Bowtie are examples of widely used mapping tools. In this exercise Bowtie2 will be used.

Our project is a population study of 19 individuals. We will use the reference generated in Exercise 4. If the tasks are split, 20 tasks are needed: the indexing of the genome by the mapping tool (is only needed once, so can be reused), the mapping of the samples (19 samples, so 19 tasks). If the number of individuals would rise more, the number of scripts to run will get to high to be manageable. Therefor the solution is to use parallel jobs.

###A
- Open bowtie_batch.pbs
```bash
nano bowtie_batch.pbs
```
- Change script (mail, accounting, number of cores?)
```bash
##CHANGE:
#PBS -l nodes=1:ppn10:ivybrige
##TO:
#PBS -l nodes=1:ppn20:ivybrige
```
- Variable name?
```
$SAMPLE
```
- input/output path?
- Reference genome?
```bash
$VSC_SCRATCH/genome/genome
```

###B
- Open prolog script
- What happens?
```
The created genome in exercise 4 is copied to $VSC_SCRATCH/genome/ and is renamed to genome.fa. The needed bowtie2 index is created
```
- Where is the genome stored?
```
$VSC_SCRATCH/genome/genome
```

###C
- Open epilog script
- What happens?

###D
- Start job on thinking
```bash
source switch_to_2015a
module load worker
wsub -prolog bowtie_prolog.sh -batch bowtie_batch.pbs -data samples.csv
#if you want to submit it with the epilog:
wsub -prolog bowtie_prolog.sh -batch bowtie_batch.pbs -epilog bowtie_epilog.sh -data samples.csv
```
- Check mapping statistics (especially the data for the assembly)

##HomeWork
The samples used in Exercise 5, contains out of 2 populations. In population studies variants that only occur in one of the populations are interseting. FreeBayes is an easy variant calling tool for populations, since it can call variants in multiple samples at the same time. Write a PBS script base on these commands, and execute this on the VSC:

```bash
source switch_to_2015a
module load freebayes/1.0.2-33-foss-2015a

#set some variables (see other scripts)

GENOME="$GIT_DIR/results/denovo/genome_k31-unitigs.fa";
BAM_DIR="$GIT_DIR/results/mapping";
FREEBAYES_OPTIONS="-m 20 -q 15 --ploidy 2 ";
FREEBAYES_OUTPUT_FILE_NAME="freebayes.m20.q15.ploidy2.vcf";

#copy the GENOME to $VSC_SCRATCH_NODE/genome/genome.fa
#copy the bam files to the $VSC_SCRATCH_NODE/bams directory
bamfiles="";
for i in `ls -1 -d $VSC_SCRATCH_NODE/bams/*bam`;
do
        bamfiles="$bamfiles $i";
done

#do the variant calling
freebayes --fasta-reference $SCRATCH_DIR/genome/genome.fa $FREEBAYES_OPTIONS $bamfiles > $SCRATCH_DIR/$FREEBAYES_OUTPUT_FILE_NAME;

#copy the data
```

How many variants do you find? And how many of these variants are interesting to discriminate the populations?
```bash
#The needed script can be found in the script directory. There are 5 variants:
grep -v "#" freebayes.m20.q15.ploidy2.vcf | wc -l
```



