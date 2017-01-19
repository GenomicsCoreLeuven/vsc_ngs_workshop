#Cheat Sheet

A quick overview of all available commands and variables.

## Account and Groups
Account and groups are managed through: [https://account.vscentrum.be/django/](https://account.vscentrum.be/django/)
```bash
#login to the VSC (vsc3XXXXX is your user id)
ssh vsc3XXXX@login.hpc.kuleuven.be
```
## Credits
```bash
#load the accounting module
module load accounting
#check how many credits you have left
gbalance
#ask a quote for this resources
gquote -l nodes=3:ppn=4:ivybridge,pmem=2gb,walltime=48:00:00
#get an overview of all jobs
gstatement
#get an overview of all jobs in the month september for the lp_projectname
gstatement -g lp_projectname -s 2015-09-01 -e 2015-09-30
#get infromation about a job
glsjob -J jobID
```

## Storage

| Storage Type | Path Environment Variable | Standard Size | Usage |
|--------------|---------------------------|---------------|-------|
| Home | /user/leuven/3XX/vsc3XXXX | $VSC_HOME | 25GB | Important data, like configuration files. Is private. |
| Data | /data/leuven/3XX/vsc3XXXX | $VSC_DATA | 75GB | Important data, biger data. Is private. |
| Scratch | /scratch/leuven/3XX/vsc3XXXX | $VSC_SCRATCH | 100GB | Temporary data, will be deleted within 21 days. |
| Node Scratch | | $VSC_SCRATCH_NODE | machine dependeble, min 150GB | Temporary data, while job is running. Can not be accessed from the login node. Data is lost at the jobs end. |
| Staging | /staging/leuven/stg_000XX | project dependable, per 1TB | Storage for project files, while still working at the project. |
| Archive | /archive/leuven/arc_000XX | project dependable, per 1TB | Backup for project files (or staging), long term storage. Only accessible from the login node. |

```bash
#get the size of a directory
du -h --max-depth=1 directoryname
#get the size of a partition
df -h directoryname
#change the permissions of a file
chmod u=rwx,g=rx,o=r -R myfile
chmod 754 -R myfile
#change the group of a file
chgrp -R groupname filename
#change the owner of a file
chown -R username filename

#check your used storage and limit on staging
mmlsquota  -j stg_000XX --block-size auto vol_ddn2
#on archive
mmlsquota  -j arc_000XX --block-size auto vol_ddn2
```
## The Module System
```bash
#give a list of available modules
module av
#load a module
module load modulename
module load modulename/moduleversion
#show a list of all loaded modules
module list
#unload a module
module unload modulename
#unload all modules at once
module purge
#show the help
module help
```

## The Hardware


| Cluster | Partition | CPUType | #nodes | #cores (threads) per node | Internal disk (Node Scratch) | Useable Memory (RAM) per node | #credits/hour |
|---------|-----------|---------|--------|---------------------------|------------------------------|-------------------------------|---------------|
| ThinKing | Ivybridge | Ivybridge | 208 | 20 | 250GB | 60GB (176nodes) - 124GB (32nodes) | 4.76 |
| ThinKing | Haswell | Haswell | 144 | 24 | 150GB | 60GB (42nodes) - 124GB (96nodes) | 6.68 |
| Cerebro | Smp1 | Ivybridge | 48 | 10 | shared 10TB | shared 250GB (max 11.77TB) | 3.45 |
| Cerebro | Smp2 | Ivybridge | 16 | 10 | shared 10TB | shared 124GB (max 1.79TB) | 3.45 |


Typical tasks run on the different clusters/partitions:


| Cluster | Partition | Task Description | Task Example |
|---------|-----------|------------------|--------------|
| ThinKing | Ivybridge | Memory low jobs, with lots of I/O | Alignment, Read Mapping, Variant Calling, Read Counting, ... |
| ThinKing | Haswell | Memory low jobs, low I/O, high computing power needed | Model Calculations, Sample clustering, Intensive populations studies (Differential expression analysis) | 
| Cerebro | Smp1 and Smp2 | High memory jobs, computing power less important | De Novo Assemblies, Reference based Assemblies, ... |


## Portable Batch System

A typical pbs script header:
```bash
#!/bin/bash -l
#PBS -l walltime=12:00:00
#PBS -l mem=100gb
#PBS -l nodes=1:ppn=20:ivybridge
#PBS -M mail@mail.com
#PBS -m aeb
#PBS -N jobname
#PBS -A lp_projectname
module load modulename modulename2
```
## Start Basic Jobs
```bash
#submit a job
qsub job.pbs
#show all requested/running jobs for the user
qstat -u vsc3XXXX
#show the estimated start for a job
showstart jobID
#check the status of a job
checkjob jobID
#show the status of the cluster
pbstop

#start a job automatically when another job finishes:
#start job1:
qsub job1.pbs
#returns JOB_ID
#start job2, waiting on job1 to finish:
qsub -W depend=afterany:JOB_ID job2.pbs
```
## Parallel Jobs
```bash
#load the worker module
module load worker/1.5.0-intel-2014a
#launch a batch job with the parameter variation
wsub -batch job.pbs -data data.csv
wsub -prolog beforejob.sh -batch job.pbs -epilog afterjob.sh -data data.csv
#start with 20 threads
wsub -l nodes=10:ppn5 -batch job.pbs -data data.csv -threaded 20
#show the process of a parallel hob
tail -f job.pbs.logXXXXXX
watch -n number_of_seconds job.pbs.logXXXXXX
```
An example of a parallel job, where each job gets a limited time.
```bash
#!/bin/bash -l
#PBS -l nodes=1:ppn=8
#PBS -l walltime=04:00:00
module load timedrun/1.0.1
cd $VSC_SCRATCH
timedrun -t 00:20:00 map -s $sample -r $reference -l $length
```
An example of the data file, belonging to the above pbs script. Note that the variables in the scripts are the heading in the file.
```
sample,reference,length
sample1,homo_sapiens,100
sample2,homo_sapiens,50
sample2,mus_musculus,50
sample3,homo_sapiens,100
sample3,homo_sapiens,50
...
```
## Interactive Nodes
```bash
qsub -I
qsub -X -I
```
