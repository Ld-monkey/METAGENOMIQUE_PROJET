# METAGENOMIQUE_PROJET
Projet de métagénomique pour le master II de Bio-informatique.


```bash
./16S_workflow.sh fastq results
```
# Architecture du projet :
Cette architecture doit être respectée pour pourvoir lancer le programme.
```bash
.
├── 16S_workflow.sh
├── databases
│   ├── contaminants.fasta
│   └── mock_16S_18S.fasta
├── fastq
│   ├── 1ng-25cycles-1_R1.fastq.gz
│   ├── 1ng-25cycles-1_R2.fastq.gz
│   ├── 1ng-25cycles-2_R1.fastq.gz
│   ├── 1ng-25cycles-2_R2.fastq.gz
│   ├── 1ng-25cycles-3_R1.fastq.gz
│   ├── 1ng-25cycles-3_R2.fastq.gz
│   ├── 1ng-30cycles-1_R1.fastq.gz
│   ├── 1ng-30cycles-1_R2.fastq.gz
│   ├── 1ng-30cycles-2_R1.fastq.gz
│   ├── 1ng-30cycles-2_R2.fastq.gz
│   ├── 1ng-30cycles-3_R1.fastq.gz
│   ├── 1ng-30cycles-3_R2.fastq.gz
│   ├── zero5ng-25cycles-1_R1.fastq.gz
│   ├── zero5ng-25cycles-1_R2.fastq.gz
│   ├── zero5ng-25cycles-2_R1.fastq.gz
│   ├── zero5ng-25cycles-2_R2.fastq.gz
│   ├── zero5ng-25cycles-3_R1.fastq.gz
│   ├── zero5ng-25cycles-3_R2.fastq.gz
│   ├── zero5ng-30cycles-1_R1.fastq.gz
│   ├── zero5ng-30cycles-1_R2.fastq.gz
│   ├── zero5ng-30cycles-2_R1.fastq.gz
│   ├── zero5ng-30cycles-2_R2.fastq.gz
│   ├── zero5ng-30cycles-3_R1.fastq.gz
│   └── zero5ng-30cycles-3_R2.fastq.gz
├── FastQC
│   ├── fastqc
│   ├── fastqc_icon.ico
│   ├── Help

└── soft
    ├── AlienTrimmer.jar
    ├── AlienTrimmer.java
    ├── COPYING
    ├── JarMaker.sh
    ├── Makefile
    └── vsearch
```
